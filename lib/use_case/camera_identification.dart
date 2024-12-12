import 'dart:typed_data';
import 'dart:ui';

import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:image/image.dart' as pkg_image;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';

class CameraIdentificationHandheldForCamerawesome implements
    ICameraAttendance<pkg_awesome.AnalysisImage, JpegPictureBytes>
{

  final ICameraImageHandler<
      pkg_awesome.AnalysisImage,
      pkg_image.Image,
      Uint8List> imageHandler;
  final IRecognitionPipeline<
      pkg_awesome.AnalysisImage,
      pkg_image.Image,
      Uint8List,
      Student,
      FaceEmbedding> recognitionPipeline;
  final Map<Student, Iterable<FacialData>> facialDataByStudent;
  final IDomainRepository domainRepository;
  final Lesson lesson;
  @override
  void Function(List<({JpegPictureBytes face, Rect rect})> detected)?
      onDetectionResult;
  @override
  void Function({
    Iterable<EmbeddingRecognitionResult> recognized,
    Iterable<EmbeddingRecognitionResult> notRecognized,
  })? onRecognitionResult;


  CameraIdentificationHandheldForCamerawesome({
    required this.recognitionPipeline,
    required this.imageHandler,
    required this.domainRepository,
    required this.lesson,
  }) : facialDataByStudent = domainRepository.getFacialDataFromStudent(
            domainRepository.getStudentFromSubjectClass(
                [lesson.subjectClass])[lesson.subjectClass]!);

  @override
  Future<void> onNewCameraInput(
    final pkg_awesome.AnalysisImage input,
  ) async {
    final rects = await recognitionPipeline.detectFace(input);
    final faces = await recognitionPipeline.cropFaces(input: input, rects: rects);
    final embeddings = await recognitionPipeline.extractEmbedding(faces);
    final jpgs = faces.map<JpegPictureBytes>((e) => imageHandler.toJpg(e)).toList();

    // call back the function to handle the detected faces image
    final localShowFaceImages = onDetectionResult;
    if (localShowFaceImages != null) {
      final l = List.generate(
        rects.length,
        (index) => (rect: rects[index], face: jpgs[index]),
      );
      localShowFaceImages(l);
    }

    const bool tryRecognizeLater = false;
    final Map<Student, List<FaceEmbedding>> embeddingsByStudent =
        facialDataByStudent.map(
      (student, iterableFacialData) => MapEntry(
        student,
        iterableFacialData
            .map(
              (facialData) => facialData.data,
            )
            .toList(),
      ),
    );

    final dateTime = DateTime.now().toUtc();
    final embeddingsAndFaces = List.generate(
      embeddings.length,
      (index) => (
        embedding: embeddings[index],
        face: jpgs[index],
        utcDateTime: dateTime,
      ),
    );
    // do recognitions later
    // ignore: dead_code
    if (tryRecognizeLater) {
      projectLogger.info(
          'could not recognize embedding now; face recognition is going to be deferred');
      domainRepository.addFaceEmbeddingToDeferredPool(embeddingsAndFaces, lesson);
      return;
    }

    final recognizedAndNot = recognitionPipeline.recognizeEmbedding(
      inputs: embeddingsAndFaces,
      embeddingsByStudent: embeddingsByStudent,
    );

    final Iterable<EmbeddingRecognitionResult> recognized = recognizedAndNot.recognized;
    final Iterable<EmbeddingRecognitionResult> notRecognized = recognizedAndNot.notRecognized;
    projectLogger.info('recognized students ${recognized.length}');
    projectLogger.info('not recognized students: ${notRecognized.length}');

    // handle recognized students
    if (recognized.isNotEmpty) {
      domainRepository.addFaceEmbeddingToCameraRecognized(recognized, lesson);
    }

    // handle not recognized faces embedding
    if (notRecognized.isNotEmpty) {
      domainRepository.addFaceEmbeddingToCameraNotRecognized(
          notRecognized, lesson);
    }
  }
}

class CameraIdentificationTotemForCamerawesome implements
    ICameraAttendance<pkg_awesome.AnalysisImage, JpegPictureBytes>
{
  final ICameraImageHandler<
      pkg_awesome.AnalysisImage,
      pkg_image.Image,
      Uint8List> imageHandler;
  final IRecognitionPipeline<
      pkg_awesome.AnalysisImage,
      pkg_image.Image,
      Uint8List,
      Student,
      FaceEmbedding> recognitionPipeline;
  final Map<Student, Iterable<FacialData>> facialDataByStudent;
  final IDomainRepository domainRepository;
  final Lesson lesson;
  @override
  void Function(List<({JpegPictureBytes face, Rect rect})> detected)?
      onDetectionResult;
  @override
  void Function({
    Iterable<EmbeddingRecognitionResult> recognized,
    Iterable<EmbeddingRecognitionResult> notRecognized,
  })? onRecognitionResult;

  CameraIdentificationTotemForCamerawesome({
    required this.recognitionPipeline,
    required this.imageHandler,
    required this.domainRepository,
    required this.lesson,
  }) : facialDataByStudent = domainRepository.getFacialDataFromStudent(
            domainRepository.getStudentFromSubjectClass(
                [lesson.subjectClass])[lesson.subjectClass]!);

  @override
  Future<void> onNewCameraInput(
    final pkg_awesome.AnalysisImage input,
  ) async {
    final dateTime = DateTime.now().toUtc();
    List<Rect> rects = await recognitionPipeline.detectFace(input);
    rects = List.of(rects);
    rects.sort((a,b) => (a.width*a.height).compareTo(b.width*b.height));
    final biggestRectIndex = rects.length-1;
    // NOTE - only the biggest face, so faces length is 0 or 1
    final faces = await recognitionPipeline.cropFaces(
      input: input,
      rects: rects.isNotEmpty ? [rects[biggestRectIndex]] : [],
    );
    final facesJpg = faces.map<JpegPictureBytes>((e) => imageHandler.toJpg(e)).toList();

    if (onDetectionResult != null) {
      onDetectionResult!(
        faces.isEmpty
            ? []
            : [(rect: rects[biggestRectIndex], face: facesJpg.first)],
      );
    }

    final embeddings = await recognitionPipeline.extractEmbedding(faces);

    final Map<Student, List<FaceEmbedding>> embeddingsByStudent =
        facialDataByStudent.map(
      (student, iterableFacialData) => MapEntry(
        student,
        iterableFacialData
            .map(
              (facialData) => facialData.data,
            )
            .toList(),
      ),
    );

    final embeddingsAndFaces = List.generate(
      embeddings.length,
      (index) => (
        embedding: embeddings[index],
        face: facesJpg[index],
        utcDateTime: dateTime,
      ),
    );

    final recognizedAndNot = recognitionPipeline.recognizeEmbedding(
      inputs: embeddingsAndFaces,
      embeddingsByStudent: embeddingsByStudent,
    );

    final Iterable<EmbeddingRecognitionResult> recognized = recognizedAndNot.recognized;
    final Iterable<EmbeddingRecognitionResult> notRecognized = recognizedAndNot.notRecognized;

    if (onRecognitionResult != null) {
      onRecognitionResult!(
        recognized: recognized,
        notRecognized: notRecognized,
      );
    }
  }
}
