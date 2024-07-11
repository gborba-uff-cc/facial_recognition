import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:image/image.dart';

class CameraIdentification implements ICameraAttendance<CameraImage> {
  CameraIdentification(
    IFaceDetector<CameraImage> faceDetector,
    IImageHandler<CameraImage, Image, Uint8List> imageHandler,
    IFaceEmbedder faceEmbedder,
    IFaceRecognizer<FaceEmbedding, Student> faceRecognizer,
    DomainRepository domainRepository,
    this.showFaceImages,
    this.lesson,
  ) :
    _detector = faceDetector,
    _imageHandler = imageHandler,
    _embedder = faceEmbedder,
    _recognizer = faceRecognizer,
    _domainRepo = domainRepository;

  final IFaceDetector<CameraImage> _detector;
  final IImageHandler<CameraImage, Image, Uint8List> _imageHandler;
  final IFaceEmbedder _embedder;
  final IFaceRecognizer<FaceEmbedding, Student> _recognizer;
  final DomainRepository _domainRepo;
  void Function(Iterable<Uint8List> jpegImages)? showFaceImages;
  final Lesson lesson;

  @override
  Future<void> onNewCameraImage(
    final CameraImage image,
    final int cameraSensorOrientation,
  ) async {
    //
    final Iterable<Duple<Uint8List, FaceEmbedding>> jpegsAndEmbeddings =
        await _detectFaceAndExtractEmbedding(image, cameraSensorOrientation);

    // call back the function to handle the detected faces image
    final localShowFaceImages = showFaceImages;
    if (localShowFaceImages != null) {
      localShowFaceImages(jpegsAndEmbeddings.map((e) => e.value1));
    }

    // recognize embedding now
    final Duple<Iterable<EmbeddingRecognized>,
        Iterable<EmbeddingNotRecognized>> recognizedAndNot;
    try {
      recognizedAndNot =
          _recognizeEmbedding(jpegsAndEmbeddings, lesson.subjectClass);
    }
    on _TryRecognizeLater {
      projectLogger.info('could not recognize embedding now', e);
      _deferRecognizeEmbedding(jpegsAndEmbeddings, lesson);
      return;
    }
    catch (e) {
      projectLogger.severe('for some reason, other than to try recognize later, could not recognize embedding', e);
      return;
    }

    final Iterable<EmbeddingRecognized> recognized = recognizedAndNot.value1;
    final Iterable<EmbeddingNotRecognized> notRecognized = recognizedAndNot.value2;
    projectLogger.fine('recognized students ${recognized.length}');
    projectLogger.fine('not recognized students: ${notRecognized.length}');

/* REVIEW
- for recognized, would be better to ask for a human comparison before marking
the attendance
- for not recognized, would be better ask to update known facial data for student
*/
    // handle recognized students
    _faceRecognized(recognized, lesson);

    // handle not recognized faces embedding
    _faceNotRecognized(notRecognized, lesson);
  }

  Future<Iterable<Duple<Uint8List, FaceEmbedding>>>
      _detectFaceAndExtractEmbedding(
    final CameraImage image,
    final int cameraSensorOrientation,
  ) async {
    // detect faces
    final faceRects = await _detector.detect(image, cameraSensorOrientation);
    projectLogger.fine('detected faces: ${faceRects.length}');

    // detach faces into manipulable images
    final manipulableImage = _imageHandler.fromCameraImage(image);
    final faceImages = _imageHandler.cropFromImage(manipulableImage, faceRects);

    // create jpegs images and rgbMatrixes of detected face images
    final List<Uint8List> detectedFaces = [];
    final List<List<List<List<int>>>> samples = [];
    for (final i in faceImages) {
      final jpeg = _imageHandler.toJpeg(i);
      detectedFaces.add(jpeg);

      final resizedImage = _imageHandler.resizeImage(i, 160, 160);
      final imageMatrix = _imageHandler.toRgbMatrix(resizedImage);
      samples.add(imageMatrix);
    }

    // generate faces embedding
    List<FaceEmbedding> facesEmbedding = await _embedder.extractEmbedding(samples);

    final List<Duple<Uint8List, FaceEmbedding>> result = [
      for (int i=0; i<detectedFaces.length; i++)
        Duple(detectedFaces[i], facesEmbedding[i])
    ];
    return result;
  }

  void _deferRecognizeEmbedding(
    final Iterable<Duple<Uint8List, FaceEmbedding>> input,
    final Lesson lesson,
  ) {
    projectLogger.info('face recognition is going to be deferred');
    _domainRepo.addFaceEmbeddingToDeferredPool(input, lesson);
  }

  /// trows _TryRecognizeLater if, for some reason, can't access face embeddings
  Duple<Iterable<EmbeddingRecognized>, Iterable<EmbeddingNotRecognized>>
      _recognizeEmbedding(
    final Iterable<Duple<Uint8List, FaceEmbedding>> input,
    final SubjectClass subjectClass,
  ) {
    final List<EmbeddingRecognized> recognized = [];
    final List<EmbeddingNotRecognized> notRecognized = [];
    final result = Duple(recognized, notRecognized);
    if (input.isEmpty) {
      return result;
    }

    // retrieve all students in this class that have facial data added
    final Map<Student, Iterable<FacialData>> facialDataByStudent;
    try {
      facialDataByStudent = _getFacialDataFromSubjectClass(subjectClass);
    }
    catch (e) {  // STUB - change to the correct condition
      throw _TryRecognizeLater();
    }

    // no facial data registered for students in the subject class
    if(facialDataByStudent.isEmpty) {
      notRecognized.addAll(
        input.map(
          (i) => EmbeddingNotRecognized(
            inputFace: i.value1,
            inputFaceEmbedding: i.value2,
            nearestStudent: null,
          ),
        ),
      );
      projectLogger.info(
        'This subject class has no student with facial data registered'
      );
      return result;
    }
    //
    final recognizeResult = _recognizer.recognize(
      input.map((e) => e.value2),
      facialDataByStudent.map(
        (student, iterableFacialData) => MapEntry(
          student,
          iterableFacialData.map((facialData) => facialData.data),
        ),
      ),
    );
    // split the recognition data between recognized and not
    for (final inputElement in input) {
      final jpeg = inputElement.value1;
      final inputEmbedding = inputElement.value2;
      final r = recognizeResult[inputElement.value2]!;
      // decide whether or not the embedding was recognized
      // REVIEW - necessity of different classes to recognized?
      if (r.status == FaceRecognitionStatus.recognized) {
        final newEntry = EmbeddingRecognized(
          inputFace: jpeg,
          inputFaceEmbedding: inputEmbedding,
          identifiedStudent: r.label,
        );
        recognized.add(newEntry);
      }
      else {
        final newEntry = EmbeddingNotRecognized(
          inputFace: jpeg,
          inputFaceEmbedding: inputEmbedding,
          nearestStudent: r.label,
        );
        notRecognized.add(newEntry);
      }
    }

    return result;
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
    Iterable<EmbeddingRecognized> recognized,
    Lesson lesson,
  ) {
    if (recognized.isEmpty) {
      return;
    }

    _domainRepo.addFaceEmbeddingToCameraRecognized(recognized, lesson);
    // _writeStudentAttendance(recognized.map((e) => e.nearestStudent), lesson);
    // _getAndShowSubjectClassAttendance(lesson.subjectClass);
  }

  void _faceNotRecognized(
    Iterable<EmbeddingNotRecognized> notRecognized,
    Lesson lesson,
  ) {
    if (notRecognized.isEmpty) {
      return;
    }

    _domainRepo.addFaceEmbeddingToCameraNotRecognized(notRecognized, lesson);
    _saveEmbeddingAsNewStudent(notRecognized, lesson);
  }

  /// FIXME - only for development - register a new student for a face embedding
  void _saveEmbeddingAsNewStudent(
    Iterable<EmbeddingNotRecognized> notRecognized,
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
}

class _TryRecognizeLater implements Exception {}
