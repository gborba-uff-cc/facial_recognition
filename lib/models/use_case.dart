import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';

class Duple<T1, T2> {
  final T1 value1;
  final T2 value2;

  const Duple(
    this.value1,
    this.value2,
  );
}

class EmbeddingNotRecognized {
  /// [inputFace] is a jpeg image as UInt8List
  final Uint8List inputFace;
  final FaceEmbedding inputFaceEmbedding;
  final Student? nearestStudent;

  EmbeddingNotRecognized({
    required this.inputFace,
    required this.inputFaceEmbedding,
    required this.nearestStudent,
  });
}

class EmbeddingRecognized {
  /// [inputFace] is a jpeg image as UInt8List
  final Uint8List inputFace;
  final FaceEmbedding inputFaceEmbedding;
  final Student identifiedStudent;

  EmbeddingRecognized({
    required this.inputFace,
    required this.inputFaceEmbedding,
    required this.identifiedStudent,
  });
}
