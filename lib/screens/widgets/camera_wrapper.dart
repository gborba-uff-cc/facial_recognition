import 'dart:async';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class CameraWrapper extends StatefulWidget {
  const CameraWrapper({
    super.key,
    required this.camerasAvailable,
    void Function()? onCapturePressed,
    void Function(
      pkg_camera.CameraDescription cameraDescription,
      pkg_camera.CameraImage cameraImage,
    )?
        imageStreamHandler,
    this.streamDiscardCount = 29,
  })  : _onCapturePressed = onCapturePressed,
        _imageStreamHandler = imageStreamHandler;

  final List<pkg_camera.CameraDescription> camerasAvailable;
  final void Function()? _onCapturePressed;
  final void Function(
    pkg_camera.CameraDescription cameraDescription,
    pkg_camera.CameraImage cameraImage,
  )? _imageStreamHandler;
  /// discard [streamDiscardCount] images after handling 1 image from the
  /// stream for load balance
  final int streamDiscardCount;

  @override
  State<CameraWrapper> createState() => _CameraWrapperState();
}

class _CameraWrapperState extends State<CameraWrapper> with WidgetsBindingObserver {
  // controll the frequency at which images are processed
  late _ModularCounter _imageCounterFilter;
  StreamController<pkg_camera.CameraImage>? _cameraImageStreamController;
  StreamSubscription<pkg_camera.CameraImage>? _cameraImageStreamSubscription;

  pkg_camera.CameraController? cameraController;
  double _cameraControllerMinZoom = 1.0;
  double _cameraControllerMaxZoom = 1.0;
  double _cameraControllerBaseZoom = 1.0;
  double _cameraControllerCurrentZoom = 1.0;
  late _ModularCounter _selectedCameraIndex;

  @override
  void initState() {
    super.initState();
    // setup to receive calls to didChangeAppLifecycleState
    WidgetsBinding.instance.addObserver(this);
    if (widget.camerasAvailable.isNotEmpty) {
      _selectedCameraIndex = _ModularCounter(widget.camerasAvailable.length);
      _onNewCameraSelected(widget.camerasAvailable[_selectedCameraIndex.current]);
      _imageCounterFilter = _ModularCounter(widget.streamDiscardCount);
    }
    else {}
  }

  @override
  void dispose() {
    final controller = cameraController;
    if (controller != null) {
      _stopImageStream(controller);
      controller.dispose();
    }

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    super.didChangeAppLifecycleState(state);
    final pkg_camera.CameraController? controller = cameraController;

    if (
      // App state changed before we got the chance to initialize.
      controller == null ||
      !controller.value.isInitialized) {
      return;
    }
    else {
      switch (state) {
        case AppLifecycleState.resumed:
          _initializeCameraController(controller.description).then(
            (startedController) {
              if (mounted) {
                setState(() {
                  cameraController = startedController;
                });
              }
            },
          );
          break;
        case AppLifecycleState.inactive:
          controller.dispose();
          break;
        default:
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = cameraController;
    Widget buildObject;
    if (controller == null) {
      buildObject = const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Camera preview',
          ),
        ),
      );
    }
    else {
      const double baseIconSize = 80;
      const double bottomPadding = 8;
      final iconColor = Theme.of(context).colorScheme.primary;
      final backgroundIconColor = Colors.grey.shade300;
      buildObject = Align(
        alignment: Alignment.center,
        child: pkg_camera.CameraPreview(
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: bottomPadding),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: widget._onCapturePressed,
                      child: Container(
                        height: baseIconSize,
                        width: baseIconSize,
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
                    padding: const EdgeInsets.only(bottom: bottomPadding),
                    child: SizedBox(
                      height: baseIconSize,
                      width: baseIconSize,
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
        ),
      );
    }
    return buildObject;
  }

  Future<pkg_camera.CameraController?> _initializeCameraController(
      pkg_camera.CameraDescription description,
  ) async {
    final controller = pkg_camera.CameraController(
      description,
      pkg_camera.ResolutionPreset.high,
      enableAudio: false,
      // imageFormatGroup: ImageFormatGroup.yuv420
    );

    controller.addListener(
      () {
        if (controller.value.hasError) {
          projectLogger.warning(controller.value.errorDescription);
        }
      },
    );

    try {
      await controller.initialize();
      _cameraControllerMinZoom = await controller.getMinZoomLevel();
      _cameraControllerMaxZoom = await controller.getMaxZoomLevel();
      _cameraControllerCurrentZoom = 1.0;

      return controller;
    } on pkg_camera.CameraException catch (e) {
      _logCameraException(e);
    }
    _cameraControllerCurrentZoom = 1.0;
    _cameraControllerMinZoom = 1.0;
    _cameraControllerMaxZoom = 1.0;

    return null;
  }

  void _onNewCameraSelected(
    pkg_camera.CameraDescription description,
  ) async {
    final oldController = cameraController;
    // stop image stream on old controller
    if (oldController != null) {
      _stopImageStream(oldController);
    }

    // update camera controller
    if (oldController == null) {
      _initializeCameraController(description).then(
        (startedController) {
          if (startedController != null) {
            _startImageStream(startedController);
          }
          if (mounted) {
            setState(() {
              cameraController = startedController;
            });
          }
        },
      );
    } else {
      oldController.setDescription(description).then(
        (value) => _startImageStream(oldController),
        onError: (error) {
          switch (error) {
            case pkg_camera.CameraException:
              _logCameraException(error);
              break;
            default:
              projectLogger.severe(error);
          }
        },
      );
    }
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

  void _startImageStream(
    pkg_camera.CameraController controller,
  ) {
    final streamHandler = widget._imageStreamHandler;
    if (streamHandler != null) {
      final streamController = StreamController<pkg_camera.CameraImage>();
      _cameraImageStreamController = streamController;
      _cameraImageStreamSubscription =
          streamController.stream.where((cameraImage) {
        final isZero = _imageCounterFilter.current == 0;
        _imageCounterFilter.tick();
        return isZero ? true : false;
      }).listen(
        (cameraImage) => streamHandler(
          widget.camerasAvailable[_selectedCameraIndex.current],
          cameraImage,
        ),
      );
      controller.startImageStream((image) => streamController.add(image));
    }
  }

  void _stopImageStream(pkg_camera.CameraController controller) {
    final streamHandler = widget._imageStreamHandler;
    if (streamHandler != null) {
      final streamSubscription = _cameraImageStreamSubscription;
      final streamController = _cameraImageStreamController;

      controller.stopImageStream();
      if (streamSubscription != null) {
        streamSubscription.cancel();
      }
      if (streamController != null) {
        streamController.close();
      }
    }
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
      cameraController?.setZoomLevel(_cameraControllerCurrentZoom);
      return;
    }
  }

  void _setExposureAndFocusPoint(
    TapDownDetails details,
    BoxConstraints constraints,
  ) {
    final controller = cameraController;
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

  void _onSwitchCameraPressed()
  {
    _selectedCameraIndex.tick();
    _onNewCameraSelected(widget.camerasAvailable[_selectedCameraIndex.current]);
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
