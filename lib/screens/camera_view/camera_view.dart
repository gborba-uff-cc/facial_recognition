import 'dart:async';

import 'package:camera/camera.dart';
import 'package:facial_recognition/domain.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
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
  final List<Uint8List> facesPhotos = [];

  bool _finishedProcessingImage = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.cameras.isNotEmpty) {
      updateCameraController(widget.cameras[1]);
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

  Future<void> updateCameraController(CameraDescription description) {
    _disposeCameraController(cameraController);
    return startCameraController(description);
  }

  Future<void> startCameraController(CameraDescription description) async {
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
      controller.initialize().then(
        (_) async {
          projectLogger.fine('cameraController inicializado');
          controller.startImageStream( (image) async {
            if (_finishedProcessingImage) {
              _finishedProcessingImage = false;
              await onCameraImageAvailable(
                image,
                controller.description.sensorOrientation,
              );
              _finishedProcessingImage = true;
            }},
          );
        },
      );
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
    }
    finally {
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
      _disposeCameraController(controller);
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

  Future<void> onCameraImageAvailable(
    CameraImage image,
    int controllerSensorOrientation,
  ) async {

    final inImage = toInputImage(image, controllerSensorOrientation);
    if (inImage == null) {
      return;
    }

    final faces = await detectFaces(inImage);
    if (faces.isEmpty) {
      return;
    }

    final asRgb = yCbCr420ToRgb(width: image.width, height: image.height, planes: image.planes,);
    final asLogicalImage = toLogicalImage(width: image.width, height: image.height, rgbBytes: asRgb,);

    // detach faces into manipulable images
    final logicalImages = cropImage(asLogicalImage, faces.map((e) => e.boundingBox).toList(),);
    final List<Uint8List> newFaces = [];

    // samples to generate features sets
    final List<List<List<List<double>>>> samples = [];
    for (final i in logicalImages) {
      final jpeg = await convertToJpg(i);

      final resizedImage = resizeImage(i, 160, 160);
      final stdImage = standardizeImage(resizedImage.buffer.asUint8List(), resizedImage.width, resizedImage.height);

      newFaces.add(jpeg);
      final stdImageMatrix = rgbListToMatrix(stdImage, resizedImage.width, resizedImage.height);
      samples.add(stdImageMatrix);
    }

    // update detected faces preview
    if (mounted) {
      setState(() {
        facesPhotos.addAll(newFaces);
      });
    }

    // generate faces embedding
    List<FaceEmbedding> facesEmbedding = await extractFaceEmbedding(samples);
    for (final fe in facesEmbedding) {
      projectLogger.fine(fe.take(10));
    }

    final subject = Subject(code: 'TestingSubject', name: 'testing');
    final individual = Individual(individualRegistration: 'individual01', name: 'TesteingIndividualName');
    final teacher = Teacher(registration: 'teacher01', individual: individual);
    final subjectClass = SubjectClass(subject: subject, year: 2024, semester: 01, name: 'TestingSubjectClass', teacher: teacher);
    final lesson = Lesson(subjectClass: subjectClass, utcDateTime: DateTime(2024,01,01,07), teacher: teacher);

    // retrieve all students in this class that have facial data added
    final facialDataByStudent = getFacialDataFromSubjectClass(subjectClass);
    Map<FaceEmbedding, List<FacialDataDistance>> searchResult = {};
    bool couldSearch = true;
    try {
      searchResult = getFacialDataDistance(facesEmbedding, facialDataByStudent);
    }
    on CouldntSearchException {
      couldSearch = false;
    }

    // handle later if it was not possible to retrieve the students
    if (!couldSearch) {
      deferAttendance(facesEmbedding, lesson);
      return;
    }

    //
    final List<FacialDataDistance> recognized = [];
    final Map<FaceEmbedding, FacialDataDistance?> notRecognized = {};
    for (final entry in searchResult.entries) {
      final List<FacialDataDistance> result = entry.value;

      if (result.isEmpty) {
        notRecognized.addAll({entry.key: null});
        projectLogger.info(
          'This subject class has no student with facial data registered'
        );
      }
      else {
        result.sort((e1, e2) => e1.distance.compareTo(e2.distance));
        final nearestFacialData = result.first;
        if (nearestFacialData.distance < recognitionDistanceThreshold) {
          recognized.add(nearestFacialData);
        }
        else {
          notRecognized.addAll({entry.key: result.first});
        }
      }
    }

    if (recognized.isNotEmpty) {
      for (var fdd in recognized) {
        projectLogger.fine('${fdd.distance} is the actual distance to ${fdd.student.individual.name}');
      }
      writeStudentAttendance(
        recognized.map((r) => r.student),
        lesson,
      );
    }
    // dismiss not recognized faces or ask to update known facial data for student
    if (notRecognized.isNotEmpty) {
      faceNotRecognized(notRecognized, subjectClass);
    }
  }
}
