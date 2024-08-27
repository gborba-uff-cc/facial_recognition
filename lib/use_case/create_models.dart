import 'dart:typed_data';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:facial_recognition/models/use_case.dart';
import 'package:image/image.dart' as pkg_image;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';

class CreateModels {
  CreateModels(
    DomainRepository domainRepository,
    IImageHandler<pkg_camera.CameraImage, pkg_camera.CameraDescription, pkg_image.Image, Uint8List> imageHandler,
    IRecognitionPipeline<pkg_camera.CameraImage, pkg_camera.CameraDescription, pkg_image.Image, Uint8List,
      Student, FaceEmbedding> recognitionPipeline,
  )   : _domainRepository = domainRepository,
        _recognitionPipeline = recognitionPipeline,
        _imageHandler = imageHandler;

  final DomainRepository _domainRepository;
  final IRecognitionPipeline<
      pkg_camera.CameraImage,
      pkg_camera.CameraDescription,
      pkg_image.Image,
      Uint8List,
      Student,
      FaceEmbedding> _recognitionPipeline;
  final IImageHandler<pkg_camera.CameraImage, pkg_camera.CameraDescription,
      pkg_image.Image, Uint8List> _imageHandler;

  void createLesson({
    required String codeOfSubject,
    required String yearOfSubjectClass,
    required String semesterOfSubjectClass,
    required String nameOfSubjectClass,
    required String registrationOfTeacher,
    required String utcDateTime,
  }) {
    final s =
        _domainRepository.getSubjectFromCode([codeOfSubject])[codeOfSubject];
    final t = _domainRepository.getTeacherFromRegistration(
        [registrationOfTeacher])[registrationOfTeacher];
    if (s == null) {
      throw ArgumentError('not found', 'codeOfSubject');
    }
    if (t == null) {
      throw ArgumentError('not found', 'registrationOfTeacher');
    }
    final sC = SubjectClass(
      subject: s,
      year: int.parse(yearOfSubjectClass),
      semester: int.parse(semesterOfSubjectClass),
      name: nameOfSubjectClass,
      teacher: t,
    );
    final lesson = Lesson(
      subjectClass: sC,
      utcDateTime: DateTime.parse(utcDateTime),
      teacher: t,
    );
    _domainRepository.addLesson([lesson]);
  }

  void createSubjectClass({
    required String codeOfSubject,
    required String registrationOfTeacher,
    required String year,
    required String semester,
    required String name,
  }) {
    final s = _domainRepository.getSubjectFromCode([codeOfSubject])[codeOfSubject];
    final t = _domainRepository.getTeacherFromRegistration([registrationOfTeacher])[registrationOfTeacher];
    if (s == null) {
      throw ArgumentError('not found', 'codeOfSubject');
    }
    if (t == null) {
      throw ArgumentError('not found', 'registrationOfTeacher');
    }
    final subjectClass = SubjectClass(
      subject: s,
      year: int.parse(year),
      semester: int.parse(semester),
      name: name,
      teacher: t,
    );
    _domainRepository.addSubjectClass([subjectClass]);
  }

  void createTeacher({
    required String individualRegistration,
    required String registration,
    required String name,
    required String surname,
  }) {
    final existingTeacher = _domainRepository
        .getTeacherFromRegistration([registration])[registration];
    final existingIndividual = _domainRepository.getIndividualFromRegistration(
        [individualRegistration])[individualRegistration];
    if (existingTeacher != null) {
      ArgumentError(
        'already found a registered teacher',
        'registration',);
    }
    if (existingIndividual != null) {
      throw ArgumentError(
        'already found a registered individual',
        'individualRegistration',
      );
    }
    final i = Individual(
      individualRegistration: individualRegistration,
      name: name,
      surname: surname,
    );
    final teacher = Teacher(
      individual: i,
      registration: registration,
    );
    _domainRepository.addIndividual([i]);
    _domainRepository.addTeacher([teacher]);
  }

  Future<List<pkg_image.Image>> detectFaces(
    final pkg_camera.CameraImage image,
    final pkg_camera.CameraDescription cameraDescription,
  ) {
    return _recognitionPipeline.detectFace(image, cameraDescription);
  }

  Future<List<Duple<Uint8List, FaceEmbedding>>> extractEmbedding(
    final pkg_image.Image face,
  ) {
    return _recognitionPipeline.extractEmbedding([face]);
  }

  Uint8List fromCameraImagetoJpg(pkg_camera.CameraImage cameraImage, pkg_camera.CameraDescription cameraDescription) {
    return _imageHandler.toJpg(
      _imageHandler.fromCameraImage(
        cameraImage,
        cameraDescription,
      ),
    );
  }

  Uint8List fromImageToJpg(pkg_image.Image image) {
    return pkg_image.encodeJpg(image);
  }

  void createStudent({
    required String individualRegistration,
    required String registration,
    required String name,
    required String surname,
  }) {
    final existingOne = _domainRepository
        .getStudentFromRegistration([registration])[registration];
    if (existingOne != null) {
      ArgumentError(
        'already found a registered student',
        'registration',);
    }
    final existingIndividual = _domainRepository.getIndividualFromRegistration(
        [individualRegistration])[individualRegistration];
    if (existingIndividual != null) {
      throw ArgumentError(
        'already found a registered individual',
        'individualRegistration',
      );
    }
    final i = Individual(
      individualRegistration: individualRegistration,
      name: name,
      surname: surname,
    );
    final student = Student(
      individual: i,
      registration: registration,
    );
    _domainRepository.addIndividual([i]);
    _domainRepository.addStudent([student]);
  }

  void createStudentFacePicture({
    required Uint8List jpegFacePicture,
    required String studentRegistration,
  }) {
    final s = _domainRepository
        .getStudentFromRegistration([studentRegistration])[studentRegistration];
    if (s == null) {
      throw ArgumentError(
        'could not find a registered student',
        'individualRegistration',
      );
    }
    else {
      final facePicture = FacePicture(
        faceJpeg: jpegFacePicture,
        individual: s.individual,
      );
      _domainRepository.addFacePicture([facePicture]);
    }
  }

  void createStudentFacialData({
    required FaceEmbedding embedding,
    required String studentRegistration,
  }){
    final s = _domainRepository
        .getStudentFromRegistration([studentRegistration])[studentRegistration];
    if (s == null) {
      throw ArgumentError(
        'could not find a registered student',
        'individualRegistration',
      );
    }
    else {
      final facialData = FacialData(
        data: embedding,
        individual: s.individual,
      );
      _domainRepository.addFacialData([facialData]);
    }
  }

  void createSubject({
    required String code,
    required String name,
  }) {
    final subject = Subject(code: code, name: name);
    _domainRepository.addSubject([subject]);
  }
}
