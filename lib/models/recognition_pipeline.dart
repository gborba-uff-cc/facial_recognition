import 'dart:typed_data';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:camera/camera.dart' as pkg_camera;
import 'package:image/image.dart' as pkg_image;


class RecognitionPipeline implements IRecognitionPipeline<pkg_image.Image, JpegPictureBytes, Student, FaceEmbedding> {
  const RecognitionPipeline({
    required IFaceDetector faceDetector,
    required IImageHandler<
        pkg_camera.CameraImage,
        pkg_camera.CameraDescription,
        pkg_image.Image, Uint8List>
      imageHandler,
    required IFaceEmbedder faceEmbedder,
    required IFaceRecognizer<Student, FaceEmbedding> faceRecognizer,
  })  : _faceDetector = faceDetector,
        _imageHandler = imageHandler,
        _faceEmbedder = faceEmbedder,
        _faceRecognizer = faceRecognizer;

  final IFaceDetector _faceDetector;
  final IImageHandler<pkg_camera.CameraImage, pkg_camera.CameraDescription,
      pkg_image.Image, Uint8List> _imageHandler;
  final IFaceEmbedder _faceEmbedder;
  final IFaceRecognizer<Student, FaceEmbedding> _faceRecognizer;

  @override
  Future<List<pkg_image.Image>> detectFace({
    required pkg_image.Image image,
    int imageRollDegree = 0,
  }) async {
    // detect faces
    final bgraBuffer = _imageHandler.toBgraBuffer(image);
    final faceRects = await _faceDetector.detect(
      bgraBuffer: bgraBuffer,
      width: image.width,
      height: image.height,
      imageRollDegree: imageRollDegree,
      // 1 byte * (1 blue + 1 gree + 3 red + 1 alpha)
      bytesRowStride: image.width*4,
    );
    projectLogger.info('detected faces: ${faceRects.length}');

    // detach faces into manipulable images
    // final manipulableImage = _imageHandler.fromCameraImage(bgraBuffer, cameraDescription);
    final faces = _imageHandler.cropFromImage(image, faceRects);
    return faces;
  }

  @override
  Future<List<Duple<JpegPictureBytes, FaceEmbedding>>> extractEmbedding(
    final List<pkg_image.Image> faces,
  ) async {
    // create jpegs images and rgbMatrixes of detected face images
    final List<Uint8List> detectedFaces = [];
    final List<List<List<List<int>>>> samples = [];
    for (final i in faces) {
      final jpeg = _imageHandler.toJpg(i);
      detectedFaces.add(jpeg);

      final resizedImage = _imageHandler.resizeImage(i, 160, 160);
      final imageMatrix = _imageHandler.toRgbMatrix(resizedImage);
      samples.add(imageMatrix);
    }

    // generate faces embedding
    List<FaceEmbedding> facesEmbedding =
        await _faceEmbedder.extractEmbedding(samples);

    final List<Duple<Uint8List, FaceEmbedding>> result = [
      for (int i = 0; i < detectedFaces.length; i++)
        Duple(detectedFaces[i], facesEmbedding[i])
    ];
    return result;
  }

  /// originally thought to be paired with something like:
  /// ```dart
  ///  // retrieve all students in this class that have facial data added
  ///  final Map<Student, Iterable<FacialData>> facialDataByStudent;
  ///  try {
  ///    facialDataByStudent = _getFacialDataFromSubjectClass(subjectClass);
  ///  }
  ///  catch (e) {  // STUB - change to the correct condition
  ///    throw _TryRecognizeLater();
  ///  }
  /// ```
  @override
  Duple<Iterable<EmbeddingRecognitionResult>, Iterable<EmbeddingRecognitionResult>>
      recognizeEmbedding(
    final Iterable<Duple<Uint8List, FaceEmbedding>> input,
    final Map<Student, Iterable<FaceEmbedding>>embeddingsByStudent,
  ) {
    final List<EmbeddingRecognitionResult> recognized = [];
    final List<EmbeddingRecognitionResult> notRecognized = [];
    final result = Duple(recognized, notRecognized);
    if (input.isEmpty) {
      return result;
    }

    // no facial data registered for students in the subject class
    if(embeddingsByStudent.isEmpty) {
      notRecognized.addAll(
        input.map(
          (i) => EmbeddingRecognitionResult(
            inputFace: i.value1,
            inputFaceEmbedding: i.value2,
            recognized: false,
            nearestStudent: null,
          ),
        ),
      );
      projectLogger.info(
        'This subject class has no student with facial data registered'
      );
      return result;
    }

    final Iterable<FaceEmbedding> unlabelledembeddings = input.map((e) => e.value2).cast();
    // (listFaceEmbedding, labeledFaceEmbedding) => {aFaceEmbedding: theRecognitionResult, ...}
    final recognizeResult = _faceRecognizer.recognize(
      unlabelledembeddings,
      embeddingsByStudent,
    );
    // split the recognition data between recognized and not
    for (final inputElement in input) {
      final jpeg = inputElement.value1;
      final inputEmbedding = inputElement.value2;
      final r = recognizeResult[inputElement.value2]!;
      // decide whether or not the embedding was recognized
      // REVIEW - necessity of different classes to recognized?
      if (r.status == FaceRecognitionStatus.recognized) {
        final newEntry = EmbeddingRecognitionResult(
          inputFace: jpeg,
          inputFaceEmbedding: inputEmbedding,
          recognized: true,
          nearestStudent: r.label,
        );
        recognized.add(newEntry);
      }
      else {
        final newEntry = EmbeddingRecognitionResult(
          inputFace: jpeg,
          inputFaceEmbedding: inputEmbedding,
          recognized: false,
          nearestStudent: r.label,
        );
        notRecognized.add(newEntry);
      }
    }

    return result;
  }
}
