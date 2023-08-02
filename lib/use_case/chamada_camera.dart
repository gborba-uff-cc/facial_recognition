import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart' as googleFaceDetector;

void main(List<String> args) {

}

abstract class IFaceDetector {
  Future<List<Rect>> detect(CameraImage image);  // {add|read|update|delete|transformations}
}

abstract class IView {
  void update() {}  // {get|clear}
}

abstract class IPresenter {
  void notifyModel() {}  // handle intents
  void notifyView() {}  // handle intents
}

// -------------------

class FaceDetector implements IFaceDetector {
  final detector = googleFaceDetector.FaceDetector(
      options: googleFaceDetector.FaceDetectorOptions(),
    );

  FaceDetector({required Presenter presenter}) {}

  @override
  Future<List<Rect>> detect(CameraImage image, CameraDescription camera) {
    final input = toInputImage(image, camera);
    final faces = detector.processImage(input);
    final rects = faces
        .then((list) => list
            .map((e) => e.boundingBox)
            .toList(growable: false));
    return rects;
  }

  googleFaceDetector.InputImage toInputImage(CameraImage image, CameraDescription camera) {
    final imageRotation = InputImageRotationValue.fromRawValue(
        camera.sensorOrientation);
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
}

class View implements IView {
  View({required Presenter presenter});

  @override
  void update() {
    // TODO: implement update
  }
}

class Presenter implements IPresenter{
    Presenter({required FaceDetector model, required View view});

      @override
      void notifyModel() {
    // TODO: implement notifyModel
      }

      @override
      void notifyView() {
    // TODO: implement notifyView
      }
}

class ChamadaCamera extends StatelessWidget {
  const ChamadaCamera({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}