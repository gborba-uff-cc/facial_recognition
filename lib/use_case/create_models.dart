import 'dart:typed_data';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:image/image.dart' as pkg_image;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';

class CreateModels {
  CreateModels(
    this._domainRepository,
    this._faceDetector,
    this._imageHandler,
  );

  final DomainRepository _domainRepository;
  final IFaceDetector<pkg_camera.CameraImage> _faceDetector;
  final IImageHandler<pkg_camera.CameraImage, pkg_image.Image, Uint8List> _imageHandler;

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

  Future<bool> isOneFacePicture(pkg_camera.CameraImage facePicture, sensorOrientation) async {
    final faces = await _faceDetector.detect(facePicture, sensorOrientation);
    return faces.length == 1;
  }

  Uint8List toJpg(pkg_camera.CameraImage cameraImage, int sensorRotation) {
    return _imageHandler.toJpg(
      _imageHandler.fromCameraImage(
        cameraImage,
        sensorRotation,
      ),
    );
  }

  void createStudent({
    required String individualRegistration,
    required String registration,
    required String name,
    required String surname,
  }) {
    final existingTeacher = _domainRepository
        .getStudentFromRegistration([registration])[registration];
    final existingIndividual = _domainRepository.getIndividualFromRegistration(
        [individualRegistration])[individualRegistration];
    if (existingTeacher != null) {
      ArgumentError(
        'already found a registered student',
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
