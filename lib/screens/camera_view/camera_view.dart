import 'dart:async';

import 'package:camera/camera.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/facenet_face_recognizer.dart';
import 'package:facial_recognition/models/google_face_detector.dart';
import 'package:facial_recognition/models/image_handler.dart';
import 'package:facial_recognition/use_case/camera_attendance.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {

  factory CameraView({key, cameras = const []}) {
    final subject = Subject(code: 'TestingSubject', name: 'testing');
    final individual = Individual(individualRegistration: 'individual01', name: 'TesteingIndividualName');
    final teacher = Teacher(registration: 'teacher01', individual: individual);
    final subjectClass = SubjectClass(subject: subject, year: 2024, semester: 01, name: 'TestingSubjectClass', teacher: teacher);
    final lesson = Lesson(subjectClass: subjectClass, utcDateTime: DateTime(2024,01,01,07), teacher: teacher);

    final useCase = CameraAttendance(
      GoogleFaceDetector(),
      ImageHandler(),
      FacenetFaceRecognizer(),
      DomainRepository(),
      (jpegImages) {},
      lesson,
    );

    return CameraView._private(useCase: useCase, cameras: cameras);
  }

  const CameraView._private({
    super.key,
    required useCase,
    required this.cameras,
  }) : _useCase = useCase;

  final CameraAttendance _useCase;
  final List<CameraDescription> cameras;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  // NOTE - a new controller is needed after a dispose (dispose can be called
  // more than once), so...
  //  create controller on: initState, app is resumed, change camera source
  //  delete controller on: dispose, app is inactive, change camera source
  CameraController? cameraController;
  final List<Uint8List> facesPhotos = [];
  bool _finishedProcessingImage = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget._useCase.showFaceImages = (jpegImages) {
      if (mounted) {
        setState(() {
          facesPhotos.addAll(jpegImages);
        });
      }
    };
    if (widget.cameras.isNotEmpty) {
      _updateCameraController(widget.cameras[1]);
    }
    // NOTE - camera controller initialized on didChangeAppLifecycleState
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCameraController(cameraController);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = cameraController;
    if (controller == null) {
      return const Center(
        child: Text('Couldn\'t find a camera controller.'),
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

  Future<void> _updateCameraController(CameraDescription description) async {
    await _disposeCameraController(cameraController);
    await _startCameraController(description);
    return;
  }

  Future<void> _disposeCameraController(CameraController? controller) {
    if (controller == null) {
      return Future.value(null);
    }
    return Future(() {
      controller.removeListener(onCameraControllerValueChange);
      if (controller.value.isStreamingImages) {
        return controller.stopImageStream();
      }
      return null;
    }).then((_) => controller.dispose());
  }

  Future<void> _startCameraController(CameraDescription description) async {
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
      await controller.startImageStream(
        (image) async {
          if (!_finishedProcessingImage) {
            return;
          }

          _finishedProcessingImage = false;
          await widget._useCase.onNewCameraImage(
            image,
            controller.description.sensorOrientation,
          );
          _finishedProcessingImage = true;
        },
      );
      cameraController = controller;

      projectLogger.fine('cameraController initialized');
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
      _disposeCameraController(controller);
    }
    else if (state == AppLifecycleState.resumed) {
      _updateCameraController(controller.description);
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

  @override
  void didUpdateWidget(covariant CameraView oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }
}
