import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:camera/camera.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as pkg_image;

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

/// Return logical images of subareas from [image].
List<pkg_image.Image> cropImage(
    pkg_image.Image image, final List<dart_ui.Rect> areas) {
  return List.generate(areas.length, (index) {
    final rect = areas[index];
    return pkg_image.copyCrop(image,
        x: rect.left.toInt(),
        y: rect.top.toInt(),
        width: rect.width.toInt(),
        height: rect.height.toInt());
  }, growable: false);
}

/// Resize the *image* to match [size]
pkg_image.Image resizeImage(pkg_image.Image image, int width, int height) {
  return pkg_image.copyResize(image, width: width, height: height);
}

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
/// Convert a [image] from camera to an image used by the Google ML Kit
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

  final imageSize = dart_ui.Size(image.width.toDouble(), image.height.toDouble());

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

pkg_image.Image toLogicalImage({
  required int width,
  required int height,
  required ByteBuffer rgbBytes
}) {
  final image = pkg_image.Image.fromBytes(
    width: width,
    height: height,
    bytes: rgbBytes,
    order: pkg_image.ChannelOrder.rgb,
  );

  return image;
}

/// Convert YCbCr (called YUV) 4:2:0 3-plane to an RGB 1-plane.
ByteBuffer yCbCr420ToRgb({
  required final int width,
  required final int height,
  required List<Plane> planes
}) {
  final yBytes = planes[0].bytes;   // Y
  final cbBytes = planes[1].bytes;  // U
  final crBytes = planes[2].bytes;  // V
  final yBytesPerPixel = planes[0].bytesPerPixel ?? 1;
  final yBytesPerRow = planes[0].bytesPerRow;
  final cbCrBytesPerPixel = planes[1].bytesPerPixel ?? 1;
  final cbCrBytesPerRow = planes[1].bytesPerRow;

  final WriteBuffer rgbBytes = WriteBuffer(startCapacity: 3*width*height);

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int yIndex = x~/2 * yBytesPerPixel + y~/2 * yBytesPerRow;
      final int cbCrIndex = x~/2 * cbCrBytesPerPixel + (y~/2 * cbCrBytesPerRow);

      final yp = yBytes[yIndex];
      final up = cbBytes[cbCrIndex];
      final vp = crBytes[cbCrIndex];
      final r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      final g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      final b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      rgbBytes.putUint8(r);
      rgbBytes.putUint8(g);
      rgbBytes.putUint8(b);
    }
  }

  return rgbBytes.done().buffer;
}

Future<Uint8List> convertToJpg(pkg_image.Image image) async {
  if (image.format != pkg_image.Format.uint8 || image.numChannels != 4) {
    final cmd = pkg_image.Command()
      ..image(image)
      ..convert(format: pkg_image.Format.uint8, numChannels: 4);
    final rgba8 = await cmd.getImageThread();
    if (rgba8 != null) {
      image = rgba8;
    }
  }

  return pkg_image.encodeJpg(image);
}

// FIXME - imagem invertida, desentrelaçada e rosto não centrado
