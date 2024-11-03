import 'dart:async';
import 'dart:collection';
// import 'dart:math';

// import 'package:camera_app/utils/mlkit_utils.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/utils/project_logger.dart';
// import 'package:facial_recognition/use_case/camera_identification.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
// import 'package:rxdart/rxdart.dart';

// made out of a camerawesome example (camerawesome-2.1.0/example/lib/ai_analysis_faces.dart)

enum _IdentificationMode {
  automatic,
  manual,
}

class CameraIdentificationHandheldScreen extends StatefulWidget {
  const CameraIdentificationHandheldScreen({
    super.key,
    required this.useCase,
  });

  // final CameraIdentification useCase;
  final ICameraAttendance<AnalysisImage, JpegPictureBytes> useCase;

  @override
  State<CameraIdentificationHandheldScreen> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraIdentificationHandheldScreen> {
  // final _faceDetectionController = BehaviorSubject<FaceDetectionModel>();
  final List _detectedFaces = [];
  _IdentificationMode _identificationMode = _IdentificationMode.manual;
  bool _shouldCaptureImage = false;
  bool _isHandlingImage = false;
  final _jpgToShowController = StreamController<JpegPictureBytes>.broadcast();

  @override
  void initState() {
    super.initState();
    widget.useCase.onDetectionResult = (jpegImages) async {
      jpegImages.map((e) => e.face).forEach(_jpgToShowController.add);
      // if (mounted) {
      //   setState(() => _detectedFaces.addAll(jpegImages));
      // }
    };
  }

  @override
  void dispose() {
    _detectedFaces.clear();
    _jpgToShowController.close();
    // _faceDetectionController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraAwesomeBuilder.previewOnly(
        previewFit: CameraPreviewFit.contain,
        sensorConfig: SensorConfig.single(
          sensor: Sensor.position(SensorPosition.back),
          aspectRatio: CameraAspectRatios.ratio_1_1,
        ),
        onImageForAnalysis: _handleAnalysisImage,
        // image analysis default use nv21 for android and bgra for ios
        // (width configuration not working for some reason)
        imageAnalysisConfig: AnalysisConfig(maxFramesPerSecond: 1),
        builder: (state, preview) {
          return SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _TopPreviewDecorator(
                      jpgStream: _jpgToShowController.stream,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox.shrink(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            switch (_identificationMode) {
                              _IdentificationMode.manual => FilledButton.tonal(
                                  onPressed: () => setState(() =>
                                      _identificationMode = _IdentificationMode.automatic),
                                  child: const Text('Auto'),
                                ),
                              _IdentificationMode.automatic => FilledButton(
                                  onPressed: () => setState(() =>
                                      _identificationMode = _IdentificationMode.manual),
                                  child: const Text('Auto'),
                                ),
                            },
                            AppDefaultCameraShutter(
                              onTap: () => _shouldCaptureImage = true,
                            ),
                            AppDefaultCameraSwitcher(
                              onTap: state.switchCameraSensor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleAnalysisImage(AnalysisImage image) {
    if (_isHandlingImage) {
      return Future.value();
    }
    if (_identificationMode == _IdentificationMode.manual && !_shouldCaptureImage) {
      return Future.value();
    }
    _isHandlingImage = true;
    _shouldCaptureImage = false;
    // run asyncronously
    Future(() => widget.useCase.onNewCameraInput(image))
        .then((value) => _isHandlingImage = false);
    return Future.value();
  }

/*   Future _analyzeImage(AnalysisImage img) async {
    final inputImage = img.toInputImage();

    try {
      _faceDetectionController.add(
        FaceDetectionModel(
          faces: await faceDetector.processImage(inputImage),
          absoluteImageSize: inputImage.metadata!.size,
          rotation: 0,
          imageRotation: img.inputImageRotation,
          img: img,
        ),
      );
      // debugPrint("...sending image resulted with : ${faces?.length} faces");
    } catch (error) {
      debugPrint("...sending image resulted error $error");
    }
  } */
}
class _TopPreviewDecorator extends StatefulWidget {
  final Stream<JpegPictureBytes> jpgStream;
  const _TopPreviewDecorator({
    super.key,
    required this.jpgStream,
  });

  @override
  State<_TopPreviewDecorator> createState() => _TopPreviewDecoratorState();
}

class _TopPreviewDecoratorState extends State<_TopPreviewDecorator> {
  StreamSubscription<JpegPictureBytes>? jpgSubscription;
  final Queue<JpegPictureBytes> jpgsToShow = Queue();
  final Duration timeUntilRemove = Duration(milliseconds: 2000);

  @override
  void didUpdateWidget(covariant _TopPreviewDecorator oldWidget) {
    super.didUpdateWidget(oldWidget);
    jpgSubscription?.cancel();
    _startRecievingFromStream();
  }

  @override
  void initState() {
    super.initState();
    _startRecievingFromStream();
  }

  @override
  void dispose() {
    jpgSubscription?.cancel();
    super.dispose();
  }

  void _startRecievingFromStream() {
    jpgSubscription = widget.jpgStream.listen((event) {
      if (mounted) {
        setState(() {
          jpgsToShow.addFirst(event);
        });
        if (jpgsToShow.length > 5) {
          Future.delayed(timeUntilRemove, () {
            if (mounted) {
              setState(() {
                jpgsToShow.removeLast();
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = 100.0;
    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: SizedBox.square(
            dimension: height,
            child: Image.memory(
              jpgsToShow.elementAt(index),
            ),
          ),
        ),
        itemCount: jpgsToShow.length,
      ),
    );
  }
}
