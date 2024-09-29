import 'dart:typed_data';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:sqlite3/sqlite3.dart' as pkg_sqlite3;
import 'package:crypto/crypto.dart' as pkg_crypto;

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

typedef JpegPictureBytes = Uint8List;

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

class DomainRepository  implements IDomainRepository {
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

  @override
  void addIndividual(
    final Iterable<Individual> individual,
  ) {
    _individual.addAll(individual);
  }
  @override
  void addFacialData(
    final Iterable<FacialData> facialData,
  ) {
    _facialData.addAll(facialData);
  }
  @override
  void addFacePicture(
    final Iterable<FacePicture> facePicture,
  ) {
    _facePicture.addAll(facePicture);
  }
  @override
  void addStudent(
    final Iterable<Student> student,
  ) {
    _student.addAll(student);
  }
  @override
  void addTeacher(
    final Iterable<Teacher> teacher,
  ) {
    _teacher.addAll(teacher);
  }
  @override
  void addSubject(
    final Iterable<Subject> subject,
  ) {
    _subject.addAll(subject);
  }
  @override
  void addSubjectClass(
    final Iterable<SubjectClass> subjectClass,
  ) {
    _subjectClass.addAll(subjectClass);
  }
  @override
  void addLesson(
    final Iterable<Lesson> lesson,
  ) {
    _lesson.addAll(lesson);
  }
  @override
  void addEnrollment(
    final Iterable<Enrollment> enrollment,
  ) {
    _enrollment.addAll(enrollment);
  }
  @override
  void addAttendance(
    final Iterable<Attendance> attendance,
  ) {
    _attendance.addAll(attendance);
  }
  // ---
  @override
  void addFaceEmbeddingToDeferredPool(
    final Iterable<Duple<Uint8List, FaceEmbedding>> embedding,
    final Lesson lesson,
  ) {
    _faceEmbeddingDeferredPool.putIfAbsent(lesson, () => []);
    _faceEmbeddingDeferredPool[lesson]!.addAll(embedding);
  }
  @override
  void addFaceEmbeddingToCameraRecognized(
    Iterable<EmbeddingRecognitionResult> recognized,
    Lesson lesson,
  ) {
    _faceRecognizedFromCamera.putIfAbsent(lesson, () => []);
    _faceRecognizedFromCamera[lesson]!.addAll(recognized);
  }
  @override
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
  @override
  void addFaceEmbeddingToCameraNotRecognized(
    Iterable<EmbeddingRecognitionResult> notRecognized,
    Lesson lesson,
  ) {
    _faceNotRecognizedFromCamera.putIfAbsent(lesson, () => []);
    _faceNotRecognizedFromCamera[lesson]!.addAll(notRecognized);
  }
  @override
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
  @override
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

  @override
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
  @override
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
  @override
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
    @override
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
  @override
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
  @override
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
  @override
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
  @override
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
  @override
  SubjectClass? getSubjectClass({
    required int year,
    required int semester,
    required String subjectCode,
    required String name,
  }) {
    for (final sC in _subjectClass) {
      if (sC.year == year &&
          sC.semester == semester &&
          sC.subject.code == subjectCode &&
          sC.name == name
      ) {
        return sC;
      }
    }
    return null;
  }
  @override
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
  @override
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
  @override
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

  @override
  List<Subject> getAllSubjects() {
    return _subject.toList(growable: false);
  }

  @override
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
  @override
  Map<Lesson, Iterable<Duple<Uint8List, FaceEmbedding>>>
      getDeferredFacesEmbedding(
    Iterable<Lesson> lesson,
  ) {
    final Map<Lesson, Iterable<Duple<Uint8List, FaceEmbedding>>>result;
    // if (lesson == null) {
    //   result = {
    //     for (final l in _faceEmbeddingDeferredPool.keys)
    //       l : _faceEmbeddingDeferredPool[l]!.toList(growable: false)
    //   };
    // }
    // else {
      result = {
        for (final l in lesson)
          l : _faceEmbeddingDeferredPool[l]?.toList(growable: false) ?? []
      };
    // }
    return result;
  }
  @override
  Map<Lesson, Iterable<EmbeddingRecognitionResult>> getCameraRecognized(
    Iterable<Lesson> lesson,
  ) {
    final Map<Lesson, Iterable<EmbeddingRecognitionResult>> result;
    // if (lesson == null) {
    //   result = {
    //     for (final l in _faceRecognizedFromCamera.keys)
    //       l : _faceRecognizedFromCamera[l]!.toList(growable: false)
    //   };
    // }
    // else {
      result = {
        for (final l in lesson)
          l : _faceRecognizedFromCamera[l]?.toList(growable: false) ?? []
      };
    // }
    return result;
  }
  @override
  Map<Lesson, Iterable<EmbeddingRecognitionResult>> getCameraNotRecognized(
    Iterable<Lesson> lesson,
  ) {
    final Map<Lesson, Iterable<EmbeddingRecognitionResult>> result;
    // if (lesson == null) {
    //   result = {
    //     for (final l in _faceNotRecognizedFromCamera.keys)
    //       l : _faceNotRecognizedFromCamera[l]!.toList(growable: false)
    //   };
    // }
    // else {
      result = {
        for (final l in lesson)
          l : _faceNotRecognizedFromCamera[l]?.toList(growable: false) ?? []
      };
    // }
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
      Subject(code: 'sC0', name: 'Materia para teste'),
    ]);
    final subjectClasses = List<SubjectClass>.unmodifiable(<SubjectClass>[
      SubjectClass(
        subject: subjects[0],
        year: 2024,
        semester: 01,
        name: 'a0',
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

class SQLite3DomainRepository implements IDomainRepository {
  final pkg_sqlite3.Database _database;
  final SqlStatementsLoader _statementsLoader;

  SQLite3DomainRepository({
    required final String databasePath,
    required final SqlStatementsLoader statementsLoader,
  })  : _database = pkg_sqlite3.sqlite3.open(databasePath),
        _statementsLoader = statementsLoader {
    _createDatabase();
  }

  void _beginTransaction()    => _database.execute('BEGIN TRANSACTION;');
  void _commitTransaction()    => _database.execute('COMMIT TRANSACTION;');
  void _rollbackTransaction() => _database.execute('ROLLBACK TRANSACTION;');

  void _createDatabase() {
    final statements = _statementsLoader.getStatements([
      ['individual','ddl','create'],
      ['facialData','ddl','create'],
      ['facePicture','ddl','create'],
      ['student','ddl','create'],
      ['teacher','ddl','create'],
      ['subject','ddl','create'],
      ['class','ddl','create'],
      ['lesson','ddl','create'],
      ['enrollment','ddl','create'],
      ['attendance','ddl','create'],
    ]);
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final statement in statements) {
        _database.execute(statement);
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addAttendance(Iterable<Attendance> attendance) {
    final insertAttendace = _database.prepare(
      _statementsLoader.getStatement(['attendance', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in attendance) {
        insertAttendace.executeMap({
          ':subjectCode': element.lesson.subjectClass.subject.code,
          ':year': element.lesson.subjectClass.year,
          ':semester': element.lesson.subjectClass.semester,
          ':name': element.lesson.subjectClass.name,
          ':utcDateTime': element.lesson.utcDateTime,
          ':studentRegisration': element.student.registration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertAttendace.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addEnrollment(Iterable<Enrollment> enrollment) {
    final insertEnrollment = _database.prepare(
      _statementsLoader.getStatement(['enrollment', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in enrollment) {
        insertEnrollment.executeMap({
          ':subjectCode': element.subjectClass.subject.code,
          ':year': element.subjectClass.year,
          ':semester': element.subjectClass.semester,
          ':name': element.subjectClass.name,
          ':studentRegisration': element.student.registration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertEnrollment.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addFaceEmbeddingToCameraNotRecognized(Iterable<EmbeddingRecognitionResult> notRecognized, Lesson lesson) {
    final insert = _database.prepare(
      _statementsLoader
          .getStatement(['notRecognizedFromCamera', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (var element in notRecognized) {
        final pictureMd5 = pkg_crypto.md5.convert(element.inputFace.buffer.asUint8List());
        insert.executeMap({
          ':subjectCode': lesson.subjectClass.subject.code,
          ':year': lesson.subjectClass.year,
          ':semester': lesson.subjectClass.semester,
          ':name': lesson.subjectClass.name,
          ':utcDateTime': lesson.utcDateTime,
          ':picture': element.inputFace,
          ':pictureMd5': pictureMd5,
          ':embedding': element.inputFaceEmbedding,
          ':nearestStudentRegistration': element.nearestStudent?.registration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insert.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addFaceEmbeddingToCameraRecognized(Iterable<EmbeddingRecognitionResult> recognized, Lesson lesson) {
    final insert = _database.prepare(
      _statementsLoader
          .getStatement(['recognizedFromCamera', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (var element in recognized) {
        final pictureMd5 = pkg_crypto.md5.convert(element.inputFace.buffer.asUint8List());
        insert.executeMap({
          ':subjectCode': lesson.subjectClass.subject.code,
          ':year': lesson.subjectClass.year,
          ':semester': lesson.subjectClass.semester,
          ':name': lesson.subjectClass.name,
          ':utcDateTime': lesson.utcDateTime,
          ':picture': element.inputFace,
          ':pictureMd5': pictureMd5,
          ':embedding': element.inputFaceEmbedding,
          ':nearestStudentRegistration': element.nearestStudent?.registration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insert.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addFaceEmbeddingToDeferredPool(Iterable<Duple<JpegPictureBytes, FaceEmbedding>> embedding, Lesson lesson) {
    final insert = _database.prepare(
      _statementsLoader
          .getStatement(['deferredRecognitionPool', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (var element in embedding) {
        final pictureMd5 = pkg_crypto.md5.convert(element.value1.buffer.asUint8List());
        insert.executeMap({
          ':subjectCode': lesson.subjectClass.subject.code,
          ':year': lesson.subjectClass.year,
          ':semester': lesson.subjectClass.semester,
          ':name': lesson.subjectClass.name,
          ':utcDateTime': lesson.utcDateTime,
          ':picture': element.value1,
          ':pictureMd5': pictureMd5,
          ':embedding': element.value2,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insert.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addFacePicture(Iterable<FacePicture> facePicture) {
    final insertFacePicture = _database.prepare(
      _statementsLoader.getStatement(['facePicture', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in facePicture) {
        insertFacePicture.executeMap({
          ':picture': element.faceJpeg,
          ':individualRegisration': element.individual.individualRegistration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertFacePicture.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addFacialData(Iterable<FacialData> facialData) {
    final insertFacialData = _database.prepare(
      _statementsLoader.getStatement(['facialData', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in facialData) {
        insertFacialData.executeMap({
          ':data': element.data,
          ':individualRegisration': element.individual.individualRegistration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertFacialData.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addIndividual(Iterable<Individual> individual) {
    final insertIndividual = _database.prepare(
      _statementsLoader.getStatement(['individual', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in individual) {
        insertIndividual.executeMap({
          ':individualRegisration': element.individualRegistration,
          ':name': element.name,
          ':surname': element.surname,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertIndividual.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addLesson(Iterable<Lesson> lesson) {
    final insertLesson = _database.prepare(
      _statementsLoader.getStatement(['lesson', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in lesson) {
        insertLesson.executeMap({
          ':subjectCode': element.subjectClass.subject.code,
          ':year': element.subjectClass.year,
          ':semester': element.subjectClass.semester,
          ':name': element.subjectClass.name,
          ':utcDateTime': element.utcDateTime,
          ':teacherRegistration': element.teacher.registration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertLesson.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addStudent(Iterable<Student> student) {
    final insertStudent = _database.prepare(
      _statementsLoader.getStatement(['student', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in student) {
        insertStudent.executeMap({
          ':registration': element.registration,
          ':individualRegistration': element.individual.individualRegistration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertStudent.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addSubject(Iterable<Subject> subject) {
    final insertSubject = _database.prepare(
      _statementsLoader.getStatement(['subject', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in subject) {
        insertSubject.executeMap({
          ':code': element.code,
          ':name': element.name,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertSubject.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addSubjectClass(Iterable<SubjectClass> subjectClass) {
    final insertClass = _database.prepare(
      _statementsLoader.getStatement(['class', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in subjectClass) {
        insertClass.executeMap({
          ':subjectCode': element.subject.code,
          ':year': element.year,
          ':semester': element.semester,
          ':name': element.name,
          ':teacherRegistration': element.teacher.registration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertClass.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  void addTeacher(Iterable<Teacher> teacher) {
    final insertTeacher = _database.prepare(
      _statementsLoader.getStatement(['teacher', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in teacher) {
        insertTeacher.executeMap({
          ':registration': element.registration,
          ':individualRegistration': element.individual.individualRegistration,
        });
      }
    }
    on ArgumentError catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      errorOrException = e;
      shouldCommit = false;
    }
    finally {
      insertTeacher.dispose();
    }

    if (shouldCommit) {
      _commitTransaction();
    }
    else {
      projectLogger.severe(errorOrException);
      _rollbackTransaction();
    }
  }

  @override
  List<Subject> getAllSubjects() {
    final select = _database.prepare(
      _statementsLoader.getStatement(['dql', 'allSubjects']),
    );

    try {
      final selectedSet = select.select();
      final aux = selectedSet.map(
            (e) => Subject(code: e['code'], name: e['name']),
          )
          .toList(growable: false);
      return aux;
    }
    on ArgumentError catch (e) {
      projectLogger.severe(e);
    }
    on pkg_sqlite3.SqliteException catch (e) {
      projectLogger.severe(e);
    }
    finally {
      select.dispose();
    }
    return List.empty(growable: false);
  }

  @override
  Map<Lesson, Iterable<EmbeddingRecognitionResult>> getCameraNotRecognized(
    Iterable<Lesson> lesson,
  ) {
    final Map<Lesson, Iterable<EmbeddingRecognitionResult>> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'notRecognizedFromCameraByLesson'],
      ),
    );

    for (final l in lesson) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectMap({
          ':subjectCode': l.subjectClass.subject.code,
          ':year': l.subjectClass.year,
          ':semester': l.subjectClass.semester,
          ':name': l.subjectClass.name,
          ':utcDateTime': l.utcDateTime,
        });
      }
      on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }
      on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      // final Map<String, Student> students = {};
      // for (final row in selected) {
      //   final String? registration = row['registration'];
      //   if (registration != null && !students.containsKey(registration)) {
      //     students[registration] = Student(
      //       registration: registration,
      //       individual: Individual(
      //         individualRegistration: row['individualRegistration'],
      //         name: row['name'],
      //         surname: row['surname'],
      //       ),
      //     );
      //   }
      // }

      final Map<String, Student> students = {};
      final resultValue = selected
          .map(
            (e) => EmbeddingRecognitionResult(
              inputFace: e['picture'],
              inputFaceEmbedding: e['embedding'],
              recognized: false,
              // nearestStudent: students['nearestStudentRegistration'],
              nearestStudent: e['registration'] == null
                  ? null
                  : students.putIfAbsent(
                      e['registration'],
                      () => Student(
                        registration: e['registration'],
                        individual: Individual(
                          individualRegistration: e['individualRegistration'],
                          name: e['name'],
                          surname: e['surname'],
                        ),
                      ),
                    ),
            ),
          )
          .toList(growable: false);
      result[l] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Lesson, Iterable<EmbeddingRecognitionResult>> getCameraRecognized(
    Iterable<Lesson> lesson,
  ) {
    final Map<Lesson, Iterable<EmbeddingRecognitionResult>> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'recognizedFromCameraByLesson'],
      ),
    );

    for (final l in lesson) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectMap({
          ':subjectCode': l.subjectClass.subject.code,
          ':year': l.subjectClass.year,
          ':semester': l.subjectClass.semester,
          ':name': l.subjectClass.name,
          ':utcDateTime': l.utcDateTime,
        });
      }
      on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable(const {});
      }
      on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable(const {});
      }

      // final Map<String, Student> students = {};
      // for (final row in selected) {
      //   final String? registration = row['nearestStudentRegistration'];
      //   if (registration != null && !students.containsKey(registration)) {
      //     students[registration] = Student(
      //       registration: registration,
      //       individual: Individual(
      //         individualRegistration: row['individualRegistration'],
      //         name: row['name'],
      //         surname: row['surname'],
      //       ),
      //     );
      //   }
      // }

      final Map<String, Student> students = {};
      final resultValue = selected
          .map(
            (e) => EmbeddingRecognitionResult(
              inputFace: e['picture'],
              inputFaceEmbedding: e['embedding'],
              recognized: false,
              // nearestStudent: students['nearestStudentRegistration'],
              nearestStudent: e['registration'] == null
                  ? null
                  : students.putIfAbsent(
                      e['registration'],
                      () => Student(
                        registration: e['registration'],
                        individual: Individual(
                          individualRegistration: e['individualRegistration'],
                          name: e['name'],
                          surname: e['surname'],
                        ),
                      ),
                    ),
            ),
          )
          .toList(growable: false);
      result[l] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Lesson, Iterable<Duple<JpegPictureBytes, FaceEmbedding>>> getDeferredFacesEmbedding(
    Iterable<Lesson> lesson,
  ) {
    final Map<Lesson, Iterable<Duple<JpegPictureBytes, FaceEmbedding>>> result =
        {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'deferredRecognitionPoolByLesson'],
      ),
    );

    for (final l in lesson) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectMap({
          ':subjectCode': l.subjectClass.subject.code,
          ':year': l.subjectClass.year,
          ':semester': l.subjectClass.semester,
          ':name': l.subjectClass.name,
          ':utcDateTime': l.utcDateTime,
        });
      } on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      } on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      final resultValue = selected
          .map(
            (e) => Duple<JpegPictureBytes, FaceEmbedding>(
              e['picture'],
              e['embedding'],
            ),
          )
          .toList(growable: false);
      result[l] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Student, FacePicture?> getFacePictureFromStudent(
    Iterable<Student> student,
  ) {
    final Map<Lesson, FacePicture> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'deferredRecognitionPoolByLesson'],
      ),
    );

    for (final l in student) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectMap({
          ':subjectCode': l.subjectClass.subject.code,
          ':year': l.subjectClass.year,
          ':semester': l.subjectClass.semester,
          ':name': l.subjectClass.name,
          ':utcDateTime': l.utcDateTime,
        });
      } on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      } on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      final resultValue = selected
          .map(
            (e) => Duple<JpegPictureBytes, FaceEmbedding>(
              e['picture'],
              e['embedding'],
            ),
          )
          .toList(growable: false);
      result[l] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Teacher, FacePicture?> getFacePictureFromTeacher(Iterable<Teacher> teacher) {
    // TODO: implement getFacePictureFromTeacher
    throw UnimplementedError();
  }

  @override
  Map<Student, List<FacialData>> getFacialDataFromStudent(Iterable<Student> student) {
    // TODO: implement getFacialDataFromStudent
    throw UnimplementedError();
  }

  @override
  Map<Teacher, List<FacialData>> getFacialDataFromTeacher(Iterable<Teacher> teacher) {
    // TODO: implement getFacialDataFromTeacher
    throw UnimplementedError();
  }

  @override
  Map<String, Individual?> getIndividualFromRegistration(Iterable<String> individualRegistration) {
    // TODO: implement getIndividualFromRegistration
    throw UnimplementedError();
  }

  @override
  Map<SubjectClass, List<Lesson>> getLessonFromSubjectClass(Iterable<SubjectClass> subjectClass) {
    // TODO: implement getLessonFromSubjectClass
    throw UnimplementedError();
  }

  @override
  Map<String, Student?> getStudentFromRegistration(Iterable<String> registration) {
    // TODO: implement getStudentFromRegistration
    throw UnimplementedError();
  }

  @override
  Map<SubjectClass, List<Student>> getStudentFromSubjectClass(Iterable<SubjectClass> subjectClass) {
    // TODO: implement getStudentFromSubjectClass
    throw UnimplementedError();
  }

  @override
  SubjectClass? getSubjectClass({required int year, required int semester, required String subjectCode, required String name}) {
    // TODO: implement getSubjectClass
    throw UnimplementedError();
  }

  @override
  Map<SubjectClass, Map<Student, List<Attendance>>> getSubjectClassAttendance(Iterable<SubjectClass> subjectClass) {
    // TODO: implement getSubjectClassAttendance
    throw UnimplementedError();
  }

  @override
  Map<Subject, List<SubjectClass>> getSubjectClassFromSubject(Iterable<Subject> subject) {
    // TODO: implement getSubjectClassFromSubject
    throw UnimplementedError();
  }

  @override
  Map<String, Subject?> getSubjectFromCode(Iterable<String> code) {
    // TODO: implement getSubjectFromCode
    throw UnimplementedError();
  }

  @override
  Map<String, Teacher?> getTeacherFromRegistration(Iterable<String> registration) {
    // TODO: implement getTeacherFromRegistration
    throw UnimplementedError();
  }

  @override
  void removeFaceEmbeddingNotRecognizedFromCamera(Iterable<EmbeddingRecognitionResult> recognition, Lesson lesson) {
    // TODO: implement removeFaceEmbeddingNotRecognizedFromCamera
  }

  @override
  void removeFaceEmbeddingRecognizedFromCamera(Iterable<EmbeddingRecognitionResult> recognition, Lesson lesson) {
    // TODO: implement removeFaceEmbeddingRecognizedFromCamera
  }

  @override
  void replaceRecordOfRecognitionResultFromCamera(EmbeddingRecognitionResult oldRecord, EmbeddingRecognitionResult newRecord, Lesson lesson) {
    // TODO: implement replaceRecordOfRecognitionResultFromCamera
  }
}