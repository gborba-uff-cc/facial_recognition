import 'dart:ui';

abstract class IFaceDetector<CI, CD> {
  Future<List<Rect>> detect(final CI image, final CD description);
}

abstract class IImageHandler<CI, CD, I, J> {
  I fromCameraImage(final CI image, final CD? description);
  I cropFromImage(final I image, final Rect rect);
  I resizeImage(final I image, final int width, final int height);
  J toJpeg(final I image);
  List<List<List<int>>> toRgbMatrix(final I image);
}

abstract class IFaceRecognizer {
  int get neededImageWidth;
  int get neededImageHeight;
  Future<List<double>> extractFeature(final List<List<List<num>>> image);
  double facesDistance(final List<double> face1, final List<double> face2);
}

abstract class ICameraAttendance<CI, CD> {
  void onNewCameraImage(final CI image, final CD description);
}
