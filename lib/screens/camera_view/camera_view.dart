import 'package:camera/camera.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraView({super.key, this.cameras = const []});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  // NOTE - a new controller is needed after a dispose (dispose can be called
  // more than once), so...
  //  create controller on: initState, app is resumed, change camera source
  //  delete controller on: dispose, app is inactive, change camera source
  CameraController? cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.cameras.isNotEmpty) {
      updateCameraController(widget.cameras[0]);
    }
    // NOTE - camera controller initialized on didChangeAppLifecycleState
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = cameraController;
    return Scaffold(
      appBar: AppBar(),
      body: controller == null
          ? const Center(
              child: Text('Couldn\'t find a camera controller.'),
            )
          : Center(
              child: CameraPreview(
                controller,
                child: const Icon(
                  Icons.arrow_upward,
                ),
              ),
            ),
    );
  }

  Future<void> updateCameraController(CameraDescription description) {
    cameraController?.dispose();
    return startCameraController(description);
  }

  Future<void> startCameraController(CameraDescription description) async {
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      imageFormatGroup: ImageFormatGroup.jpeg,
      enableAudio: false,
    );

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          projectLogger.severe('You have denied camera access.');
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          projectLogger
              .severe('Please go to Settings app to enable camera access.');
          break;
        case 'CameraAccessRestricted':
          // iOS only
          projectLogger.severe('Camera access is restricted.');
          break;
        case 'AudioAccessDenied':
          projectLogger.severe('You have denied audio access.');
          break;
        case 'AudioAccessDeniedWithoutPrompt':
          // iOS only
          projectLogger
              .severe('Please go to Settings app to enable audio access.');
          break;
        case 'AudioAccessRestricted':
          // iOS only
          projectLogger.severe('Audio access is restricted.');
          break;
        default:
          projectLogger.shout('Unknow CameraException code', e);
          break;
      }
    } finally {
      controller.addListener(() {
        onCameraControllerValueChange();
      });
      cameraController = controller;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // LINK - https://docs.flutter.dev/get-started/flutter-for/android-devs#how-do-i-listen-to-android-activity-lifecycle-events
    // LINK - https://api.flutter.dev/flutter/dart-ui/AppLifecycleState.html
    projectLogger.fine('#camera_view #app_changed_state #$state');

    // SECTION - manage camera resources.
    final controller = cameraController;

    // nothing to manage or controller not initialized
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.removeListener(onCameraControllerValueChange);
      controller.dispose();
    }
    else if (state == AppLifecycleState.resumed) {
      updateCameraController(controller.description);
    }
    // !SECTION

    super.didChangeAppLifecycleState(state);
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
