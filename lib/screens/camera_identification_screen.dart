import 'dart:async';

import 'package:camera/camera.dart';
import 'package:facial_recognition/use_case/camera_identification.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraIdentificationScreen extends StatefulWidget {
  const CameraIdentificationScreen({
    super.key,
    required this.cameras,
    required this.useCase,
  });

  final CameraIdentification useCase;
  final List<CameraDescription> cameras;

  @override
  State<CameraIdentificationScreen> createState() => _CameraIdentificationScreenState();
}

class _CameraIdentificationScreenState extends State<CameraIdentificationScreen> with WidgetsBindingObserver {
  late CameraDescription _selectedCamera;
  // NOTE - a new controller is needed after a dispose (dispose can be called
  // more than once), so...
  //  create controller on: initState, app is resumed, change camera source
  //  delete controller on: dispose, app is inactive, change camera source
  CameraController? cameraController;
  final List<Uint8List> facesPhotos = [];
  // controll the frequency and which what images are processed
  final StreamController<CameraImage> _cameraImageStreamController = StreamController();
  StreamSubscription<CameraImage>? _cameraImageStreamSubscription;
  final _imageCounterFilter = _ModularCounter(30);

  @override
  void initState() {
    super.initState();
    // Register this object as a binding observer to receive application events
    WidgetsBinding.instance.addObserver(this);
    // update useCase.showFaceImages callback with how to show detected faces
    widget.useCase.showFaceImages = (jpegImages) {
      if (mounted) {
        setState(() {
          facesPhotos.addAll(jpegImages);
        });
      }
    };
    // controller life cycle is handled here and on didChangeAppLifecycleState
    if (widget.cameras.isNotEmpty) {
      _selectedCamera = widget.cameras[1];
      projectLogger.fine(_selectedCamera);
      _startCameraController(_selectedCamera).then((value) {
        if (mounted && value != null) {
          setState(() {
            cameraController = value;
          });
        }
      });
    }
    // tie together the 'camera images acquirement' to the 'image processing'
    _cameraImageStreamSubscription = _cameraImageStreamController.stream
        .where((cameraImage) {
          final isZero = _imageCounterFilter.current == 0;
          _imageCounterFilter.tick();
          return isZero ? true : false;
        })
        .listen((cameraImage) {
      widget.useCase.onNewCameraImage(
        cameraImage,
        cameraController!.description.sensorOrientation,
      );
    });
  }

  @override
  void dispose() {
    _cameraImageStreamSubscription?.cancel();
    _cameraImageStreamController.close();
    _disposeCameraController(cameraController);
    cameraController = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = cameraController;
    if (controller == null) {
      return const Center(
      );
    }
    // what need to be visible
    final widgets = <Widget>[];
    widgets.add(CameraPreview(
      controller,
      child: const Icon(
        Icons.arrow_upward,
      ),
    ));
    widgets.add(Expanded(
      child: ListView.builder(
        itemCount: facesPhotos.length,
        itemBuilder: (context, index) => Image.memory(facesPhotos[index]),
        scrollDirection: Axis.horizontal,
      ),
    ));

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: widgets,
      ),
    );
  }

  void _disposeCameraController(CameraController? controller) async {
    if (controller == null) {
      return;
    }

    if (controller.value.isStreamingImages) {
      await controller.stopImageStream();
    }
    await controller.dispose();
    projectLogger.fine('camera controller disposed.');
  }

  Future<CameraController?> _startCameraController(CameraDescription description) async {
    final controller = CameraController(
      description,
      // FIXME - as per documentation resolution limited due streaming and
      // running the preview widget
      ResolutionPreset.low,
      // NOTE - let it fallback to platform's default to be able to stream
      imageFormatGroup: null,
      enableAudio: false,
    );

    try {
      await controller.initialize();
      // create a stream of camera images
      await controller.startImageStream(
        (image) => _cameraImageStreamController.add(image),
      );
      return controller;
    }
    on CameraException catch (e) {
      projectLogger.severe('cameraController could not be initialized');
      cameraController = null;

      switch (e.code) {
        case 'CameraAccessDenied':
          projectLogger.severe('You have denied camera access.');
          break;
        // iOS only
        case 'CameraAccessDeniedWithoutPrompt':
          projectLogger
              .severe('Please go to Settings app to enable camera access.');
          break;
        // iOS only
        case 'CameraAccessRestricted':
          projectLogger.severe('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          projectLogger.severe('You have denied audio access.');
          break;
        // iOS only
        case 'AudioAccessDeniedWithoutPrompt':
          projectLogger
              .severe('Please go to Settings app to enable audio access.');
          break;
        // iOS only
        case 'AudioAccessRestricted':
          projectLogger.severe('Audio access is restricted.');
          break;
        default:
          projectLogger.shout('Unknow CameraException code', e);
      }
    }
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // LINK - https://docs.flutter.dev/get-started/flutter-for/android-devs#how-do-i-listen-to-android-activity-lifecycle-events
    // LINK - https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html
    projectLogger.fine('#camera_view #app_changed_state #$state');

    // SECTION - manage camera resources.
    final controller = cameraController;

    // // nothing to manage or controller not initialized
    // if (controller == null || !controller.value.isInitialized) {
    //   return;
    // }

    switch (state) {
      // start the camera controller
      case AppLifecycleState.resumed: // visible and focused
        _startCameraController(_selectedCamera).then((value) {
          projectLogger.fine('camera controller $value');
          if (mounted && value != null) {
            setState(() {
              cameraController = value;
            });
          }
        });
        break;
      // stop the camera controller
      // visible (or obscured by a system view) and not focused
      case AppLifecycleState.inactive:
      // not visible and not focused
      case AppLifecycleState.paused:
      //
      case AppLifecycleState.detached:
        _disposeCameraController(controller);
        cameraController = null;
        break;
      default:
        null;
    }
    // !SECTION
  }

  // when there is a change on cameraController.value
  void onCameraControllerValueChange() {
    projectLogger.fine('#camera_controller #value_changed ${cameraController?.value}');
    final controller = cameraController;

    if (mounted) {
      setState(() {});
    }
    if (controller != null && controller.value.hasError) {
      projectLogger
          .severe('Camera error: ${controller.value.errorDescription}');
    }
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
