import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

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