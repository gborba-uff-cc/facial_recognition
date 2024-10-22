import 'dart:typed_data';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:facial_recognition/models/use_case.dart';
import 'package:image/image.dart' as pkg_image;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';

class CreateModels {
  CreateModels(
    IDomainRepository domainRepository,
    IImageHandler<pkg_camera.CameraImage, pkg_camera.CameraDescription,
            pkg_image.Image, Uint8List>
        imageHandler,
    IRecognitionPipeline<pkg_camera.CameraImage, pkg_camera.CameraController, pkg_image.Image, Uint8List, Student, FaceEmbedding>
        recognitionPipeline,
  )   : _domainRepository = domainRepository,
        _recognitionPipeline = recognitionPipeline,
        _imageHandler = imageHandler;

  final IDomainRepository _domainRepository;
  final IRecognitionPipeline<
      pkg_camera.CameraImage,
      pkg_camera.CameraController,
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

  void createLessons({
    required String codeOfSubject,
    required String yearOfSubjectClass,
    required String semesterOfSubjectClass,
    required String nameOfSubjectClass,
    required String registrationOfTeacher,
    required Iterable<String> utcDateTime,
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
    final List<Lesson> lessons = [];
    for (final value in utcDateTime) {
      final aux = Lesson(
        subjectClass: sC,
        utcDateTime: DateTime.parse(value),
        teacher: t,
      );
      lessons.add(aux);
    }
    _domainRepository.addLesson(lessons);
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

  void createTeacherFacePicture({
    required Uint8List jpegFacePicture,
    required String teacherRegistration,
  }) {
    final t = _domainRepository
        .getTeacherFromRegistration([teacherRegistration])[teacherRegistration];
    if (t == null) {
      throw ArgumentError(
        'could not find a registered teacher',
        'registration',
      );
    }
    else {
      final facePicture = FacePicture(
        faceJpeg: jpegFacePicture,
        individual: t.individual,
      );
      _domainRepository.addFacePicture([facePicture]);
    }
  }

  void createTeacherFacialData({
    required FaceEmbedding embedding,
    required String teacherRegistration,
  }){
    final t = _domainRepository
        .getTeacherFromRegistration([teacherRegistration])[teacherRegistration];
    if (t == null) {
      throw ArgumentError(
        'could not find a registered teacher',
        'registration',
      );
    }
    else {
      final facialData = FacialData(
        data: embedding,
        individual: t.individual,
      );
      _domainRepository.addFacialData([facialData]);
    }
  }

  Future<List<pkg_image.Image>> detectFaces(
    final pkg_camera.CameraImage image,
    final pkg_camera.CameraController cameraController,
  ) {
    return _recognitionPipeline.detectFace(cameraImage: image, cameraController: cameraController);
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

  /// throws an [ArgumentError]
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

  /// returns all the students that already exist (should return anything)
  List<({
    String individualRegistration,
    String name,
    String registration,
    String? surname
  })> createStudents(
    Iterable<({
      String individualRegistration,
      String registration,
      String name,
      String? surname
    })> entries
  ) {
    if (entries.isEmpty) {
      return const [];
    }
    final List<Individual> individuals = [];
    final List<Student> stdudents = [];
/*
    final List<
        ({
          String registration,
          String individualRegistration,
          String name,
          String? surname
        })> existing = [];
    final List<
        ({
          String registration,
          String individualRegistration,
          String name,
          String? surname
        })> notExisting = [];
    final existingStudent = _domainRepository.getStudentFromRegistration(
      entries
          .map(
            (e) => e.registration,
          )
          .toList(),
    );
    final existingIndividual = _domainRepository.getIndividualFromRegistration(
      entries
          .map(
            (e) => e.registration,
          )
          .toList(),
    );
    for (final entry in entries) {
      if (existingStudent.containsKey(entry.registration) ||
          existingIndividual.containsKey(entry.individualRegistration)) {
        existing.add(entry);
      } else {
        notExisting.add(entry);
      }
    }
    for (var entry in notExisting) {
      final i = Individual(individualRegistration: entry.individualRegistration, name: entry.name, surname: entry.surname,);
      final s = Student(registration: entry.registration, individual: i);
      individuals.add(i);
      stdudents.add(s);
    }
*/
    for (var entry in entries) {
      final i = Individual(individualRegistration: entry.individualRegistration, name: entry.name, surname: entry.surname,);
      final s = Student(registration: entry.registration, individual: i);
      individuals.add(i);
      stdudents.add(s);
    }
    _domainRepository.addIndividual(individuals);
    _domainRepository.addStudent(stdudents);
    return const [];
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

  void createEnrollment({
    required String registrationOfStudent,
    required String year,
    required String semester,
    required String codeOfSubject,
    required String name,
  }) {
    final student = _domainRepository.getStudentFromRegistration(
      [registrationOfStudent],
    )[registrationOfStudent];
    final subjectClass = _domainRepository.getSubjectClass(
        year: int.parse(year),
        semester: int.parse(semester),
        subjectCode: codeOfSubject,
        name: name);
    if (student != null && subjectClass != null) {
      final enrollment = Enrollment(
          student: student,
          subjectClass: subjectClass,);
      _domainRepository.addEnrollment([enrollment]);
    }
  }

  List<String> createEnrollments({
    required Iterable<String> registrationOfStudent,
    required String year,
    required String semester,
    required String codeOfSubject,
    required String name,
  }) {
    if (registrationOfStudent.isEmpty) {
      return const [];
    }
    final subjectClass = _domainRepository.getSubjectClass(
      year: int.parse(year),
      semester: int.parse(semester),
      subjectCode: codeOfSubject,
      name: name,
    );
    if (subjectClass == null) {
      return registrationOfStudent.toList(growable: false);
    }
    final students = _domainRepository.getStudentFromRegistration(
      registrationOfStudent,
    );
    final List<Enrollment> enrollments = [];
    for (final value in students.values) {
      if (value == null) {
        continue;
      }
      enrollments.add(Enrollment(
        student: value,
        subjectClass: subjectClass,
      ));
    }
    _domainRepository.addEnrollment(enrollments);
    return const [];
  }
  void createAttendances({
    required String codeOfSubject,
    required String registrationOfTeacher,
    required String yearfsubjectClass,
    required String semesterOfSubjectClass,
    required String nameOfSubjectClass,
    required Iterable<({String registration, DateTime utcDateTime})> attendances,
    bool createMissingLessons = false,
  }) {
    // retrieve subject class
    final year = int.parse(yearfsubjectClass);
    final semester = int.parse(semesterOfSubjectClass);
    final theSubjectClass = _domainRepository.getSubjectClass(
      year: year,
      semester: semester,
      subjectCode: codeOfSubject,
      name: nameOfSubjectClass,
    );
    if (theSubjectClass == null) {
      throw ArgumentError('not found', 'subject class');
    }

    // create lessons on subject class if on attendance
    if (createMissingLessons) {
      final List<Lesson> subjectClassLessons = _domainRepository
          .getLessonFromSubjectClass([theSubjectClass])[theSubjectClass]!;
      final registeredLessons = subjectClassLessons
          .map((e) => e.utcDateTime.toIso8601String())
          .toSet();
      final List<String> notRegisteredLessons = attendances
          .map((e) => e.utcDateTime.toIso8601String())
          .toList()
          .where((element) => !registeredLessons.contains(element))
          .toList();
      createLessons(
        codeOfSubject: codeOfSubject,
        yearOfSubjectClass: yearfsubjectClass,
        semesterOfSubjectClass: semesterOfSubjectClass,
        nameOfSubjectClass: nameOfSubjectClass,
        registrationOfTeacher: registrationOfTeacher,
        utcDateTime: notRegisteredLessons,
      );
    }

    // create attendance
    final Map<DateTime, Lesson> lessonsByUtcDateTime = _domainRepository
        .getLessonFromSubjectClass([theSubjectClass])[theSubjectClass]!
        .asMap()
        .map((key, value) =>
            MapEntry(value.utcDateTime, value));
    final studentsByRegistration = _domainRepository
        .getStudentFromSubjectClass([theSubjectClass])[theSubjectClass]!
        .asMap()
        .map((key, value) => MapEntry(value.registration, value));
    final List<Attendance> newAttendances = [];
    for (final entry in attendances) {
      final s = studentsByRegistration[entry.registration];
      final l = lessonsByUtcDateTime[entry.utcDateTime];
      if (s != null && l != null) {
        final a = Attendance(student: s, lesson: l);
        newAttendances.add(a);
      }
    }
    _domainRepository.addAttendance(newAttendances);
    return;
  }
}
