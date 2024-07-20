import 'dart:ui';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';

abstract class IFaceDetector<CI> {
  Future<List<Rect>> detect(final CI image, [final int controllerSensorOrientation = 0]);
}

abstract class IImageHandler<CI, I, J> {
  I fromCameraImage(final CI image);
  List<I> cropFromImage(final I image, final List<Rect> rect);
  I resizeImage(final I image, final int width, final int height);
  J toJpeg(final I image);
  List<List<List<int>>> toRgbMatrix(final I image);
}

abstract class IFaceEmbedder {
  int get neededImageWidth;
  int get neededImageHeight;
  Future<List<FaceEmbedding>> extractEmbedding(final List<List<List<List<num>>>> facesRgbMatrix);
}

abstract class IFaceRecognizer<TLabel, TElement> {
  /// return the most alike label among the data set and the a recognition value
  Map<TElement, IFaceRecognitionResult<TLabel>> recognize(
    final Iterable<TElement> unknown,
    final Map<TLabel, Iterable<TElement>> dataSet,
  );

  double get recognitionThreshold;
}

abstract class IFaceRecognitionResult<TLabel> {
  double get recognitionValue;
  FaceRecognitionStatus get status;
  TLabel get label;
}

enum FaceRecognitionStatus {
  recognized,
  notRecognized,
}

abstract class ICameraAttendance<CI> {
  // void onNewCameraImage(final CI image, final int cameraSensorOrientation);
  void onNewCameraImage(final CI image, final int cameraSensorOrientation);
}

typedef DistanceFunction<TElement> = double Function(TElement a, TElement b);