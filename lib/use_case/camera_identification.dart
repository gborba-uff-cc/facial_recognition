import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:image/image.dart' as pkg_image;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';

class CameraIdentificationInputType {

  final pkg_camera.CameraImage image;
  final pkg_camera.CameraController controller;

  CameraIdentificationInputType({required this.image, required this.controller});
}

/* class CameraIdentification implements ICameraAttendance<CameraIdentificationInputType, JpegPictureBytes> {
  CameraIdentification(
    IRecognitionPipeline<pkg_camera.CameraImage, pkg_camera.CameraController,
            pkg_image.Image, Uint8List, Student, FaceEmbedding>
        recognitionPipeline,
    IImageHandler<pkg_camera.CameraImage, pkg_camera.CameraDescription,
            pkg_image.Image, Uint8List>
        imageHandler,
    IDomainRepository domainRepository,
    // this.showFaceImages,
    this.lesson,
  )   : _imageHandler = imageHandler,
        _recognitionPipeline = recognitionPipeline,
        _domainRepo = domainRepository;

  final IImageHandler<pkg_camera.CameraImage, pkg_camera.CameraDescription,
      pkg_image.Image, Uint8List> _imageHandler;

  final IRecognitionPipeline<
      pkg_camera.CameraImage,
      pkg_camera.CameraController,
      pkg_image.Image,
      Uint8List,
      Student,
      FaceEmbedding> _recognitionPipeline;
  final IDomainRepository _domainRepo;
  final Lesson lesson;

  @override
  void Function(List<({JpegPictureBytes faceImage, Rect rect})> detected)? onDetectedFaces;

  @override
  Future<void> onNewCameraInput(
    final CameraIdentificationInputType input,
  ) async {
    final faces = await _recognitionPipeline.detectFace(
      cameraImage: input.image,
      cameraController: input.controller,
    );
    final jpegsAndEmbeddings =
        await _recognitionPipeline.extractEmbedding(faces);

    // call back the function to handle the detected faces image
    final localShowFaceImages = onDetectedFaces;
    // FIXME
    if (localShowFaceImages != null) {
      localShowFaceImages(
        jpegsAndEmbeddings.map(
          (e) => (rect: Rect.zero, faceImage: e.value1),
        ).toList(),
      );
    }

    const bool tryRecognizeLater = false;
    // TODO - receive this from outside to avoid unecessary calls
    // retrieve all students in this class that have facial data added
    final Map<Student, Iterable<FaceEmbedding>> embeddingsByStudent =
        _getFacialDataFromSubjectClass(lesson.subjectClass).map(
      (student, iterableFacialData) => MapEntry(
        student,
        iterableFacialData.map(
          (facialData) => facialData.data,
        ),
      ),
    );

    Duple<Iterable<EmbeddingRecognitionResult>,
        Iterable<EmbeddingRecognitionResult>> recognizedAndNot = const Duple([], []);
    // ignore: dead_code
    if (tryRecognizeLater) {
      projectLogger.info('could not recognize embedding now', e);
      _deferRecognizeEmbedding(jpegsAndEmbeddings, lesson);
      return;
    }
    recognizedAndNot = await _recognitionPipeline.recognizeEmbedding(
      jpegsAndEmbeddings,
      embeddingsByStudent,
    );

    final Iterable<EmbeddingRecognitionResult> recognized = recognizedAndNot.value1;
    final Iterable<EmbeddingRecognitionResult> notRecognized = recognizedAndNot.value2;
    projectLogger.fine('recognized students ${recognized.length}');
    projectLogger.fine('not recognized students: ${notRecognized.length}');

    // handle recognized students
    _faceRecognized(recognized, lesson);

    // handle not recognized faces embedding
    _faceNotRecognized(notRecognized, lesson);
  }

  void _deferRecognizeEmbedding(
    final Iterable<Duple<Uint8List, FaceEmbedding>> input,
    final Lesson lesson,
  ) {
    projectLogger.info('face recognition is going to be deferred');
    _domainRepo.addFaceEmbeddingToDeferredPool(input, lesson);
  }

  Map<Student, Iterable<FacialData>> _getFacialDataFromSubjectClass(
    SubjectClass subjectClass,
  ) {
    final studentByClass =
        _domainRepo.getStudentFromSubjectClass([subjectClass]);
    final facialDataByStudent = _domainRepo
        .getFacialDataFromStudent(studentByClass[subjectClass]!);
    return facialDataByStudent;
  }

  void _faceRecognized(
    Iterable<EmbeddingRecognitionResult> recognized,
    Lesson lesson,
  ) {
    if (recognized.isEmpty) {
      return;
    }

    _domainRepo.addFaceEmbeddingToCameraRecognized(recognized, lesson);
  }

  void _faceNotRecognized(
    Iterable<EmbeddingRecognitionResult> notRecognized,
    Lesson lesson,
  ) {
    if (notRecognized.isEmpty) {
      return;
    }

    _domainRepo.addFaceEmbeddingToCameraNotRecognized(notRecognized, lesson);
/*
    //STUB - only for development
    _saveEmbeddingAsNewStudent(notRecognized, lesson);
 */
  }

/*
  /// STUB - only for development - register a new student with a face embedding
  void _saveEmbeddingAsNewStudent(
    Iterable<EmbeddingRecognitionResult> notRecognized,
    Lesson lesson,
  ) {
    final individual = <Individual>[];
    final facialData = <FacialData>[];
    final facePicture = <FacePicture>[];
    final student = <Student>[];
    final enrollment = <Enrollment>[];

    for (final elem in notRecognized) {
      final random = Random();
      final i = [for (int i = 0; i < 11; i++) 97+random.nextInt(26)]
          .map((e) => String.fromCharCode(e))
          .join();
      final n = [for (int i = 0; i < 6; i++) 97+random.nextInt(26)]
          .map((e) => String.fromCharCode(e))
          .join();
      final r = [for (int i = 0; i < 9; i++) 97+random.nextInt(26)]
          .map((e) => String.fromCharCode(e))
          .join();

      final anIndividual = Individual(individualRegistration: i, name: n);
      final aFacePicture = FacePicture(faceJpeg: elem.inputFace, individual: anIndividual);
      final aFacialData = FacialData(data: elem.inputFaceEmbedding, individual: anIndividual);
      final aStudent = Student(registration: r, individual: anIndividual);
      final anEnrollment = Enrollment(student: aStudent, subjectClass: lesson.subjectClass);

      individual.add(anIndividual);
      facePicture.add(aFacePicture);
      facialData.add(aFacialData);
      student.add(aStudent);
      enrollment.add(anEnrollment);
    }

    _domainRepo.addIndividual(individual);
    _domainRepo.addFacePicture(facePicture);
    _domainRepo.addFacialData(facialData);
    _domainRepo.addStudent(student);
    _domainRepo.addEnrollment(enrollment);
  }
*/
} */

class CameraIdentificationForCamerawesome implements
    ICameraAttendance<pkg_awesome.AnalysisImage, JpegPictureBytes>
{

  final IImageHandler<
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
      onDetectedFaces;

  CameraIdentificationForCamerawesome({
    required this.recognitionPipeline,
    required this.imageHandler,
    required this.domainRepository,
    // this.showFaceImages,
    required this.lesson,
  }) : facialDataByStudent = domainRepository.getFacialDataFromStudent(
            domainRepository.getStudentFromSubjectClass(
                [lesson.subjectClass])[lesson.subjectClass]!);

  @override
  Future<void> onNewCameraInput(
    final pkg_awesome.AnalysisImage input,
  ) async {
    final rects = await recognitionPipeline.detectFace(input);
    final image = imageHandler.fromCameraImage(input);
    final faces = imageHandler.cropFromImage(image, rects);
    final embeddings = await recognitionPipeline.extractEmbedding(faces);
    final jpgs = faces.map<JpegPictureBytes>((e) => imageHandler.toJpg(image)).toList();

    // call back the function to handle the detected faces image
    final localShowFaceImages = onDetectedFaces;
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

/*     Duple<Iterable<EmbeddingRecognitionResult>,
            Iterable<EmbeddingRecognitionResult>> recognizedAndNot =
        const Duple([], []); */
        // TODO - continue here
    // ignore: dead_code
    if (tryRecognizeLater) {
      projectLogger.info('could not recognize embedding now', e);
      _deferRecognizeEmbedding(embeddings, lesson);
      return;
    }
    final recognizedAndNot = recognitionPipeline.recognizeEmbedding(
      inputs: embeddings,
      embeddingsByStudent: embeddingsByStudent,
    );

    final Iterable<EmbeddingRecognitionResult> recognized = recognizedAndNot.recognized;
    final Iterable<EmbeddingRecognitionResult> notRecognized = recognizedAndNot.notRecognized;
    projectLogger.info('recognized students ${recognized.length}');
    projectLogger.info('not recognized students: ${notRecognized.length}');

    // handle recognized students
    _faceRecognized(recognized, lesson);

    // handle not recognized faces embedding
    _faceNotRecognized(notRecognized, lesson);
  }

  void _deferRecognizeEmbedding(
    final Iterable<Duple<Uint8List, FaceEmbedding>> input,
    final Lesson lesson,
  ) {
    projectLogger.info('face recognition is going to be deferred');
    _domainRepo.addFaceEmbeddingToDeferredPool(input, lesson);
  }

  Map<Student, Iterable<FacialData>> _getFacialDataFromSubjectClass(
    SubjectClass subjectClass,
  ) {
    final studentByClass =
        domainRepository.getStudentFromSubjectClass([subjectClass])[subjectClass]!;
    final facialDataByStudent = domainRepository
        .getFacialDataFromStudent(studentByClass);
    return facialDataByStudent;
  }

  void _faceRecognized(
    Iterable<EmbeddingRecognitionResult> recognized,
    Lesson lesson,
  ) {
    if (recognized.isEmpty) {
      return;
    }

    _domainRepo.addFaceEmbeddingToCameraRecognized(recognized, lesson);
  }

  void _faceNotRecognized(
    Iterable<EmbeddingRecognitionResult> notRecognized,
    Lesson lesson,
  ) {
    if (notRecognized.isEmpty) {
      return;
    }

    _domainRepo.addFaceEmbeddingToCameraNotRecognized(notRecognized, lesson);
  }
}
