import 'package:crypto/crypto.dart' as pkg_crypto;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/algorithms.dart';
import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:sqlite3/sqlite3.dart' as pkg_sqlite3;

class InMemoryDomainRepository  implements IDomainRepository {
  InMemoryDomainRepository();

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
  final Map<Lesson, List<({
    FaceEmbedding embedding,
    JpegPictureBytes face,
    DateTime utcDateTime
  })>> _faceEmbeddingDeferredPool = {};
  final Map<Lesson, List<EmbeddingRecognitionResult>> _faceRecognizedFromCamera = {};
  final Map<Lesson, List<EmbeddingRecognitionResult>> _faceNotRecognizedFromCamera = {};
// ---------------------------

  @override
  void dispose() {}

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
    final List<({
      FaceEmbedding embedding,
      JpegPictureBytes face,
      DateTime utcDateTime
    })> embedding,
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
  Map<Lesson, List<({FaceEmbedding embedding, JpegPictureBytes face, DateTime utcDateTime})>>
      getDeferredFacesEmbedding(
    Iterable<Lesson> lesson,
  ) {
    final Map<Lesson, List<({FaceEmbedding embedding, JpegPictureBytes face, DateTime utcDateTime})>>
        result;
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

class InMemoryDomainRepositoryForTests extends InMemoryDomainRepository {
  factory InMemoryDomainRepositoryForTests() {
    final d = InMemoryDomainRepositoryForTests._private();

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

  InMemoryDomainRepositoryForTests._private();
}

class SQLite3DomainRepository implements IDomainRepository {
  late final pkg_sqlite3.Database _database;
  final SqlStatementsLoader _statementsLoader;

  SQLite3DomainRepository({
    required final String databasePath,
    required final SqlStatementsLoader statementsLoader,
  })  : _database = pkg_sqlite3.sqlite3.open(databasePath),
        _statementsLoader = statementsLoader {

    _enforceForeignKeys();

    _createDatabase();
  }

  @override
  void dispose() {
    _database.dispose();
  }

  void _enforceForeignKeys()  => _database.execute('PRAGMA foreign_keys = ON;');
  void _beginTransaction()    => _database.execute('BEGIN TRANSACTION;');
  void _commitTransaction()   => _database.execute('COMMIT TRANSACTION;');
  void _rollbackTransaction() => _database.execute('ROLLBACK TRANSACTION;');
  String _pictureMd5(JpegPictureBytes picture) => pkg_crypto.md5.convert(picture).toString();

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
      ['notRecognizedFromCamera','ddl','create'],
      ['recognizedFromCamera','ddl','create'],
      ['deferredRecognitionPool','ddl','create'],
    ]);

    _beginTransaction();
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
        insertAttendace.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': element.lesson.subjectClass.subject.code,
            ':year': element.lesson.subjectClass.year,
            ':semester': element.lesson.subjectClass.semester,
            ':name': element.lesson.subjectClass.name,
            ':lessonUtcDateTime': element.lesson.utcDateTime.toIso8601String(),
            ':studentRegistration': element.student.registration,
            ':attendanceUtcDateTime': element.utcDateTime.toIso8601String(),
          }),
        );
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
        insertEnrollment.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': element.subjectClass.subject.code,
            ':year': element.subjectClass.year,
            ':semester': element.subjectClass.semester,
            ':name': element.subjectClass.name,
            ':studentRegistration': element.student.registration,
          }),
        );
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
  void addFaceEmbeddingToCameraNotRecognized(
    Iterable<EmbeddingRecognitionResult> notRecognized,
    Lesson lesson,
  ) {
    final insert = _database.prepare(
      _statementsLoader
          .getStatement(['notRecognizedFromCamera', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (var element in notRecognized) {
        final pictureMd5 = _pictureMd5(element.inputFace);
        final embedding = listDoubleToBytes(element.inputFaceEmbedding);
        insert.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': lesson.subjectClass.subject.code,
            ':year': lesson.subjectClass.year,
            ':semester': lesson.subjectClass.semester,
            ':name': lesson.subjectClass.name,
            ':lessonUtcDateTime': lesson.utcDateTime.toIso8601String(),
            ':picture': element.inputFace,
            ':pictureMd5': pictureMd5,
            ':embedding': embedding,
            ':arriveUtcDateTime': element.utcDateTime.toIso8601String(),
            ':nearestStudentRegistration': element.nearestStudent?.registration,
          }),
        );
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
        final pictureMd5 = _pictureMd5(element.inputFace);
        final embedding = listDoubleToBytes(element.inputFaceEmbedding);
        insert.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': lesson.subjectClass.subject.code,
            ':year': lesson.subjectClass.year,
            ':semester': lesson.subjectClass.semester,
            ':name': lesson.subjectClass.name,
            ':lessonUtcDateTime': lesson.utcDateTime.toIso8601String(),
            ':picture': element.inputFace,
            ':pictureMd5': pictureMd5,
            ':embedding': embedding,
            ':arriveUtcDateTime': element.utcDateTime.toIso8601String(),
            ':nearestStudentRegistration': element.nearestStudent?.registration,
          }),
        );
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
  void addFaceEmbeddingToDeferredPool(
    final List<({
      FaceEmbedding embedding,
      JpegPictureBytes face,
      DateTime utcDateTime,
    })> embedding,
    Lesson lesson,
  ) {
    final insert = _database.prepare(
      _statementsLoader
          .getStatement(['deferredRecognitionPool', 'dml', 'insert']),
    );

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (var element in embedding) {
        final pictureMd5 = _pictureMd5(element.face);
        final embedding = listDoubleToBytes(element.embedding);
        insert.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': lesson.subjectClass.subject.code,
            ':year': lesson.subjectClass.year,
            ':semester': lesson.subjectClass.semester,
            ':name': lesson.subjectClass.name,
            ':lessonUtcDateTime': lesson.utcDateTime.toIso8601String(),
            ':picture': element.face,
            ':pictureMd5': pictureMd5,
            ':embedding': embedding,
            ':arriveUtcDateTime': element.utcDateTime.toIso8601String(),
          }),
        );
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
        insertFacePicture.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':picture': element.faceJpeg,
            ':individualRegistration':
                element.individual.individualRegistration,
          }),
        );
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
        final data = listDoubleToBytes(element.data);
        insertFacialData.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':data': data,
            ':individualRegistration':
                element.individual.individualRegistration,
          }),
        );
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
/*   final insertIndividual = _database.prepare(
'''INSERT INTO individual (
  individualRegistration, name, surname
) VALUES (
  :individualRegistration, :name, :surname
);'''
  ); */

    _beginTransaction();
    bool shouldCommit = true;
    dynamic errorOrException;
    try {
      for (final element in individual) {
        insertIndividual.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':individualRegistration': element.individualRegistration,
            ':name': element.name,
            ':surname': element.surname,
          }),
        );
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
        insertLesson.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': element.subjectClass.subject.code,
            ':year': element.subjectClass.year,
            ':semester': element.subjectClass.semester,
            ':name': element.subjectClass.name,
            ':utcDateTime': element.utcDateTime.toIso8601String(),
            ':teacherRegistration': element.teacher.registration,
          }),
        );
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
        insertStudent.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':registration': element.registration,
            ':individualRegistration':
                element.individual.individualRegistration,
          }),
        );
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
        insertSubject.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':code': element.code,
            ':name': element.name,
          }),
        );
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
        insertClass.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': element.subject.code,
            ':year': element.year,
            ':semester': element.semester,
            ':name': element.name,
            ':teacherRegistration': element.teacher.registration,
          }),
        );
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
        insertTeacher.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':registration': element.registration,
            ':individualRegistration':
                element.individual.individualRegistration,
          }),
        );
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
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': l.subjectClass.subject.code,
            ':year': l.subjectClass.year,
            ':semester': l.subjectClass.semester,
            ':name': l.subjectClass.name,
            ':utcDateTime': l.utcDateTime.toIso8601String(),
          }),
        );
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

      final Map<String, Student> students = {};
      final Map<String, DateTime> datesTimes = {};
      final resultValue = selected.map(
        (e) {
          final embedding = listBytesToDouble(e['embedding']);
          final kDateTime = e['utcDateTime'];
          final dateTime = datesTimes.putIfAbsent(
            kDateTime,
            () => DateTime.parse(kDateTime),
          );
          return EmbeddingRecognitionResult(
            inputFace: e['picture'],
            inputFaceEmbedding: embedding,
            recognized: false,
            utcDateTime: dateTime,
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
          );
        },
      ).toList(growable: false);
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
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': l.subjectClass.subject.code,
            ':year': l.subjectClass.year,
            ':semester': l.subjectClass.semester,
            ':name': l.subjectClass.name,
            ':utcDateTime': l.utcDateTime.toIso8601String(),
          }),
        );
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

      final Map<String, Student> students = {};
      final Map<String, DateTime> datesTimes = {};
      final resultValue = selected.map(
        (e) {
          final embedding = listBytesToDouble(e['embedding']);
          final kDateTime = e['utcDateTime'];
          final dateTime = datesTimes.putIfAbsent(
            kDateTime,
            () => DateTime.parse(kDateTime),
          );
          return EmbeddingRecognitionResult(
            inputFace: e['picture'],
            inputFaceEmbedding: embedding,
            recognized: true,
            utcDateTime: dateTime,
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
          );
        },
      ).toList(growable: false);
      result[l] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Lesson, List<({FaceEmbedding embedding, JpegPictureBytes face, DateTime utcDateTime})>>
      getDeferredFacesEmbedding(
    Iterable<Lesson> lesson,
  ) {
    final Map<Lesson, List<({FaceEmbedding embedding, JpegPictureBytes face, DateTime utcDateTime})>>
        result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'deferredRecognitionPoolByLesson'],
      ),
    );

    final Map<String, DateTime> datesTimes = {};
    for (final l in lesson) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': l.subjectClass.subject.code,
            ':year': l.subjectClass.year,
            ':semester': l.subjectClass.semester,
            ':name': l.subjectClass.name,
            ':utcDateTime': l.utcDateTime.toIso8601String(),
          }),
        );
      } on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      } on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      final resultValue = selected.map<({
        FaceEmbedding embedding,
        JpegPictureBytes face,
        DateTime utcDateTime
      })>(
        (e) {
          final embedding = listBytesToDouble(e['embedding']);
          final kDateTime = e['utcDateTime'];
          final dateTime = datesTimes.putIfAbsent(
            kDateTime,
            () => DateTime.parse(kDateTime),
          );
          return (
            face: e['picture'] as JpegPictureBytes,
            embedding: embedding,
            utcDateTime: dateTime,
          );
        },
      ).toList(growable: false);
      result[l] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Student, FacePicture?> getFacePictureFromStudent(
    Iterable<Student> student,
  ) {
    final Map<Student, FacePicture?> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'facePictureByStudentRegistration'],
      ),
    );

    final Map<String, Individual> individuals = {};
    for (final s in student) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':registration': s.registration,
          }),
        );
      } on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      } on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      if (selected.isEmpty) {
        result[s] = null;
      }
      else {
        if (selected.length > 1) {
          projectLogger.warning('more than 1 face picture related to the same student; proceeding with one;');
        }
        final row = selected[0];
        final resultValue = FacePicture(
          faceJpeg: row['picture'],
          individual: individuals.putIfAbsent(
            row['individualRegistration'],
            () => Individual(
              individualRegistration: row['individualRegistration'],
              name: row['name'],
              surname: row['surname'],
            ),
          ),
        );
        result[s] = resultValue;
      }
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Teacher, FacePicture?> getFacePictureFromTeacher(
    Iterable<Teacher> teacher,
  ) {
    final Map<Teacher, FacePicture?> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'facePictureByTeacherRegistration'],
      ),
    );

    final Map<String, Individual> individuals = {};
    for (final t in teacher) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':registration': t.registration,
          }),
        );
      } on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      } on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      if (selected.isEmpty) {
        result[t] = null;
      }
      else {
        if (selected.length > 1) {
          projectLogger.warning('more than 1 face picture related to the same student; proceeding with one;');
        }
        final row = selected[0];
        final resultValue = FacePicture(
          faceJpeg: row['picture'],
          individual: individuals.putIfAbsent(
            row['individualRegistration'],
            () => Individual(
              individualRegistration: row['individualRegistration'],
              name: row['name'],
              surname: row['surname'],
            ),
          ),
        );
        result[t] = resultValue;
      }
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Student, List<FacialData>> getFacialDataFromStudent(
    Iterable<Student> student,
  ) {
    final Map<Student, List<FacialData>> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'facialDataByStudentRegistration'],
      ),
    );

    final Map<String, Individual> individuals = {};
    for (final s in student) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':registration': s.registration,
          }),
        );
      } on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      } on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      final resultValue = selected.map(
        (e) {
          final data = listBytesToDouble(e['data']);
          return FacialData(
            data: data,
            individual: individuals.putIfAbsent(
              e['individualRegistration'],
              () => Individual(
                individualRegistration: e['individualRegistration'],
                name: e['name'],
                surname: e['surname'],
              ),
            ),
          );
        },
      ).toList(growable: false);
      result[s] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Teacher, List<FacialData>> getFacialDataFromTeacher(
    Iterable<Teacher> teacher,
  ) {
    final Map<Teacher, List<FacialData>> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'facialDataByTeacherRegistration'],
      ),
    );

    final Map<String, Individual> individuals = {};
    for (final t in teacher) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':registration': t.registration,
          }),
        );
      } on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      } on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      final resultValue = selected.map(
        (e) {
          final data = listBytesToDouble(e['data']);
          return FacialData(
            data: data,
            individual: individuals.putIfAbsent(
              e['individualRegistration'],
              () => Individual(
                individualRegistration: e['individualRegistration'],
                name: e['name'],
                surname: e['surname'],
              ),
            ),
          );
        },
      ).toList(growable: false);
      result[t] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<String, Individual?> getIndividualFromRegistration(
    Iterable<String> individualRegistration,
  ) {
    final Map<String, Individual?> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'individualByRegistration'],
      ),
    );

    for (final i in individualRegistration) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':individualRegistration': i,
          }),
        );
      } on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      } on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      if (selected.isEmpty) {
        result[i] = null;
      }
      else {
        if (selected.length > 1) {
          projectLogger.warning('more than 1 face picture related to the same student; proceeding with one;');
        }
        final row = selected[0];
        result.putIfAbsent(
          i,
          () => row['individualRegistration'] == null
              ? null
              : Individual(
                  individualRegistration: row['individualRegistration'],
                  name: row['name'],
                  surname: row['surname'],
                ),
        );
      }
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<SubjectClass, List<Lesson>> getLessonFromSubjectClass(
    Iterable<SubjectClass> subjectClass,
  ) {
    final Map<SubjectClass, List<Lesson>> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'lessonBySubjectClass'],
      ),
    );

    for (final c in subjectClass) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': c.subject.code,
            ':year': c.year,
            ':semester': c.semester,
            ':name': c.name,
          }),
        );
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

      final Map<String, Teacher> teachers = {};
      // final SubjectClass readClass = SubjectClass(
      //   subject: Subject(
      //     code: selected[0]['subjectCode'],
      //     name: selected[0]['subjectName'],
      //   ),
      //   year: selected[0]['year'],
      //   semester: selected[0]['semester'],
      //   name: selected[0]['name'],
      //   teacher: teachers.putIfAbsent(
      //           selected[0]['cTeacherRegistration'],
      //           () => Teacher(
      //             registration: selected[0]['cTeacherRegistration'],
      //             individual: Individual(
      //               individualRegistration: selected[0]['cTeacherIndividualRegistration'],
      //               name: selected[0]['cTeacherName'],
      //               surname: selected[0]['cTeacherSurname'],
      //             ),
      //           ),
      //         ),
      // );
      // REVIEW not using the class information returned from query
      final resultValue = selected
          .map(
            (e) {
              final dateTime = DateTime.parse(e['utcDateTime']);
              return Lesson(
              subjectClass: c,
              teacher: teachers.putIfAbsent(
                e['lTeacherRegistration'],
                () => Teacher(
                  registration: e['lTeacherRegistration'],
                  individual: Individual(
                    individualRegistration: e['lTeacherIndividualRegistration'],
                    name: e['lTeacherName'],
                    surname: e['lTeacherSurname'],
                  ),
                ),
              ),
              utcDateTime: dateTime,
            );},
          )
          .toList(growable: false);
      result[c] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<String, Student?> getStudentFromRegistration(
    Iterable<String> registration,
  ) {
    final Map<String, Student?> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'studentByRegistration'],
      ),
    );

    for (final r in registration) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':registration': r,
          }),
        );
      } on ArgumentError catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      } on pkg_sqlite3.SqliteException catch (e) {
        select.dispose();
        projectLogger.severe(e);
        return Map.unmodifiable({});
      }

      if (selected.isEmpty) {
        result[r] = null;
      }
      else {
        if (selected.length > 1) {
          projectLogger.warning('more than 1 student related to the same registration; proceeding with one;');
        }
        final row = selected[0];
        result.putIfAbsent(
          r,
          () => row['registration'] == null
              ? null
              : Student(
                  registration: row['registration'],
                  individual: Individual(
                    individualRegistration: row['individualRegistration'],
                    name: row['name'],
                    surname: row['surname'],
                  ),
                ),
        );
      }
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<SubjectClass, List<Student>> getStudentFromSubjectClass(
    Iterable<SubjectClass> subjectClass,
  ) {
    final Map<SubjectClass, List<Student>> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'studentFromSubjectClass'],
      ),
    );

    for (final c in subjectClass) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': c.subject.code,
            ':year': c.year,
            ':semester': c.semester,
            ':name': c.name,
          }),
        );
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

      final Map<String, Student> student = {};
      final resultValue = selected
          .map(
            (e) => student.putIfAbsent(
              e['sRegistration'],
              () => Student(
                registration: e['sRegistration'],
                individual: Individual(
                  individualRegistration: e['sIndividualRegistration'],
                  name: e['sName'],
                  surname: e['sSurname'],
                ),
              ),
            ),
          )
          .toList(growable: false);
      result[c] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  SubjectClass? getSubjectClass({
    required String subjectCode,
    required int year,
    required int semester,
    required String name,
  }) {
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'subjectClass'],
      ),
    );

    pkg_sqlite3.ResultSet selected;
    try {
      selected = select.selectWith(
        pkg_sqlite3.StatementParameters.named({
          ':subjectCode': subjectCode,
          ':year': year,
          ':semester': semester,
          ':name': name,
        }),
      );
    }
    on ArgumentError catch (e) {
      select.dispose();
      projectLogger.severe(e);
      return null;
    }
    on pkg_sqlite3.SqliteException catch (e) {
      select.dispose();
      projectLogger.severe(e);
      return null;
    }

    if (selected.isEmpty) {
      projectLogger.warning('no subject class found;');
      return null;
    }
    else if (selected.length > 1) {
      projectLogger.warning('more than 1 student related to the same registration; proceeding with one;');
    }

    final row = selected[0];
    final result = SubjectClass(
      subject: Subject(
        code: row['subjectCode'],
        name: row['subjectName'],
      ),
      year: row['year'],
      semester: row['semester'],
      name: row['name'],
      teacher: Teacher(
        registration: row['cTeacherRegistration'],
        individual: Individual(
          individualRegistration: row['cTeacherIndividualRegistration'],
          name: row['cTeacherName'],
          surname: row['cTeacherSurname'],
        ),
      ),
    );
    return result;
  }

  @override
  Map<SubjectClass, Map<Student, List<Attendance>>> getSubjectClassAttendance(
    Iterable<SubjectClass> subjectClass,
  ) {
    final Map<SubjectClass, Map<Student, List<Attendance>>> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'attendance'],
      ),
    );

    final Map<String, SubjectClass> classes = {};
    final Map<String, Subject> subjects = {};
    for (final sc in subjectClass) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': sc.subject.code,
            ':year': sc.year,
            ':semester': sc.semester,
            ':name': sc.name,
          }),
        );
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

      final Map<String, Student> students = {};
      final Map<String, Teacher> teachers = {};
      final Map<int, Lesson> lessons = {};
      final Map<String, DateTime> datesAndTimes = {};
      final Map<Student, List<Attendance>> attendancesByStudents = {};
      for (final e in selected) {
        final subjectKey = e['subjectCode']!;
        if (!subjects.containsKey(subjectKey)) {
          subjects[subjectKey] = Subject(
            code: e['subjectCode'],
            name: e['subjectName'],
          );
        }
        final classTeacherKey = e['classTeacherRegistration']!;
        if (!teachers.containsKey(classTeacherKey)) {
          teachers[classTeacherKey] = Teacher(
            registration: e['classTeacherRegistration'],
            individual: Individual(
              individualRegistration: e['classTeacherIndividualRegistration'],
              name: e['classTeacherName'],
              surname: e['classTeacherSurname'],
            ),
          );
        }
        final cKey = '${e['subjectCode']!}:${e['classYear']!}:${e['classSemester']!}:${e['className']!}';
        if (!classes.containsKey(cKey)) {
          classes[cKey] = SubjectClass(
            subject: subjects[subjectKey]!,
            year: e['classYear'],
            semester: e['classSemester'],
            name: e['className'],
            teacher: teachers[classTeacherKey]!,
          );
        }

        final sKey = e['studentRegistration']!;
        if (!students.containsKey(sKey)) {
          students[sKey] = Student(
            registration: e['studentRegistration'],
            individual: Individual(
              individualRegistration: e['studentIndividualRegistration'],
              name: e['studentName'],
              surname: e['studentSurname'],
            ),
          );
        }
        final lessonTeacherKey = e['lessonTeacherRegistration'];
        if (lessonTeacherKey != null && !teachers.containsKey(lessonTeacherKey)) {
          teachers[lessonTeacherKey] = Teacher(
            registration: e['lessonTeacherRegistration'],
            individual: Individual(
              individualRegistration: e['lessonTeacherIndividualRegistration'],
              name: e['lessonTeacherName'],
              surname: e['lessonTeacherSurname'],
            ),
          );
        }
        final int? lKey = e['lessonId'];
        if (lKey != null && !lessons.containsKey(lKey)) {
          final dateTime = DateTime.parse(e['lessonDateTime']);
          lessons[lKey] = Lesson(
            subjectClass: classes[cKey]!,
            utcDateTime: dateTime,
            // teachers[lessonTeacherKey] != null <-> lessonTeacherKey != null
            teacher: teachers[lessonTeacherKey]!,
          );
        }
        final aKey = students[sKey]!;
        if (!attendancesByStudents.containsKey(aKey)) {
          attendancesByStudents[aKey] = <Attendance>[];
        }
        if (lKey != null) {
          final attendance = Attendance(
            student: students[sKey]!,
            lesson: lessons[lKey]!,
            utcDateTime: datesAndTimes.putIfAbsent(
              e['attendanceUtcDateTime'],
              () => DateTime.parse(e['attendanceUtcDateTime']),
            ),
          );
          attendancesByStudents[aKey]!.add(attendance);
        }
      }

      result[sc] = Map.unmodifiable(attendancesByStudents);
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<Subject, List<SubjectClass>> getSubjectClassFromSubject(
    Iterable<Subject> subject,
  ) {
    final Map<Subject, List<SubjectClass>> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'classBySubject'],
      ),
    );

    for (final s in subject) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': s.code,
          }),
        );
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

      final Map<String, Teacher> teachers = {};
      // REVIEW - not using the subject info returned from query
      final resultValue = selected
          .map(
            (e) => SubjectClass(
              subject: s,
              year: e['year'],
              semester: e['semester'],
              name: e['name'],
              teacher: teachers.putIfAbsent(
                e['cTeacherRegistration'],
                () => Teacher(
                  registration: e['cTeacherRegistration'],
                  individual: Individual(
                    individualRegistration: e['cTeacherIndividualRegistration'],
                    name: e['cTeacherName'],
                    surname: e['cTeacherSurname'],
                  ),
                ),
              )
            ) ,
          )
          .toList(growable: false);
      result[s] = resultValue;
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<String, Subject?> getSubjectFromCode(
    Iterable<String> code
  ) {
    final Map<String, Subject?> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'subjectByCode'],
      ),
    );

    for (final c in code) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':code': c,
          }),
        );
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

      if (selected.isEmpty) {
        result[c] = null;
      }
      else {
        if (selected.length > 1) {
          projectLogger.warning('more than 1 subject related to the same code; proceeding with one;');
        }
        final row = selected[0];
        final resultValue = Subject(code: row['code'], name: row['name']);
        if (!result.containsKey(c)) {
          result[c] = resultValue;
        }
      }
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  Map<String, Teacher?> getTeacherFromRegistration(
    Iterable<String> registration,
  ) {
    final Map<String, Teacher?> result = {};
    final select = _database.prepare(
      _statementsLoader.getStatement(
        ['dql', 'teacherByRegistration'],
      ),
    );

    for (final r in registration) {
      pkg_sqlite3.ResultSet selected;
      try {
        selected = select.selectWith(
          pkg_sqlite3.StatementParameters.named({
            ':registration': r,
          }),
        );
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

      if (selected.isEmpty) {
        result[r] = null;
      }
      else {
        if (selected.length > 1) {
          projectLogger.warning('more than 1 teacher related to the same registration; proceeding with one;');
        }
        final row = selected[0];
        result.putIfAbsent(
          r,
          () => row['registration'] == null
              ? null
              : Teacher(
                  registration: row['registration'],
                  individual: Individual(
                    individualRegistration: row['individualRegistration'],
                    name: row['name'],
                    surname: row['surname'],
                  ),
                ),
        );
      }
    }

    select.dispose();
    return Map.unmodifiable(result);
  }

  @override
  void removeFaceEmbeddingNotRecognizedFromCamera(
    Iterable<EmbeddingRecognitionResult> recognition,
    Lesson lesson,
  ) {
    final delete = _database.prepare(
      _statementsLoader.getStatement(
        ['notRecognizedFromCamera', 'dml', 'delete'],
      ),
    );

    for (final r in recognition) {
      final String pictureMd5 = _pictureMd5(r.inputFace);
      try {
        delete.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': lesson.subjectClass.subject.code,
            ':year': lesson.subjectClass.year,
            ':semester': lesson.subjectClass.semester,
            ':name': lesson.subjectClass.name,
            ':utcDateTime': lesson.utcDateTime.toIso8601String(),
            ':pictureMd5': pictureMd5,
          }),
        );
      }
      on ArgumentError catch (e) {
        delete.dispose();
        projectLogger.severe(e);
      }
      on pkg_sqlite3.SqliteException catch (e) {
        delete.dispose();
        projectLogger.severe(e);
      }
    }

    delete.dispose();
  }

  @override
  void removeFaceEmbeddingRecognizedFromCamera(
    Iterable<EmbeddingRecognitionResult> recognition,
    Lesson lesson,
  ) {
    final delete = _database.prepare(
      _statementsLoader.getStatement(
        ['recognizedFromCamera', 'dml', 'delete'],
      ),
    );

    for (final r in recognition) {

      final String pictureMd5 = _pictureMd5(r.inputFace);
      try {
        delete.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': lesson.subjectClass.subject.code,
            ':year': lesson.subjectClass.year,
            ':semester': lesson.subjectClass.semester,
            ':name': lesson.subjectClass.name,
            ':utcDateTime': lesson.utcDateTime.toIso8601String(),
            ':pictureMd5': pictureMd5,
          }),
        );
      }
      on ArgumentError catch (e) {
        delete.dispose();
        projectLogger.severe(e);
      }
      on pkg_sqlite3.SqliteException catch (e) {
        delete.dispose();
        projectLogger.severe(e);
      }
    }

    delete.dispose();
  }

  @override
  void replaceRecordOfRecognitionResultFromCamera(
    EmbeddingRecognitionResult oldRecord,
    EmbeddingRecognitionResult newRecord,
    Lesson lesson,
  ) {
    pkg_sqlite3.PreparedStatement? delete;
    pkg_sqlite3.PreparedStatement? insert;

    try {
      _beginTransaction();
      if (oldRecord.recognized) {
        delete = _database.prepare(
          _statementsLoader.getStatement(
            ['recognizedFromCamera', 'dml', 'delete'],
          ),
        );
      }
      else {
        delete = _database.prepare(
          _statementsLoader.getStatement(
            ['notRecognizedFromCamera', 'dml', 'delete'],
          ),
        );
      }

      final removePictureMd5 = _pictureMd5(oldRecord.inputFace);
      if (oldRecord.recognized) {
        delete.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': lesson.subjectClass.subject.code,
            ':year': lesson.subjectClass.year,
            ':semester': lesson.subjectClass.semester,
            ':name': lesson.subjectClass.name,
            ':utcDateTime': lesson.utcDateTime.toIso8601String(),
            ':pictureMd5': removePictureMd5,
          }),
        );
      }
      else {
        delete.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': lesson.subjectClass.subject.code,
            ':year': lesson.subjectClass.year,
            ':semester': lesson.subjectClass.semester,
            ':name': lesson.subjectClass.name,
            ':utcDateTime': lesson.utcDateTime.toIso8601String(),
            ':pictureMd5': removePictureMd5,
          }),
        );
      }

      if (newRecord.recognized) {
        insert = _database.prepare(
          _statementsLoader.getStatement(
            ['recognizedFromCamera', 'dml', 'insert'],
          ),
        );
      }
      else {
        insert = _database.prepare(
          _statementsLoader.getStatement(
            ['notRecognizedFromCamera', 'dml', 'insert'],
          ),
        );
      }

      final insertPictureMd5 = _pictureMd5(newRecord.inputFace);
      final insertEmbedding = listDoubleToBytes(newRecord.inputFaceEmbedding);
      if (newRecord.recognized) {
        insert.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': lesson.subjectClass.subject.code,
            ':year': lesson.subjectClass.year,
            ':semester': lesson.subjectClass.semester,
            ':name': lesson.subjectClass.name,
            ':lessonUtcDateTime': lesson.utcDateTime.toIso8601String(),
            ':picture': newRecord.inputFace,
            ':pictureMd5': insertPictureMd5,
            ':embedding': insertEmbedding,
            ':arriveUtcDateTime': newRecord.utcDateTime.toIso8601String(),
            ':nearestStudentRegistration':
                newRecord.nearestStudent?.registration,
          }),
        );
      }
      else {
        insert.executeWith(
          pkg_sqlite3.StatementParameters.named({
            ':subjectCode': lesson.subjectClass.subject.code,
            ':year': lesson.subjectClass.year,
            ':semester': lesson.subjectClass.semester,
            ':name': lesson.subjectClass.name,
            ':lessonUtcDateTime': lesson.utcDateTime.toIso8601String(),
            ':picture': newRecord.inputFace,
            ':pictureMd5': insertPictureMd5,
            ':embedding': insertEmbedding,
            ':arriveUtcDateTime': newRecord.utcDateTime.toIso8601String(),
            ':nearestStudentRegistration':
                newRecord.nearestStudent?.registration,
          }),
        );
      }
      _commitTransaction();
    }
    on ArgumentError catch (e) {
      projectLogger.warning(e);
      _rollbackTransaction();
    }
    on pkg_sqlite3.SqliteException catch (e) {
      projectLogger.warning(e);
      _rollbackTransaction();
    }
    delete?.dispose();
    insert?.dispose();
  }
}
