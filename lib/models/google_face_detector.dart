import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:camera/camera.dart' as pkg_camera;

class GoogleFaceDetector
    implements IFaceDetector<pkg_camera.CameraImage, pkg_camera.CameraController> {
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
  Future<List<Rect>> detect({
    required final pkg_camera.CameraImage cameraImage,
    required final pkg_camera.CameraController cameraController,
  }) async {
    try {
      final input = _toInputImage(
        image: cameraImage,
        controller: cameraController,
      );
      if (input == null) {
        return const [];
      }
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

  /// Convert a [cameraImage] to an input image used by the Google ML Kit
  // LINK - https://github.com/flutter-ml/google_ml_kit_flutter/blob/master/packages/google_mlkit_commons/README.md#usage
  InputImage? _toInputImage({
    required final pkg_camera.CameraImage image,
    required final pkg_camera.CameraController controller,
  }) {
    const compensations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };

    final deviceOrientation = controller.value.deviceOrientation;
    final sensorOrientation = controller.description.sensorOrientation;
    final lensDirection = controller.description.lensDirection;
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    else if (Platform.isAndroid) {
      var rotationCompensation = compensations[deviceOrientation];
      if (rotationCompensation == null) {
        return null;
      }
      if (lensDirection == pkg_camera.CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) {
      return null;
    }

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format because it is platform dependent:
    switch (format) {  // switch is for the exaustive comparisson
      case null:
        return null;
      case InputImageFormat.yuv_420_888:
      case InputImageFormat.nv21:
      case InputImageFormat.yv12:
        if (!Platform.isAndroid) {
          return null;
        }
        break;
      case InputImageFormat.bgra8888:
      case InputImageFormat.yuv420:
        if (!Platform.isIOS) {
          return null;
        }
        break;
    }

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) {
      return null;
    }
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }
}
