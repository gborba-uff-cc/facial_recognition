import 'dart:typed_data';
import 'dart:ui';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class GoogleFaceDetector
    implements IFaceDetector {
  final FaceDetector _detector;

  ///
  GoogleFaceDetector() : _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  ///
  void close() {
    _detector.close();
  }

  ///
  @override
  Future<List<Rect>> detect ({
    required final Uint8List bgraBuffer,
    required final width,
    required final height,
    final int imageRollDegree = 0,
    required final int bytesRowStride,
  }) async {
    try {
      final input = _toInputImage(
        bgraBuffer: bgraBuffer,
        width: width,
        height: height,
        bytesRowStride: bytesRowStride
      );
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

  /// Convert a [bgraBuffer] from camera to an image used by the Google ML Kit
  InputImage _toInputImage({
    required final Uint8List bgraBuffer,
    required final int width,
    required final int height,
    final int imageRollDegree = 0,
    required final int bytesRowStride,
  }) {
    final imageRotation =
        InputImageRotationValue.fromRawValue(imageRollDegree);
    if (imageRotation == null) {
      throw Exception("Couldn't identify the sensor orientation value");
    }

    final inputImageFormat =
        InputImageFormat.bgra8888;

    final imageSize = Size(width.toDouble(), height.toDouble());
    final inputImageData = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: bytesRowStride,
    );

    return InputImage.fromBytes(metadata: inputImageData, bytes: bgraBuffer,);
  }
}
