import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart';

import '../models/facenet_face_recognizer.dart';
import '../models/google_face_detector.dart';
import '../models/image_handler.dart';
import '../interfaces.dart';
import '../utils/hour_glass.dart';
import '../utils/project_logger.dart';

// import 'package:flutter/material.dart';

// class CameraAttendanceScreen extends StatelessWidget {
//   CameraAttendanceen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

class CameraAttendance implements ICameraAttendance<CameraImage, CameraDescription> {
  final IFaceDetector<CameraImage, CameraDescription> _detector = GoogleFaceDetector();
  final IImageHandler<CameraImage, CameraDescription, Image, Uint8List> _imageHandler = ImageHandler();
  final IFaceRecognizer _recognizer = FacenetFaceRecognizer();
  final _handleFacesCounter = HourGlass(10);

  @override
  void onNewCameraImage(CameraImage image, CameraDescription description) async {
    /* TODO - update view to show the frame
    view.update_camera_frame(image);
    */

    _handleFacesCounter.dropGrain();
    if (_handleFacesCounter.isEmpty) {
      _handleFaces(image, description);
    }
  }

  void _handleFaces(CameraImage image, CameraDescription description) async {
    final img = _imageHandler.fromCameraImage(image, description);
    final rects = await _detector.detect(image, description);
    final facesImages = rects
        .map((rect) => _imageHandler.cropFromImage(img, rect));
    /* TODO - update view adding the faces jpgs to view
    final facesJpgs = facesImages
        .map((faceImage) => _imageHandler.toJpeg(faceImage));
    view.update_detected_faces
    */
    final resized = facesImages
        .map((facePicture) => _imageHandler.resizeImage(
              facePicture,
              _recognizer.neededImageWidth,
              _recognizer.neededImageHeight,
            ));
    final rgbMatrixes = resized
        .map((picture) => _imageHandler.toRgbMatrix(picture));
    final embeddings = rgbMatrixes.map((sample) => _recognizer.extractFeature(sample));
    for (final embedding in embeddings) {
      embedding.then((value) => projectLogger.shout(value));
    }
  }
}
