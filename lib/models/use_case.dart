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
  // inputFace as a UInt8List jpeg
  final Uint8List inputFace;
  final FaceEmbedding inputFaceEmbedding;
  final FaceEmbedding? nearestEmbedding;
  // who the nearestEmbedding belong
  final Student? nearestStudent;
  final double distance;

  EmbeddingNotRecognized(
    this.inputFace,
    this.inputFaceEmbedding,
    this.nearestEmbedding,
    this.nearestStudent,
    this.distance,
  );
}

class EmbeddingRecognized {
  // inputFace as a UInt8List jpeg
  final Uint8List inputFace;
  final FaceEmbedding inputFaceEmbedding;
  final FaceEmbedding nearestEmbedding;
  // who the nearestEmbedding belong
  final Student nearestStudent;
  final double distance;

  EmbeddingRecognized(
    this.inputFace,
    this.inputFaceEmbedding,
    this.nearestEmbedding,
    this.nearestStudent,
    this.distance,
  );
}
