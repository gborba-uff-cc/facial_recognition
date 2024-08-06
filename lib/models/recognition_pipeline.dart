import 'dart:typed_data';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';

class RecognitionPipeline<CI, I, J, L extends Student, E extends FaceEmbedding> {
  const RecognitionPipeline({
    required IFaceDetector<CI> faceDetector,
    required IImageHandler<CI, I, J> imageHandler,
    required IFaceEmbedder faceEmbedder,
    required IFaceRecognizer<L, E> faceRecognizer,
  })  : _faceDetector = faceDetector,
        _imageHandler = imageHandler,
        _faceEmbedder = faceEmbedder,
        _faceRecognizer = faceRecognizer;

  final IFaceDetector<CI> _faceDetector;
  final IImageHandler<CI, I, J> _imageHandler;
  final IFaceEmbedder _faceEmbedder;
  final IFaceRecognizer<L, E> _faceRecognizer;

  Future<List<I>> detectFace(
    final CI image,
    final int cameraSensorOrientation,
  ) async {
    // detect faces
    final faceRects = await _faceDetector.detect(image, cameraSensorOrientation);
    projectLogger.fine('detected faces: ${faceRects.length}');

    // detach faces into manipulable images
    final manipulableImage = _imageHandler.fromCameraImage(image, cameraSensorOrientation);
    final faces = _imageHandler.cropFromImage(manipulableImage, faceRects);
    return faces;
  }

  Future<List<Duple<J, FaceEmbedding>>> extractEmbedding(
    final List<I> faces,
  ) async {
    // create jpegs images and rgbMatrixes of detected face images
    final List<J> detectedFaces = [];
    final List<List<List<List<int>>>> samples = [];
    for (final i in faces) {
      final jpeg = _imageHandler.toJpeg(i);
      detectedFaces.add(jpeg);

      final resizedImage = _imageHandler.resizeImage(i, 160, 160);
      final imageMatrix = _imageHandler.toRgbMatrix(resizedImage);
      samples.add(imageMatrix);
    }

    // generate faces embedding
    List<FaceEmbedding> facesEmbedding =
        await _faceEmbedder.extractEmbedding(samples);

    final List<Duple<J, FaceEmbedding>> result = [
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
  Duple<Iterable<EmbeddingRecognitionResult>, Iterable<EmbeddingRecognitionResult>>
      recognizeEmbedding(
    final Iterable<Duple<Uint8List, FaceEmbedding>> input,
    final Map<L, Iterable<E>>embeddingsByStudent,
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

    final Iterable<E> unlabelledembeddings = input.map((e) => e.value2).cast();
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
