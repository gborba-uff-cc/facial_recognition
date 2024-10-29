import 'dart:async';
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

  @override
  void initState() {
    super.initState();
    widget.useCase.onDetectionResult = (jpegImages) async {
      if (mounted) {
        setState(() => _detectedFaces.addAll(jpegImages));
      }
    };
  }

  @override
  void dispose() {
    _detectedFaces.clear();
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
        imageAnalysisConfig: AnalysisConfig(maxFramesPerSecond: 2),
        builder: (state, preview) {
          return Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [],),
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

class _MyPreviewDecoratorWidget extends StatelessWidget {
  final CameraState cameraState;
  final Stream<_FaceDetectionModel> faceDetectionStream;
  final Preview preview;

  const _MyPreviewDecoratorWidget({
    required this.cameraState,
    required this.faceDetectionStream,
    required this.preview,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: StreamBuilder(
        stream: cameraState.sensorConfig$,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const SizedBox();
          } else {
            return StreamBuilder<_FaceDetectionModel>(
              stream: faceDetectionStream,
              builder: (_, faceModelSnapshot) {
                if (!faceModelSnapshot.hasData) return const SizedBox();
                // this is the transformation needed to convert the image to the preview
                // Android mirrors the preview but the analysis image is not
                final canvasTransformation = faceModelSnapshot.data!.img
                    ?.getCanvasTransformation(preview);
                return CustomPaint(
                  painter: _FaceDetectorPainter(
                    model: faceModelSnapshot.requireData,
                    canvasTransformation: canvasTransformation,
                    preview: preview,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class _FaceDetectorPainter extends CustomPainter {
  final _FaceDetectionModel model;
  final CanvasTransformation? canvasTransformation;
  final Preview? preview;

  _FaceDetectorPainter({
    required this.model,
    this.canvasTransformation,
    this.preview,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (preview == null || model.img == null) {
      return;
    }
    // We apply the canvas transformation to the canvas so that the barcode
    // rect is drawn in the correct orientation. (Android only)
    if (canvasTransformation != null) {
      canvas.save();
      canvas.applyTransformation(canvasTransformation!, size);
    }
    for (final Face face in model.faces) {
      final faceBB = face.boundingBox;
      final previewRect = Rect.fromPoints(
        preview!.convertFromImage(faceBB.topLeft, model.img!),
        preview!.convertFromImage(faceBB.bottomRight, model.img!),
      );
      final scaledBB = Rect.fromLTWH(previewRect.left, previewRect.top*0.9, previewRect.width, previewRect.height*1.2);
      canvas.drawRect(scaledBB, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0);
    }
    // if you want to draw without canvas transformation, use this:
    if (canvasTransformation != null) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FaceDetectorPainter oldDelegate) {
    return oldDelegate.model != model;
  }
}

/* extension InputImageRotationConversion on InputImageRotation {
  double toRadians() {
    final degrees = toDegrees();
    return degrees * 2 * pi / 360;
  }

  int toDegrees() {
    switch (this) {
      case InputImageRotation.rotation0deg:
        return 0;
      case InputImageRotation.rotation90deg:
        return 90;
      case InputImageRotation.rotation180deg:
        return 180;
      case InputImageRotation.rotation270deg:
        return 270;
    }
  }
} */

class _FaceDetectionModel {
  final List<Face> faces;
  final Size absoluteImageSize;
  final int rotation;
  final InputImageRotation imageRotation;
  final AnalysisImage? img;

  _FaceDetectionModel({
    required this.faces,
    required this.absoluteImageSize,
    required this.rotation,
    required this.imageRotation,
    this.img,
  });

  Size get croppedSize => img!.croppedSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FaceDetectionModel &&
          runtimeType == other.runtimeType &&
          faces == other.faces &&
          absoluteImageSize == other.absoluteImageSize &&
          rotation == other.rotation &&
          imageRotation == other.imageRotation &&
          croppedSize == other.croppedSize;

  @override
  int get hashCode =>
      faces.hashCode ^
      absoluteImageSize.hashCode ^
      rotation.hashCode ^
      imageRotation.hashCode ^
      croppedSize.hashCode;
}
