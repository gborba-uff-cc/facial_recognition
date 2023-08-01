import 'dart:async';

import 'package:camera/camera.dart';
import 'package:facial_recognition/domain.dart';
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
          controller.addListener(onCameraControllerValueChange);
          Timer(const Duration(seconds: 1), () {
            controller.startImageStream( (image) {
              // TODO - control the frequency to call the image processing
              controller.stopImageStream();
              onCameraImageAvailable(image);
            });
          });
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

  void onCameraImageAvailable(CameraImage image) async {
    projectLogger.fine('#CameraImage #available');

    final controller = cameraController;
    if (controller == null) {
      return;
    }

    projectLogger.fine('Converting CameraImage to InputImage');
    final inImage = toInputImage(image, controller);
    if (inImage == null) {
      return;
    }
    projectLogger.fine('Detecting faces');

    final faces = await detectFaces(inImage);
    final asRgb = yCbCr420ToRgb(width: image.width, height: image.height, planes: image.planes,);
    final asLogicalImage = toLogicalImage(width: image.width, height: image.height, rgbBytes: asRgb,);

    // see the whole image
    final jpeg = await convertToJpg(asLogicalImage);
    facesPhotos.add(jpeg);

    // detach faces
    final logicalImages = cropImage(asLogicalImage, faces.map((e) => e.boundingBox).toList(),);
    final List<Uint8List> newFaces = [];

    // samples to generate features sets
    final List<List<List<List<double>>>> samples = [];
    for (final i in logicalImages) {
      final jpeg = await convertToJpg(i);
      projectLogger.fine('i (w,h)=(${i.width},${i.height}) format=${i.format.name} channels=${i.numChannels} len=${i.length} nBytes=${i.buffer.lengthInBytes}');

      final resizedImage = resizeImage(i, 160, 160);
      final stdImage = standardizeImage(resizedImage.buffer.asUint8List(), resizedImage.width, resizedImage.height);
      projectLogger.fine('resizedImage (w,h)=(${resizedImage.width},${resizedImage.height}) format=${resizedImage.format.name} channels=${resizedImage.numChannels} len=${resizedImage.length} nBytes=${resizedImage.buffer.lengthInBytes}');

      newFaces.add(jpeg);
      samples.add(rgbListToMatrix(stdImage, resizedImage.width, resizedImage.height));
    }

    setState(() {
      facesPhotos.addAll(newFaces);
    });

    final features = [for (final s in samples) await extractFaceEmbedding(s)];
    for (var f in features) {
      final d = featuresDistance(f, f);
      projectLogger.info('#feature_distance $d');
    }
  }
}
