import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/algorithms.dart';
import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:test/test.dart';
import 'package:sqlite3/open.dart' as pkg_sqlite3_open;

// Widget instantiateApp() => MaterialApp(home: Placeholder(),);

class _ModelsCollection {
  final List<Individual> individuals;
  final List<FacialData> facialsData;
  final List<FacePicture> facePictures;
  final List<Student> students;
  final List<Teacher> teachers;
  final List<Subject> subjects;
  final List<SubjectClass> classes;
  final List<Lesson> lessons;
  final List<Enrollment> enrollments;
  final List<Attendance> attendances;
  final List<EmbeddingRecognitionResult> faceNotRecognized;
  final List<EmbeddingRecognitionResult> faceRecognized;

  _ModelsCollection({
    required this.individuals,
    required this.facialsData,
    required this.facePictures,
    required this.students,
    required this.teachers,
    required this.subjects,
    required this.classes,
    required this.lessons,
    required this.enrollments,
    required this.attendances,
    required this.faceNotRecognized,
    required this.faceRecognized,
  });
}

_ModelsCollection _newCollection() {
    final individuals = List<Individual>.unmodifiable(<Individual>[
    Individual(individualRegistration: '00000000001', name: 'john', surname: 'doe'),
    Individual(individualRegistration: '00000000002', name: 'john', surname: 'roe'),
    Individual(individualRegistration: '00000000003', name: 'jane', surname: 'doe'),
    Individual(individualRegistration: '00000000004', name: 'jane', surname: 'roe'),
    Individual(individualRegistration: '00000000005', name: 'john'),
    Individual(individualRegistration: '00000000006', name: 'jane'),
  ]);
  final facialsData = List<FacialData>.unmodifiable(<FacialData>[
    FacialData(data: [0.0,0.1,0.0,0.2], individual: individuals[1]),
    FacialData(data: [0.0,0.1,0.0,0.3], individual: individuals[2]),
    FacialData(data: [0.0,0.2,0.0,0.3], individual: individuals[2]),
    FacialData(data: [0.0,0.3,0.0,0.3], individual: individuals[2]),
    FacialData(data: [0.0,0.1,0.1,0.2], individual: individuals[5]),
  ]);
  final facePictures = List<FacePicture>.unmodifiable(<FacePicture>[
    FacePicture(faceJpeg: Uint8List.fromList([0,1,0,2]), individual: individuals[1]),
    FacePicture(faceJpeg: Uint8List.fromList([0,1,0,3]), individual: individuals[2]),
    FacePicture(faceJpeg: Uint8List.fromList([0,2,0,3]), individual: individuals[2]),
    FacePicture(faceJpeg: Uint8List.fromList([0,3,0,3]), individual: individuals[2]),
    FacePicture(faceJpeg: Uint8List.fromList([0,1,1,2]), individual: individuals[5]),
  ]);
  final students = List<Student>.unmodifiable(<Student>[
  Student(registration: 's00000001', individual: individuals[0]),
  Student(registration: 's00000002', individual: individuals[1]),
  Student(registration: 's00000003', individual: individuals[2]),
  Student(registration: 's00000004', individual: individuals[3]),
  ]);
  final teachers = List<Teacher>.unmodifiable(<Teacher>[
  Teacher(registration: 't00000001', individual: individuals[4]),
  Teacher(registration: 't00000002', individual: individuals[5]),
  ]);
  final subjects = List<Subject>.unmodifiable(<Subject>[
    Subject(code: 's00001', name: 'subjectA'),
    Subject(code: 's00002', name: 'subjectB'),
  ]);
  final classes = List<SubjectClass>.unmodifiable(<SubjectClass>[
    SubjectClass(subject: subjects[0], year: 2024, semester: 1, name: 'classA', teacher: teachers[0]),
    SubjectClass(subject: subjects[1], year: 2024, semester: 1, name: 'classB', teacher: teachers[1]),
  ]);
  final dateTime = DateTime(2024, 01, 01, 07, 00).toUtc();
  final lessons = List<Lesson>.unmodifiable(<Lesson>[
    Lesson(subjectClass: classes[0], utcDateTime: dateTime, teacher: teachers[0]),
    Lesson(subjectClass: classes[1], utcDateTime: dateTime, teacher: teachers[1]),
  ]);
  final enrollments = List<Enrollment>.unmodifiable(<Enrollment>[
    Enrollment(student: students[0], subjectClass: classes[0]),
    Enrollment(student: students[2], subjectClass: classes[0]),
    Enrollment(student: students[3], subjectClass: classes[0]),
    Enrollment(student: students[0], subjectClass: classes[1]),
    Enrollment(student: students[1], subjectClass: classes[1]),
    Enrollment(student: students[2], subjectClass: classes[1]),
    Enrollment(student: students[3], subjectClass: classes[1]),
  ]);
  final attendances = List<Attendance>.unmodifiable(<Attendance>[
    Attendance(student: students[0], lesson: lessons[0]),
    Attendance(student: students[3], lesson: lessons[0]),
    Attendance(student: students[0], lesson: lessons[1]),
    Attendance(student: students[1], lesson: lessons[1]),
  ]);
  final facesNotRecognized = List<EmbeddingRecognitionResult>.unmodifiable(<
      EmbeddingRecognitionResult>[
    EmbeddingRecognitionResult(
      inputFace: Uint8List.fromList([1, 1, 1, 1, 1]),
      inputFaceEmbedding: [0.9, 0.9, 0.9, 0.1],
      nearestStudent: students[0],
      recognized: false,
    ),
    EmbeddingRecognitionResult(
      inputFace: Uint8List.fromList([1, 1, 1, 1, 2]),
      inputFaceEmbedding: [0.9, 0.9, 0.9, 0.2],
      nearestStudent: null,
      recognized: false,
    ),
  ]);
  final facesRecognized = List<EmbeddingRecognitionResult>.unmodifiable(<
      EmbeddingRecognitionResult>[
    EmbeddingRecognitionResult(
      inputFace: Uint8List.fromList([1, 1, 1, 1, 3]),
      inputFaceEmbedding: [0.9, 0.9, 0.9, 0.3],
      nearestStudent: students[1],
      recognized: true,
    ),
    EmbeddingRecognitionResult(
      inputFace: Uint8List.fromList([1, 1, 1, 1, 4]),
      inputFaceEmbedding: [0.9, 0.9, 0.9, 0.4],
      nearestStudent: null,
      recognized: true,
    ),
  ]);

  return _ModelsCollection(
    individuals: individuals,
    facialsData: facialsData,
    facePictures: facePictures,
    students: students,
    teachers: teachers,
    subjects: subjects,
    classes: classes,
    lessons: lessons,
    enrollments: enrollments,
    attendances: attendances,
    faceNotRecognized: facesNotRecognized,
    faceRecognized: facesRecognized,
  );
}

void main() {
  const databasePath = r'assets\db.sqlite';
  const jsonSqlStatementsPath = r'assets\sqlStatements_v2.json';
  final jsonSqlStatements = jsonDecode(File(jsonSqlStatementsPath).readAsStringSync());
  final sqlStatementLoader = SqlStatementsLoader(jsonSqlStatements);
  pkg_sqlite3_open.open.overrideFor(pkg_sqlite3_open.OperatingSystem.windows, () => DynamicLibrary.open(r'bin\sqlite3.dll'));
  final repo = SQLite3DomainRepository(
    databasePath: databasePath,
    statementsLoader: sqlStatementLoader,
  );

  final modelsCollection = _newCollection();

  test('convertDoubleList', () {
    final a = modelsCollection.facialsData.map(
      (e) => listDoubleToBytes(e.data)
    ).toList();
    final b = a.map(
      listBytesToDouble
    ).toList();

    final aux = modelsCollection.facialsData.map((e) => e.data).toList();
    for (int i=0; i<b.length; i++) {
      expect(b[i], equals(aux[i]));
    }
  });

  test('addIndividual', () {
    repo.addIndividual(modelsCollection.individuals);
  });

  test('addFacialData', () {
    repo.addFacialData(modelsCollection.facialsData);
  });

  test('addFacePicture', () {
    repo.addFacePicture(modelsCollection.facePictures);
  });

  test('addStudent', () {
    repo.addStudent(modelsCollection.students);
  });

  test('addTeacher', () {
    repo.addTeacher(modelsCollection.teachers);
  });

  test('addSubject', () {
    repo.addSubject(modelsCollection.subjects);
  });

  test('addClass', () {
    repo.addSubjectClass(modelsCollection.classes);
  });

  test('addEnrollment', () {
    repo.addEnrollment(modelsCollection.enrollments);
  });

  test('addLesson', () {
    repo.addLesson(modelsCollection.lessons);
  });

  test('addAttendance', () {
    repo.addAttendance(modelsCollection.attendances);
  });

  test('addNotRecognized', () {
    repo.addFaceEmbeddingToCameraNotRecognized(
      modelsCollection.faceNotRecognized,
      modelsCollection.lessons[0],
    );
  });

  test('addRecognized', () {
    repo.addFaceEmbeddingToCameraRecognized(
      modelsCollection.faceRecognized,
      modelsCollection.lessons[0],
    );
  });
}