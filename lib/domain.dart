import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// main use case for the app
// // FIXME - provide the missing components
// int useCaseRecognizeFaces({image}) {

//   const minimumFaceConfidence = 97.0;
//   const minimumResultConfidence = 97.0;

//   final faces = detectFaces(image);

//   for (var face in faces) {
//     if (face.confidence * 100.0 < minimumFaceConfidence) {
//       return -1;
//     }

//     final List<int> boundingBox = List.unmodifiable([0,0,0,0]);

//     final faceImage = resizeImage(cropImage(image, boundingBox), 160, 160);

//     final embedding = newEmbedding(faceImage);

//     final result = searchFace();
//     if (result.confidence * 100.0 < minimumResultConfidence) {
//       return -1;
//     }
//   }
//   return 0;
// }

/// Detect any faces on [image].
Future<List<Face>> detectFaces(InputImage image) {
  final detector = FaceDetector(
    options: FaceDetectorOptions(),
  );

  return detector.processImage(image);
}

// /// Return a subarea from [image]
// void cropImage(image, final List<int> boundingBox) {  // FIXME - method signature.
//   // TODO - .
//   return;
// }

// /// Resize the *image* to match [size]
// void resizeImage(image, width, height) {  // FIXME - method signature.
//   // TODO - .
//   return;
// }

// /// Create recognition data for the only face on [image]
// void newEmbedding(image) {  // FIXME - method signature.
//   // TODO - .
//   return;
// }

// /// Search for a matching person that corresponds to [embedding]
// void searchFace(embedding) {  // FIXME - method signature.
//   // TODO - .
//   return;
// }

// HELPER ------
InputImage? toInputImage(CameraImage image, CameraController controller) {
  final imageRotation = InputImageRotationValue.fromRawValue(
      controller.description.sensorOrientation);
  if (imageRotation == null) {
    projectLogger.severe("Couldn't identify the image rotation value");
    return null;
  }

  final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
  if (inputImageFormat == null) {
    projectLogger.severe("Couldn't identify the image format type");
    return null;
  }

  final WriteBuffer allPlanesCopy = WriteBuffer(
      startCapacity: image.planes
          .map((Plane plane) => plane.bytes.length)
          .reduce((value, element) => value + element));
  for (final plane in image.planes) {
    allPlanesCopy.putUint8List(plane.bytes);
  }
  final bytes = allPlanesCopy.done().buffer.asUint8List();

  final imageSize = Size(image.width.toDouble(), image.height.toDouble());

  final planeData = image.planes
      .map(
        (Plane plane) => InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        ),
      )
      .toList();

  final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData);

  final inputImage =
      InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

  return inputImage;
}
