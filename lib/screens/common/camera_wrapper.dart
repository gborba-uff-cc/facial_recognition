import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

typedef CameraWrapperCallBack = void Function(
  pkg_camera.CameraController cameraController,
  pkg_camera.CameraImage cameraImage,
);

typedef _CameraStreamContent = ({
  pkg_camera.CameraImage image,
  pkg_camera.CameraController controller,
});

class CameraWrapper extends StatefulWidget {
  const CameraWrapper({
    super.key,
    required this.camerasAvailable,
    CameraWrapperCallBack? imageCaptureHandler,
    CameraWrapperCallBack? imageStreamHandler,
    this.streamDiscardCount = 29,
  })  : _imageCaptureHandler = imageCaptureHandler,
        _imageStreamHandler = imageStreamHandler;

  final List<pkg_camera.CameraDescription> camerasAvailable;
  final CameraWrapperCallBack? _imageCaptureHandler;
  final CameraWrapperCallBack? _imageStreamHandler;
  /// discard [streamDiscardCount] images after handling 1 image from the
  /// stream for load balance
  final int streamDiscardCount;
  final double _baseIconSize = 80;
  final double _basePadding = 8;

  @override
  State<CameraWrapper> createState() => _CameraWrapperState();

  double get baseIconSize => _baseIconSize;
  double get basePadding => _basePadding;
}

class _CameraWrapperState extends State<CameraWrapper> with WidgetsBindingObserver {
  // SECTION - STREAMS ---------------------------------------------------------
  /* wrap original stream allowing multiple subscriptions */
  final StreamController<_CameraStreamContent> _cameraImageBroadcastStream =
      StreamController.broadcast();
  /* subscription receiving the same elements as the original stream */
  late final StreamSubscription<_CameraStreamContent> _cameraImageStreamSubscription;
  /* subscription receiving elements when capture button is tapped */
  late final StreamSubscription<_CameraStreamContent> _cameraImageCaptureSubscription;
  /*
  the frequency at which images are processed in the stream subscription;
  i.e. how many discarded images after handling one image;
  */
  late _ModularCounter _imageCounterFilter;
  /* sinalize the capture stream handler to handle images when true */
  final _Box<bool> _shouldCaptureImage = _Box(false);
  final _Box<bool> _isDisposing = _Box(false);
  // !SECTION ------------------------------------------------------------------

  // SECTION - CAMERA CONTROLLER -----------------------------------------------
  pkg_camera.CameraController? _cameraController;
  double _cameraControllerMinZoom = 1.0;
  double _cameraControllerMaxZoom = 1.0;
  double _cameraControllerBaseZoom = 1.0;
  double _cameraControllerCurrentZoom = 1.0;
  late _ModularCounter _selectedCameraIndex;
  // !SECTION ------------------------------------------------------------------

  @override
  void initState() {
    projectLogger.fine('[camera_wrapper] initState()');
    super.initState();
    // setup to receive calls to didChangeAppLifecycleState
    WidgetsBinding.instance.addObserver(this);
    // ----- late variables
    _imageCounterFilter = _ModularCounter(widget.streamDiscardCount);
    _selectedCameraIndex = _ModularCounter(widget.camerasAvailable.length);
    _cameraImageStreamSubscription =
        _cameraImageBroadcastStream.stream.listen(null);
    _cameraImageCaptureSubscription =
        _cameraImageBroadcastStream.stream.listen(null);
    // -----
    _updateStreamHandlers(
      capturedImageHandler: widget._imageCaptureHandler,
      streamedImageHandler: widget._imageStreamHandler,
    );
    if (widget.camerasAvailable.isNotEmpty) {
      final description = widget.camerasAvailable[_selectedCameraIndex.current];
      _onNewCameraSelected(description);
    }
  }

  @override
  void dispose() {
    projectLogger.fine('[camera_wrapper] dispose()');
    _isDisposing.value = true;
    final controller = _cameraController;
    if (controller != null) {
      _stopCameraController(controller);
    }
    // -----
    _cameraImageStreamSubscription.cancel();
    _cameraImageCaptureSubscription.cancel();
    _cameraImageBroadcastStream.close();
    // -----
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // handle calls to build targeting this.widget
  @override
  void didUpdateWidget(covariant CameraWrapper oldWidget) {
    projectLogger.fine('[camera_wrapper] didUpdateWidget()');
    super.didUpdateWidget(oldWidget);

    _updateStreamHandlers(
      capturedImageHandler: widget._imageCaptureHandler,
      streamedImageHandler: widget._imageStreamHandler,
    );
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) async {
    projectLogger.fine('[camera_wrapper] didUpdateLifeCycleState()');
    super.didChangeAppLifecycleState(state);

    final controller = _cameraController;
    switch (state) {
      case AppLifecycleState.resumed:
        final description = widget.camerasAvailable[_selectedCameraIndex.current];
        await _onNewCameraSelected(description);
        break;
      case AppLifecycleState.inactive:
        if (controller != null) {
          await _stopCameraController(controller);
        }
        break;
      default:
    }
  }

  Future<void> _onNewCameraSelected(
    pkg_camera.CameraDescription description,
  ) async {
    final oldController = _cameraController;
    projectLogger.fine('[camera_wrapper] _onNewCameraSelected()');
    if (oldController != null && oldController.value.isInitialized) {
      await _stopCameraController(oldController);
    }
    await _startCameraController(description);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _stopCameraController(
    pkg_camera.CameraController controller,
  ) async {
    projectLogger.fine('[camera_wrapper] _stopCameraController()');
    _cameraController = null;
    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    if (controller.value.isInitialized) {
      await controller.dispose();
    }
  }

  Future<void> _startCameraController(
    pkg_camera.CameraDescription description,
  ) async {
    projectLogger.fine('[camera_wrapper] _startCameraController()');
    _cameraControllerCurrentZoom = 1.0;
    _cameraControllerMinZoom = 1.0;
    _cameraControllerMaxZoom = 1.0;
    final controller = pkg_camera.CameraController(
      description,
      pkg_camera.ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? pkg_camera.ImageFormatGroup.yuv420
          : Platform.isIOS
              ? pkg_camera.ImageFormatGroup.bgra8888
              : pkg_camera.ImageFormatGroup.jpeg,
    );

    try {
      await controller.initialize();
      final futures = await Future.wait([
        controller.getMinZoomLevel(),
        controller.getMaxZoomLevel(),
      ]);
      _cameraControllerCurrentZoom = futures[0];
      _cameraControllerMinZoom = futures[0];
      _cameraControllerMaxZoom = futures[1];
      if (controller.value.isPreviewPaused) {
        await controller.pausePreview();
      }
      await controller.startImageStream((image) {
        _cameraImageBroadcastStream.add((image: image, controller: controller));
      });
    }
    on pkg_camera.CameraException catch (e) {
      _logCameraException(e);
    }
    setState(() {
      _cameraController = controller;
    });
  }

  void _logCameraException(
    pkg_camera.CameraException exception,
  ) {
    String message = '';
    bool isShout = false;
    switch (exception.code) {
      case 'CameraAccessDenied':
        message = 'You have denied camera access.';
        break;
      case 'CameraAccessDeniedWithoutPrompt':
        message = 'Please go to Settings app to enable camera access.';
        break;
      case 'CameraAccessRestricted':
        message = 'Camera access is restricted.';
        break;
      case 'AudioAccessDenied':
        message = 'You have denied audio access.';
        break;
      case 'AudioAccessDeniedWithoutPrompt':
        message = 'Please go to Settings app to enable audio access.';
        break;
      case 'AudioAccessRestricted':
        message = 'Audio access is restricted.';
        break;
      default:
        message = 'Unknow CameraException code';
        isShout = true;
    }
    if (isShout) {
      projectLogger.shout(message, exception);
    } else {
      projectLogger.severe(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraController;
    Widget buildObject;
    if (controller == null || !controller.value.isInitialized) {
      buildObject = const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Iniciando camera',
          ),
        ),
      );
    }
    else {
      final iconColor = Theme.of(context).colorScheme.primary;
      final backgroundIconColor = Colors.grey.shade300;
      buildObject = pkg_camera.CameraPreview(
        controller,
        child: SizedBox(
          height: double.infinity,
          child: Stack(
            children: [
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) =>
                    GestureDetector(
                  onScaleStart: (details) => _startZoom(details),
                  onScaleUpdate: (details) => _updateZoom(details),
                  onTapDown: (details) =>
                      _setExposureAndFocusPoint(details, constraints),
                ),
              ),
              if (widget._imageCaptureHandler != null)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: widget._basePadding),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _onCaptureTapped,
                      child: Container(
                        height: widget._baseIconSize,
                        width: widget._baseIconSize,
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: backgroundIconColor,
                        ),
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            Icons.circle_outlined,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: widget._basePadding),
                  child: SizedBox(
                    height: widget._baseIconSize,
                    width: widget._baseIconSize,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _onSwitchCameraPressed,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(
                            shape: const CircleBorder(),
                            color: backgroundIconColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: Icon(
                                Icons.cameraswitch_outlined,
                                color: iconColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return buildObject;
  }

  void _startZoom(
    ScaleStartDetails details,
  ) {
    if (details.pointerCount == 2) {
      _cameraControllerBaseZoom = _cameraControllerCurrentZoom;
      return;
    }
  }

  void _updateZoom(
    ScaleUpdateDetails details,
  ) {
    if (details.pointerCount == 2) {
      _cameraControllerCurrentZoom = (_cameraControllerBaseZoom * details.scale)
          .clamp(_cameraControllerMinZoom, _cameraControllerMaxZoom);
      _cameraController?.setZoomLevel(_cameraControllerCurrentZoom);
      return;
    }
  }

  void _setExposureAndFocusPoint(
    TapDownDetails details,
    BoxConstraints constraints,
  ) {
    final controller = _cameraController;
    final normalizedOffset = _normalizedOffsetOfTapPosition(details.localPosition, constraints);

    if (controller == null) {
      return;
    }
    else {
      controller.setExposurePoint(normalizedOffset);
      controller.setFocusPoint(normalizedOffset);
    }
  }

  Offset _normalizedOffsetOfTapPosition(
    Offset position,
    BoxConstraints constraints,
  ) =>
      Offset(
        position.dx / constraints.maxWidth,
        position.dy / constraints.maxHeight,
      );

  void _onCaptureTapped() {
    _shouldCaptureImage.value = true;
  }

  Future<void> _onSwitchCameraPressed() async {
    projectLogger.fine('[camera_wrapper] _onSwitchCameraPressed()');
    _selectedCameraIndex.tick();
    final description = widget.camerasAvailable[_selectedCameraIndex.current];
    await _onNewCameraSelected(description);
  }

  /// start/stop capture and stream data handler
  void _updateStreamHandlers({
    required final CameraWrapperCallBack? capturedImageHandler,
    required final CameraWrapperCallBack? streamedImageHandler,
  }) {
    _updateCaptureSubscriptionHandler(capturedImageHandler);
    _updateStreamSubscriptionHandler(streamedImageHandler);
  }

  /// start/stop calling the stream dataHandler
  void _updateStreamSubscriptionHandler(
    CameraWrapperCallBack? dataHandler,
  ) {
    _cameraImageStreamSubscription.onData(
      dataHandler != null
          ? (streamContent) {
              final isZero = _imageCounterFilter.current == 0;
              _imageCounterFilter.tick();
              if (isZero) {
                dataHandler(streamContent.controller, streamContent.image);
              }
            }
          : null,
    );
  }

  /// start/stop calling the capture dataHandler
  void _updateCaptureSubscriptionHandler(
    CameraWrapperCallBack? dataHandler,
  ) {
    _cameraImageCaptureSubscription.onData(
      dataHandler != null
          ? (streamContent) {
              if (_shouldCaptureImage.value) {
                _shouldCaptureImage.value = false;
                dataHandler(streamContent.controller, streamContent.image);
              }
            }
          : null,
    );
  }
}

class _ModularCounter {
  _ModularCounter(this.module);

  final int module;
  int _current = 0;

  int get current => _current;

  void tick() {
    _current = (_current+1) % module;
  }
}

/// help to bypass a value inside a closure
class _Box<T> {
  _Box(this.value);

  T value;
}
