import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class GoogleFaceDetector
    implements IFaceDetector<CameraImage> {
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
  Future<List<Rect>> detect (
    final CameraImage image,
    [final int controllerSensorOrientation = 0]
  ) async {
    try {
      final input = _toInputImage(image, controllerSensorOrientation);
      final faces = await _detector.processImage(input);

      return faces
          .map(
            (e) => e.boundingBox,
          )
          .toList(growable: false);
    }
    catch (e) {
      projectLogger.severe(e);
    }

    return Future.value(
      List.empty(growable: false),
    );
  }

  /// Convert a [image] from camera to an image used by the Google ML Kit
  InputImage _toInputImage(CameraImage image, int controllerSensorOrientation) {
    final imageRotation =
        InputImageRotationValue.fromRawValue(controllerSensorOrientation);
    if (imageRotation == null) {
      throw Exception("Couldn't identify the sensor orientation value");
    }

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw);
    if (inputImageFormat == null) {
      throw Exception("Couldn't identify the image format type");
    }

    final planeData = image.planes
        .map(
          (Plane plane) => InputImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          ),
        )
        .toList(growable: false);

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );

    final bytes = Uint8List(
      image.planes.fold(
        0,
        (previousValue, plane) => previousValue + plane.bytes.length,
      ),
    );
    int start = 0;
    for (final plane in image.planes) {
      int end = start + plane.bytes.length;
      bytes.setRange(start, end, plane.bytes);
      start = end;
    }

    return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
  }
}
