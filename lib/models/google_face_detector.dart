import 'dart:io';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/* class GoogleFaceDetector
    implements IFaceDetector<PackageCameraMethodsInput> {
  final FaceDetector _detector;

  GoogleFaceDetector()
      : _detector = FaceDetector(
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
  Future<List<Rect>> detect(
    final GoogleFaceDetectorInputType input,
  ) async {
    try {
      final inputImage = _toInputImage(
        image: input.image,
        controller: input.controller,
      );
      if (inputImage == null) {
        return const [];
      }
      final faces = await _detector.processImage(inputImage);

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
    // validate format because it is platform dependent;
    // (using switch for the exaustive comparison)
    switch (format) {
      case null:
        return null;
      case InputImageFormat.yuv_420_888:
      case InputImageFormat.nv21:
        if (!Platform.isAndroid) {
          return null;
        }
        break;
      case InputImageFormat.bgra8888:
        if (!Platform.isIOS) {
          return null;
        }
        break;
      case InputImageFormat.yv12:
      case InputImageFormat.yuv420:
        projectLogger
            .info('[GoogleFaceDetector] input image format not supported');
        return null;
    }

    Uint8List? bytes;
    InputImageMetadata? metadata;
    switch (format) {
      case InputImageFormat.yuv_420_888:
        final planes = image.planes;
        if (planes.length != 3) {
          bytes = null;
          metadata = null;
        }
        else {
          int nBytes = 0;
          for (final plane in image.planes) {
            nBytes += plane.bytes.length;
          }
          assert (nBytes == 3*planes.first.bytes.length);

          final flat = <int>[];
          for (final plane in image.planes) {
            flat.addAll(plane.bytes);
          }
          bytes = Uint8List.fromList(flat);
          metadata = InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation, // used only in Android
            format: format,     // used only in iOS
            bytesPerRow: planes.first.bytesPerRow,  // used only in iOS
          );
        }
        break;
      case InputImageFormat.nv21:
      case InputImageFormat.bgra8888:
        final plane = image.planes.singleOrNull;
        if (plane == null) {
          bytes = null;
          metadata = null;
        }
        else {
          bytes = plane.bytes;
          metadata = InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation: rotation, // used only in Android
            format: format,     // used only in iOS
            bytesPerRow: plane.bytesPerRow, // used only in iOS
          );
        }
        break;
      default:
        return null;
    }
    if (bytes == null || metadata == null) {
      return null;
    }
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }
} */

class GoogleFaceDetectorForCamerawesome implements
    IFaceDetector<pkg_awesome.AnalysisImage>
{
  final FaceDetector _detector;

  GoogleFaceDetectorForCamerawesome()
      : _detector = FaceDetector(
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
  Future<List<Rect>> detect(
    final pkg_awesome.AnalysisImage input,
  ) async {
    final inputImage = input.when(
      bgra8888: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            size: image.size,
            rotation: InputImageRotation.values.byName(image.rotation.name),
            format: InputImageFormat.bgra8888,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      },
      nv21: (image) {
        return InputImage.fromBytes(
          bytes: image.bytes,
          metadata: InputImageMetadata(
            size: image.size,
            rotation: InputImageRotation.values.byName(image.rotation.name),
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
      },
      yuv420: (image) {
        projectLogger
            .info('yuv420 input not implemented for face detection');
        return null;
/*         // final planes = image.planes;
        // int nBytes = 0;
        // for (final plane in image.planes) {
        //   nBytes += plane.bytes.length;
        // }
        // assert (nBytes == 3*image.planes.first.bytes.length);

        final flat = <int>[];
        for (final plane in image.planes) {
          flat.addAll(plane.bytes);
        }
        final bytes = Uint8List.fromList(flat);
        final metadata = InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.values.byName(image.rotation.name),
          format: InputImageFormat.yuv_420_888,
          bytesPerRow: image.planes.first.bytesPerRow,
        );
        return InputImage.fromBytes(bytes: bytes, metadata: metadata); */
      },
    );
    if (inputImage == null) {
      return Future.value(const []);
    }
    final detection = await _detector.processImage(inputImage);
    final rects = List<Rect>.unmodifiable(
      detection.map<Rect>((e) => e.boundingBox),
    );
    projectLogger.info('detected faces: ${rects.length}');
    return Future.value(rects);
  }
}

/*
...
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
...
  if (Platform.isAndroid) {
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
...
  case InputImageFormat.yuv_420_888:
    final planes = image.planes;
    if (planes.length != 3) {
      bytes = null;
      metadata = null;
    }
    else {
      int nBytes = 0;
      for (final plane in image.planes) {
        nBytes += plane.bytes.length;
      }
      assert (nBytes == 3*planes.first.bytes.length);

      final flat = <int>[];
      for (final plane in image.planes) {
        flat.addAll(plane.bytes);
      }
      bytes = Uint8List.fromList(flat);
      metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format,     // used only in iOS
        bytesPerRow: planes.first.bytesPerRow,  // used only in iOS
      );
    }
...
*/