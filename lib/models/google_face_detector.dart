import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../utils/project_logger.dart';
import '../interfaces.dart';

class GoogleFaceDetector
    implements IFaceDetector<CameraImage, CameraDescription> {
  final FaceDetector _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  ///
  GoogleFaceDetector();

  ///
  void close() {
    _detector.close();
  }

  ///
  @override
  Future<List<Rect>> detect(CameraImage image, CameraDescription description) {
    try {
      final input = _toInputImage(image, description);
      final faces = _detector.processImage(input);
      final rects = faces.then(
        (list) => list
            .map(
              (e) => e.boundingBox,
            )
            .toList(growable: false),
      );
      return rects;
    } catch (e) {
      projectLogger.severe(e);
    }
    return Future.value([]);
  }

  ///
  InputImage _toInputImage(CameraImage image, CameraDescription description) {
    final imageRotation =
        InputImageRotationValue.fromRawValue(description.sensorOrientation);
    if (imageRotation == null) {
      throw Exception("Couldn't identify the image rotation value");
    }

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) {
      throw Exception("Couldn't identify the image format type");
    }

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final planeData = image.planes
        .map(
          (Plane plane) => InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          ),
        )
        .toList(growable: false);
    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );
    var nBytes = 0;
    final Uint8List bytes = Uint8List(nBytes);
    for (final plane in image.planes) {
      nBytes += plane.bytes.length;
    }
    for (final plane in image.planes) {
      bytes.addAll(plane.bytes);
    }

    return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }
}
