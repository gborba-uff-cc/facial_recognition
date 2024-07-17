import 'dart:typed_data';

import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';

class Individual {
  String individualRegistration;
  String name;
  String? surname;

  Individual({
    required this.individualRegistration,
    required this.name,
    this.surname,
  });

  String get displayFullName => '$name${surname!=null?' $surname':''}';

  @override
  int get hashCode => Object.hash(individualRegistration, name, surname);

  @override
  bool operator ==(Object other) =>
      other is Individual &&
      other.individualRegistration == individualRegistration &&
      other.name == name &&
      other.surname == surname;
}

typedef FaceEmbedding = List<double>;

class FacialData {
  FaceEmbedding data;
  Individual individual;

  FacialData({
    required this.data,
    required this.individual,
  });

  @override
  int get hashCode => Object.hash(data, individual);

  @override
  bool operator ==(Object other) =>
    other is FacialData &&
    other.data == data &&
    other.individual == individual;
}

class FacePicture {
  Uint8List faceJpeg;
  Individual individual;

  FacePicture({
    required this.faceJpeg,
    required this.individual,
  });

  @override
  int get hashCode => Object.hash(individual, faceJpeg);

  @override
  bool operator ==(Object other) =>
    other is FacePicture &&
    other.individual == individual &&
    other.faceJpeg == faceJpeg;
}

class Student {
  String registration;
  Individual individual;

  Student({
    required this.registration,
    required this.individual,
  });

  @override
  int get hashCode => Object.hash(registration, individual);

  @override
  bool operator ==(Object other) =>
    other is Student &&
    other.registration == registration &&
    other.individual == individual;
}

class Teacher {
  String registration;
  Individual individual;

  Teacher({
    required this.registration,
    required this.individual,
  });

  @override
  int get hashCode => Object.hash(registration, individual);

  @override
  bool operator ==(Object other) =>
    other is Teacher &&
    other.registration == registration &&
    other.individual == individual;
}

class Subject {
  String code;
  String name;

  Subject({
    required this.code,
    required this.name,
  });

  @override
  int get hashCode => Object.hash(code, name);

  @override
  bool operator ==(Object other) =>
    other is Subject &&
    other.code == code &&
    other.name == name;
}

class SubjectClass {
  Subject subject;
  int year;
  int semester;
  String name;
  Teacher teacher;

  SubjectClass({
    required this.subject,
    required this.year,
    required this.semester,
    required this.name,
    required this.teacher,
  });

  @override
  int get hashCode => Object.hash(subject, year, semester, name, teacher);

  @override
  bool operator ==(Object other) =>
    other is SubjectClass &&
    other.subject == subject &&
    other.year == year &&
    other.semester == semester &&
    other.name ==name &&
    other.teacher == teacher;
}

class Lesson {
  SubjectClass subjectClass;
  DateTime utcDateTime;
  Teacher teacher;

  Lesson({
    required this.subjectClass,
    required this.utcDateTime,
    required this.teacher,
  });

  @override
  int get hashCode => Object.hash(subjectClass, utcDateTime, teacher);

  @override
  bool operator ==(Object other) =>
    other is Lesson &&
    other.subjectClass == subjectClass &&
    other.utcDateTime == utcDateTime &&
    other.teacher == teacher;
}

class Enrollment {
  Student student;
  SubjectClass subjectClass;

  Enrollment({
    required this.student,
    required this.subjectClass,
  });

  @override
  int get hashCode => Object.hash(student, subjectClass);

  @override
  bool operator ==(Object other) =>
    other is Enrollment &&
    other.student == student &&
    other.subjectClass == subjectClass;
}

class Attendance {
  Student student;
  Lesson lesson;

  Attendance({
    required this.student,
    required this.lesson,
  });

  @override
  int get hashCode => Object.hash(student, lesson);

  @override
  bool operator ==(Object other) =>
    other is Attendance &&
    other.student == student &&
    other.lesson == lesson;
}

class DomainRepository {
  DomainRepository();

  final Set<Individual> _individual = {};
  final Set<FacialData> _facialData = {};
  final Set<FacePicture> _facePicture = {};
  final Set<Student> _student = {};
  final Set<Teacher> _teacher = {};
  final Set<Subject> _subject = {};
  final Set<SubjectClass> _subjectClass = {};
  final Set<Lesson> _lesson = {};
  final Set<Enrollment> _enrollment = {};
  final Set<Attendance> _attendance = {};
  // ---
  final Map<Lesson, List<Duple<Uint8List, FaceEmbedding>>> _faceEmbeddingDeferredPool = {};
  final Map<Lesson, List<EmbeddingRecognitionResult>> _faceRecognizedFromCamera = {};
  final Map<Lesson, List<EmbeddingRecognitionResult>> _faceNotRecognizedFromCamera = {};
// ---------------------------

  void addIndividual(
    final Iterable<Individual> individual,
  ) {
    _individual.addAll(individual);
  }
  void addFacialData(
    final Iterable<FacialData> facialData,
  ) {
    _facialData.addAll(facialData);
  }
  void addFacePicture(
    final Iterable<FacePicture> facePicture,
  ) {
    _facePicture.addAll(facePicture);
  }
  void addStudent(
    final Iterable<Student> student,
  ) {
    _student.addAll(student);
  }
  void addTeacher(
    final Iterable<Teacher> teacher,
  ) {
    _teacher.addAll(teacher);
  }
  void addSubject(
    final Iterable<Subject> subject,
  ) {
    _subject.addAll(subject);
  }
  void addSubjectClass(
    final Iterable<SubjectClass> subjectClass,
  ) {
    _subjectClass.addAll(subjectClass);
  }
  void addLesson(
    final Iterable<Lesson> lesson,
  ) {
    _lesson.addAll(lesson);
  }
  void addEnrollment(
    final Iterable<Enrollment> enrollment,
  ) {
    _enrollment.addAll(enrollment);
  }
  void addAttendance(
    final Iterable<Attendance> attendance,
  ) {
    _attendance.addAll(attendance);
  }
  // ---
  void addFaceEmbeddingToDeferredPool(
    final Iterable<Duple<Uint8List, FaceEmbedding>> embedding,
    final Lesson lesson,
  ) {
    _faceEmbeddingDeferredPool.putIfAbsent(lesson, () => []);
    _faceEmbeddingDeferredPool[lesson]!.addAll(embedding);
  }
  void addFaceEmbeddingToCameraRecognized(
    Iterable<EmbeddingRecognitionResult> recognized,
    Lesson lesson,
  ) {
    _faceRecognizedFromCamera.putIfAbsent(lesson, () => []);
    _faceRecognizedFromCamera[lesson]!.addAll(recognized);
  }
  void removeFaceEmbeddingRecognizedFromCamera(
    Iterable<EmbeddingRecognitionResult> recognition,
    Lesson lesson,
  ) {
    final recognizedAtLesson = _faceRecognizedFromCamera[lesson];
    if (recognizedAtLesson == null) {
      return;
    }
    for (final r in recognition) {
      recognizedAtLesson.remove(r);
    }
  }
  void addFaceEmbeddingToCameraNotRecognized(
    Iterable<EmbeddingRecognitionResult> notRecognized,
    Lesson lesson,
  ) {
    _faceNotRecognizedFromCamera.putIfAbsent(lesson, () => []);
    _faceNotRecognizedFromCamera[lesson]!.addAll(notRecognized);
  }
  void removeFaceEmbeddingNotRecognizedFromCamera(
    Iterable<EmbeddingRecognitionResult> recognition,
    Lesson lesson,
  ) {
    final notRecognizedAtLesson = _faceNotRecognizedFromCamera[lesson];
    if (notRecognizedAtLesson == null) {
      return;
    }
    for (final r in recognition) {
      notRecognizedAtLesson.remove(r);
    }
  }
  void replaceRecordOfRecognitionResultFromCamera(
    EmbeddingRecognitionResult oldRecord,
    EmbeddingRecognitionResult newRecord,
    Lesson lesson,
  ) {
    // avoid edge cases where there is no entry in that lesson
    _faceNotRecognizedFromCamera.putIfAbsent(lesson, () => []);
    _faceRecognizedFromCamera.putIfAbsent(lesson, () => []);

    List<EmbeddingRecognitionResult> originList;
    if (oldRecord.recognized) {
      originList = _faceRecognizedFromCamera[lesson]!;
    } else {
      originList = _faceNotRecognizedFromCamera[lesson]!;
    }
    List<EmbeddingRecognitionResult> destinationList;
    if (newRecord.recognized) {
      destinationList = _faceRecognizedFromCamera[lesson]!;
    } else {
      destinationList = _faceNotRecognizedFromCamera[lesson]!;
    }

    final indexAtOrigin = originList.indexOf(oldRecord);
    // maintain entry at same location
    if (originList == destinationList && indexAtOrigin >= 0) {
      originList.replaceRange(indexAtOrigin, indexAtOrigin + 1, [newRecord]);
    } else {
      originList.removeAt(indexAtOrigin);
      destinationList.add(newRecord);
    }
  }
  // ---------------------------

  Map<String, Individual?> getIndividualFromRegistration(
    final Iterable<String> individualRegistration,
  ) {
    final result = <String, Individual?>{ for (final iR in individualRegistration) iR : null };
    for (final i in _individual) {
      for (final reg in individualRegistration) {
        if (reg == i.individualRegistration) {
          result[reg] = i;
        }
      }
    }
    return result;
  }
  Map<SubjectClass, List<Student>> getStudentFromSubjectClass(
    final Iterable<SubjectClass> subjectClass,
  ) {
    final result = { for (final sc in subjectClass) sc : <Student>[] };
    for (final e in _enrollment) {
      for (final sc in subjectClass) {
        if (e.subjectClass == sc) {
          result[sc]?.add(e.student);
        }
      }
    }
    return result;
  }
  Map<Student, List<FacialData>> getFacialDataFromStudent(
    final Iterable<Student> student,
  ) {
    final result = { for (final s in student) s : <FacialData>[] };
    for (final fd in _facialData) {
      for (final s in student) {
        if (s.individual == fd.individual) {
          result[s]?.add(fd);
        }
      }
    }
    return result;
  }
    Map<Student, FacePicture?> getFacePictureFromStudent(
    final Iterable<Student> student,
  ) {
    final result = <Student, FacePicture?>{ for (final s in student) s : null };
    for (final fp in _facePicture) {
      for (final s in student) {
        if (s.individual == fp.individual) {
          result[s] = fp;
        }
      }
    }
    return result;
  }
  Map<Teacher, FacePicture?> getFacePictureFromTeacher(
    final Iterable<Teacher> teacher,
  ) {
    final result = <Teacher, FacePicture?>{ for (final t in teacher) t : null };
    for (final fp in _facePicture) {
      for (final t in teacher) {
        if (t.individual == fp.individual) {
          result[t] = fp;
        }
      }
    }
    return result;
  }
  Map<String, Student?> getStudentFromRegistration(
    final Iterable<String> registration,
  ) {
    final result = <String, Student?>{ for (final r in registration) r : null };
    for (final s in _student) {
      for (final reg in registration) {
        if (reg == s.registration) {
          result[reg] = s;
        }
      }
    }
    return result;
  }
  Map<Teacher, List<FacialData>> getFacialDataFromTeacher(
    final Iterable<Teacher> teacher,
  ) {
    final result = { for (final t in teacher) t : <FacialData>[] };
    for (final fd in _facialData) {
      for (final t in teacher) {
        if (t.individual == fd.individual) {
          result[t]?.add(fd);
        }
      }
    }
    return result;
  }
  Map<String, Teacher?> getTeacherFromRegistration(
    final Iterable<String> registration,
  ) {
    final result = <String, Teacher?>{ for (final reg in registration) reg : null };
    for (final t in _teacher) {
      for (final reg in registration) {
        if (reg == t.registration) {
          result[reg] = t;
        }
      }
    }
    return result;
  }
  Map<SubjectClass, Map<Student, List<Attendance>>> getSubjectClassAttendance(
    final Iterable<SubjectClass> subjectClass,
  ) {
    final studentBySubjectClass = getStudentFromSubjectClass(subjectClass);

    final result = {
      for (final sSC in studentBySubjectClass.entries) sSC.key : {
        for (final s in sSC.value) s : <Attendance>[
          for (final a in _attendance) if (a.student == s) a
        ]
      }
    };
    return result;
  }
  Map<SubjectClass, List<Lesson>> getLessonFromSubjectClass(
    Iterable<SubjectClass> subjectClass
  ) {
    final result = <SubjectClass, List<Lesson>>{ for (final sc in subjectClass) sc : [] };
    for (final sc in subjectClass) {
      for (final l in _lesson) {
        if (l.subjectClass == sc) {
          result[sc]?.add(l);
        }
      }
    }
    return result;
  }
  // TODO
  Map<String, Subject?> getSubjectFromCode(
    Iterable<String> code,
  ) {
    final result = <String, Subject?>{ for (final c in code) c : null };
    for (final s in _subject) {
      for (final c in code) {
        if (c == s.code) {
          result[c] = s;
        }
      }
    }
    return result;
  }

  List<Subject> getAllSubjects() {
    return _subject.toList(growable: false);
  }

  Map<Subject, List<SubjectClass>> getSubjectClassFromSubject(
    Iterable<Subject> subject,
  ) {
    final result = <Subject, List<SubjectClass>>{ for (final s in subject) s : [] };
    for (final sC in _subjectClass) {
      for (final s in subject) {
        if (s == sC.subject) {
          result[s]!.add(sC);
        }
      }
    }
    return result;
  }

  // ---
  Map<Lesson, Iterable<Duple<Uint8List, FaceEmbedding>>> getDeferredFacesEmbedding(Iterable<Lesson>? lesson) {
    final Map<Lesson, Iterable<Duple<Uint8List, FaceEmbedding>>>result;
    if (lesson == null) {
      result = {
        for (final l in _faceEmbeddingDeferredPool.keys)
          l : _faceEmbeddingDeferredPool[l]!.toList(growable: false)
      };
    }
    else {
      result = {
        for (final l in lesson)
          l : _faceEmbeddingDeferredPool[l]?.toList(growable: false) ?? []
      };
    }
    return result;
  }
  Map<Lesson, Iterable<EmbeddingRecognitionResult>> getCameraRecognized(
    Iterable<Lesson>? lesson,
  ) {
    final Map<Lesson, Iterable<EmbeddingRecognitionResult>> result;
    if (lesson == null) {
      result = {
        for (final l in _faceRecognizedFromCamera.keys)
          l : _faceRecognizedFromCamera[l]!.toList(growable: false)
      };
    }
    else {
      result = {
        for (final l in lesson)
          l : _faceRecognizedFromCamera[l]?.toList(growable: false) ?? []
      };
    }
    return result;
  }
  Map<Lesson, Iterable<EmbeddingRecognitionResult>> getCameraNotRecognized(
    Iterable<Lesson>? lesson,
  ) {
    final Map<Lesson, Iterable<EmbeddingRecognitionResult>> result;
    if (lesson == null) {
      result = {
        for (final l in _faceNotRecognizedFromCamera.keys)
          l : _faceNotRecognizedFromCamera[l]!.toList(growable: false)
      };
    }
    else {
      result = {
        for (final l in lesson)
          l : _faceNotRecognizedFromCamera[l]?.toList(growable: false) ?? []
      };
    }
    return result;
  }
}

class DomainRepositoryForTests extends DomainRepository {
  factory DomainRepositoryForTests() {
    final d = DomainRepositoryForTests._private();

    final individuals = List<Individual>.unmodifiable(<Individual>[
      Individual(individualRegistration: 'cpf0', name: 'Individuo1'),
    ]);
    final facialsData = List<FacialData>.unmodifiable(<FacialData>[]);
    final students = List<Student>.unmodifiable(<Student>[]);
    final teachers = List<Teacher>.unmodifiable(<Teacher>[
      Teacher(registration: 'tReg0', individual: individuals[0]),
    ]);
    final subjects = List<Subject>.unmodifiable(<Subject>[
      Subject(code: 'sCode0', name: 'Materia para teste'),
    ]);
    final subjectClasses = List<SubjectClass>.unmodifiable(<SubjectClass>[
      SubjectClass(
        subject: subjects[0],
        year: 2024,
        semester: 01,
        name: 'Turma A da materia para teste',
        teacher: teachers[0],
      )
    ]);
    final lessons = List<Lesson>.unmodifiable(<Lesson>[
      Lesson(
        subjectClass: subjectClasses[0],
        utcDateTime: DateTime(2024, 01, 01, 07, 00),
        teacher: teachers[0],
      ),
    ]);
    final enrollments = List<Enrollment>.unmodifiable(<Enrollment>[]);
    final attendances = List<Attendance>.unmodifiable(<Attendance>[]);

    d.addIndividual(individuals);
    d.addFacialData(facialsData);
    d.addStudent(students);
    d.addTeacher(teachers);
    d.addSubject(subjects);
    d.addSubjectClass(subjectClasses);
    d.addLesson(lessons);
    d.addEnrollment(enrollments);
    d.addAttendance(attendances);

    return d;
  }

  DomainRepositoryForTests._private();
}
