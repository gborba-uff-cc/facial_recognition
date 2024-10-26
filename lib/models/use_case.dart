import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:camera/camera.dart' as pkg_camera;

class Duple<T1, T2> {
  final T1 value1;
  final T2 value2;

  const Duple(
    this.value1,
    this.value2,
  );
}

class EmbeddingRecognitionResult {
  /// [inputFace] is a jpeg image as UInt8List
  final Uint8List inputFace;
  final FaceEmbedding inputFaceEmbedding;
  final bool recognized;
  final Student? nearestStudent;

  EmbeddingRecognitionResult({
    required this.inputFace,
    required this.inputFaceEmbedding,
    required this.recognized,
    required this.nearestStudent,
  });
}

class PackageCameraMethodsInput {
  final pkg_camera.CameraImage image;
  final pkg_camera.CameraController controller;

  PackageCameraMethodsInput({
    required this.image,
    required this.controller,
  });
}