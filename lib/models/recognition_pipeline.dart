import 'dart:typed_data';
import 'dart:ui';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:image/image.dart' as pkg_image;


class RecognitionPipelineForCamerawesome implements
    IRecognitionPipeline<
        pkg_awesome.AnalysisImage,
        pkg_image.Image,
        JpegPictureBytes,
        Student,
        FaceEmbedding>
{
  final IFaceDetector<pkg_awesome.AnalysisImage> faceDetector;
  final ICameraImageHandler<
      pkg_awesome.AnalysisImage,
      pkg_image.Image,
      Uint8List> imageHandler;
  final IFaceEmbedder faceEmbedder;
  final IFaceRecognizer<Student, FaceEmbedding> faceRecognizer;

  const RecognitionPipelineForCamerawesome({
    required this.faceDetector,
    required this.imageHandler,
    required this.faceEmbedder,
    required this.faceRecognizer,
  });

  @override
  Future<List<Rect>> detectFace(
    pkg_awesome.AnalysisImage input,
  ) async {
    final rects = await faceDetector.detect(input);
    return rects;
  }

  @override
  Future<List<pkg_image.Image>> cropFaces({
    required final pkg_awesome.AnalysisImage input,
    required final List<Rect> rects,
  }) async {
    if (rects.isEmpty) {
      return Future.value(const []);
    }

    // detach faces into manipulable images
    final manipulableImage = await imageHandler.fromCameraImage(input);
    final faces = imageHandler.cropFromImage(manipulableImage, rects.toList());
    return faces;
  }

  @override
  Future<List<FaceEmbedding>> extractEmbedding(
    final List<pkg_image.Image> faces,
  ) async {
    if (faces.isEmpty) {
      return Future.value(const []);
    }

    final List<List<List<List<int>>>> samples = [];
    for (final i in faces) {
      final resizedImage = imageHandler.resizeImage(i, 160, 160);
      final imageMatrix = imageHandler.toRgbMatrix(resizedImage);
      samples.add(imageMatrix);
    }

    // generate faces embedding
    final List<FaceEmbedding> facesEmbedding =
        await faceEmbedder.extractEmbedding(samples);
    return facesEmbedding;
  }

  /// originally thought to throw an exception to be caugth if the recognition
  /// should be done another later due to not being able to access the needed
  /// info
  @override
  ({
    List<EmbeddingRecognitionResult> notRecognized,
    List<EmbeddingRecognitionResult> recognized
  }) recognizeEmbedding({
    required final List<({
      FaceEmbedding embedding,
      JpegPictureBytes face,
      DateTime utcDateTime,
    })> inputs,
    required final Map<Student, List<FaceEmbedding>> embeddingsByStudent,
  }) {
    final List<EmbeddingRecognitionResult> recognized = [];
    final List<EmbeddingRecognitionResult> notRecognized = [];
    final result = (recognized: recognized, notRecognized: notRecognized);
    if (inputs.isEmpty) {
      return result;
    }

    // no facial data registered for students in the subject class
    if(embeddingsByStudent.isEmpty) {
      notRecognized.addAll(
        inputs.map(
          (i) => EmbeddingRecognitionResult(
            inputFace: i.face,
            inputFaceEmbedding: i.embedding,
            recognized: false,
            utcDateTime: i.utcDateTime,
            nearestStudent: null,
          ),
        ),
      );
      projectLogger.info(
        'This subject class has no student with facial data registered'
      );
      return result;
    }

    final Iterable<FaceEmbedding> unlabelledembeddings = inputs.map((e) => e.embedding).cast();
    // (listFaceEmbedding, labeledFaceEmbedding) => {aFaceEmbedding: theRecognitionResult, ...}
    final recognizeResult = faceRecognizer.recognize(
      unlabelledembeddings,
      embeddingsByStudent,
    );
    // split the recognition data between recognized and not
    for (final inputElement in inputs) {
      final jpeg = inputElement.face;
      final inputEmbedding = inputElement.embedding;
      final r = recognizeResult[inputElement.embedding]!;
      final arriveTime = inputElement.utcDateTime;
      // decide whether or not the embedding was recognized
      // REVIEW - necessity of different classes to recognized?
      if (r.status == FaceRecognitionStatus.recognized) {
        final newEntry = EmbeddingRecognitionResult(
          inputFace: jpeg,
          inputFaceEmbedding: inputEmbedding,
          recognized: true,
          utcDateTime: arriveTime,
          nearestStudent: r.label,
        );
        recognized.add(newEntry);
      }
      else {
        final newEntry = EmbeddingRecognitionResult(
          inputFace: jpeg,
          inputFaceEmbedding: inputEmbedding,
          recognized: false,
          utcDateTime: arriveTime,
          nearestStudent: r.label,
        );
        notRecognized.add(newEntry);
      }
    }

    return result;
  }
}
