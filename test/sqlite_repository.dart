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
    FacePicture(faceJpeg: Uint8List.fromList([0,0,0,2]), individual: individuals[1]),
    FacePicture(faceJpeg: Uint8List.fromList([0,0,0,3]), individual: individuals[2]),
    FacePicture(faceJpeg: Uint8List.fromList([0,0,0,4]), individual: individuals[3]),
    FacePicture(faceJpeg: Uint8List.fromList([0,0,0,6]), individual: individuals[5]),
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
  final dateTime1 = DateTime(2024, 01, 01, 07, 00).toUtc();
  final dateTime2 = DateTime(2024, 01, 02, 07, 00).toUtc();
  final lessons = List<Lesson>.unmodifiable(<Lesson>[
    Lesson(subjectClass: classes[0], utcDateTime: dateTime1, teacher: teachers[0]),
    Lesson(subjectClass: classes[1], utcDateTime: dateTime2, teacher: teachers[1]),
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

int compareNumLists<T extends num>(List<T> a, List<T> b) {
  if (a.length < b.length) {
    return -1;
  }
  else if (a.length > b.length) {
    return 1;
  }
  for (int i = 0; i < a.length; i++) {
    final v1 = a[i];
    final v2 = b[i];
    if (v1 < v2) {
      return -1;
    }
    else if (v1 > v2) {
      return 1;
    }
  }
  return 0;
}

void main() {
  const databasePath = r'assets\test_db.sqlite3';
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

  group('get from database', () {
    test('getIndividualFromRegistration', () {
      final expected = {
        for (final e in modelsCollection.individuals)
          e.individualRegistration: e
      };

      final aux = repo.getIndividualFromRegistration(
        modelsCollection.individuals
            .map((e) => e.individualRegistration)
            .toList(),
      );

      for (final e in expected.keys) {
        expect(
          aux[e],
          isA<Individual>()
              .having((e) => e.individualRegistration, 'individualRegistration',
                  expected[e]!.individualRegistration)
              .having((e) => e.name, 'name', expected[e]!.name)
              .having((e) => e.surname, 'surname', expected[e]!.surname),
        );
      }
    });

    test('getFacialDataFromStudent', () {
      final expected = <Student, List<FacialData>>{
        modelsCollection.students[0]: [],
        modelsCollection.students[1]: [
          modelsCollection.facialsData[0],
        ],
        modelsCollection.students[2]: [
          modelsCollection.facialsData[1],
          modelsCollection.facialsData[2],
          modelsCollection.facialsData[3]
        ],
        modelsCollection.students[3]: [],
      };

      final aux = repo.getFacialDataFromStudent(
        modelsCollection.students,
      );

      expect(aux, hasLength(expected.length));
      for (final e in expected.keys) {
        final expectedList = expected[e]!;
        final actualList = aux[e]!;
        expect(expectedList, isNotNull);
        expect(actualList, isNotNull);
        expect(actualList, hasLength(expectedList.length));
        expectedList.sort((a, b) => compareNumLists(a.data, b.data));
        actualList.sort((a, b) => compareNumLists(a.data, b.data));
        for (int i = 0; i < expectedList.length; i++) {
          expect(
            actualList[i],
            isA<FacialData>()
                .having(
                    (p0) => p0.individual.individualRegistration,
                    'individualRegistration',
                    equals(expectedList[i].individual.individualRegistration))
                .having((p0) => p0.individual.name, 'name',
                    equals(expectedList[i].individual.name))
                .having((p0) => p0.individual.surname, 'surname',
                    equals(expectedList[i].individual.surname))
                .having((p0) => p0.data, 'data', equals(expectedList[i].data)),
          );
        }
      }
    });

    test('getFacialDataFromTeacher', () {
      final expected = <Teacher, List<FacialData>>{
        modelsCollection.teachers[0]: [],
        modelsCollection.teachers[1]: [
          modelsCollection.facialsData[4],
        ],
      };

      final actual = repo.getFacialDataFromTeacher(
        modelsCollection.teachers,
      );

      expect(actual, hasLength(expected.length));
      for (final e in expected.keys) {
        final expectedList = expected[e]!;
        final actualList = actual[e]!;
        expect(expectedList, isNotNull);
        expect(actualList, isNotNull);
        expect(actualList, hasLength(expectedList.length));
        expectedList.sort((a, b) => compareNumLists(a.data, b.data));
        actualList.sort((a, b) => compareNumLists(a.data, b.data));
        for (int i = 0; i < expectedList.length; i++) {
          expect(
            actualList[i],
            isA<FacialData>()
                .having(
                    (p0) => p0.individual.individualRegistration,
                    'individualRegistration',
                    equals(expectedList[i].individual.individualRegistration))
                .having((p0) => p0.individual.name, 'name',
                    equals(expectedList[i].individual.name))
                .having((p0) => p0.individual.surname, 'surname',
                    equals(expectedList[i].individual.surname))
                .having((p0) => p0.data, 'data', equals(expectedList[i].data)),
          );
        }
      }
    });

    test('getFacePictureFromStudent', () {
      final expected = <Student, FacePicture?>{
        modelsCollection.students[0]: null,
        modelsCollection.students[1]: modelsCollection.facePictures[0],
        modelsCollection.students[2]: modelsCollection.facePictures[1],
        modelsCollection.students[3]: modelsCollection.facePictures[2],
      };

      final actual = repo.getFacePictureFromStudent(
        modelsCollection.students,
      );

      expect(actual, hasLength(expected.length));
      for (final e in expected.keys) {
        final expectedElement = expected[e];
        final actualElement = actual[e];
        if (expectedElement == null) {
          expect(actualElement, isNull);
        } else {
          expect(
            actualElement,
            isA<FacePicture>()
                .having(
                    (p0) => p0.individual.individualRegistration,
                    'individualRegistration',
                    equals(expectedElement.individual.individualRegistration))
                .having((p0) => p0.individual.name, 'name',
                    equals(expectedElement.individual.name))
                .having((p0) => p0.individual.surname, 'surname',
                    equals(expectedElement.individual.surname))
                .having((p0) => p0.faceJpeg, 'faceJpeg',
                    equals(expectedElement.faceJpeg)),
          );
        }
      }
    });

    test('getFacePictureFromTeacher', () {
      final expected = <Teacher, FacePicture?>{
        modelsCollection.teachers[0]: null,
        modelsCollection.teachers[1]: modelsCollection.facePictures[3],
      };

      final actual = repo.getFacePictureFromTeacher(
        modelsCollection.teachers,
      );

      expect(actual, hasLength(expected.length));
      for (final e in expected.keys) {
        final expectedElement = expected[e];
        final actualElement = actual[e];
        if (expectedElement == null) {
          expect(actualElement, isNull);
        } else {
          expect(
            actualElement,
            isA<FacePicture>()
                .having(
                    (p0) => p0.individual.individualRegistration,
                    'individualRegistration',
                    equals(expectedElement.individual.individualRegistration))
                .having((p0) => p0.individual.name, 'name',
                    equals(expectedElement.individual.name))
                .having((p0) => p0.individual.surname, 'surname',
                    equals(expectedElement.individual.surname))
                .having((p0) => p0.faceJpeg, 'faceJpeg',
                    equals(expectedElement.faceJpeg)),
          );
        }
      }
    });

    test('getStudentFromRegistration', () {
      final expected = <String, Student?>{
        modelsCollection.students[0].registration: modelsCollection.students[0],
        modelsCollection.students[1].registration: modelsCollection.students[1],
        modelsCollection.students[2].registration: modelsCollection.students[2],
        modelsCollection.students[3].registration: modelsCollection.students[3],
        'aRegistration': null,
      };

      final actual = repo.getStudentFromRegistration(
        expected.keys,
      );

      expect(actual, hasLength(expected.length));
      for (final e in expected.keys) {
        final expectedElement = expected[e];
        final actualElement = actual[e];
        if (expectedElement == null) {
          expect(actualElement, isNull);
        } else {
          expect(
            actualElement,
            isA<Student>()
                .having(
                    (p0) => p0.individual.individualRegistration,
                    'individualRegistration',
                    equals(expectedElement.individual.individualRegistration))
                .having((p0) => p0.individual.name, 'name',
                    equals(expectedElement.individual.name))
                .having((p0) => p0.individual.surname, 'surname',
                    equals(expectedElement.individual.surname))
                .having((p0) => p0.registration, 'registration',
                    equals(expectedElement.registration)),
          );
        }
      }
    });

    test('getStudentFromSubjectClass', () {
      final extra = SubjectClass(
        subject: Subject(code: '_', name: '_'),
        year: 2024,
        semester: 01,
        name: '_',
        teacher: modelsCollection.teachers[0],
      );
      final expected = <SubjectClass, List<Student>>{
        modelsCollection.classes[0]: [
          modelsCollection.students[0],
          modelsCollection.students[2],
          modelsCollection.students[3],
        ],
        modelsCollection.classes[1]: [
          modelsCollection.students[0],
          modelsCollection.students[1],
          modelsCollection.students[2],
          modelsCollection.students[3],
        ],
        extra: [],
      };

      final actual = repo.getStudentFromSubjectClass(
        expected.keys,
      );

      expect(actual, hasLength(expected.length));
      for (final e in expected.keys) {
        final expectedList = expected[e]!;
        final actualList = actual[e]!;
        expect(expectedList, isNotNull);
        expect(actualList, isNotNull);
        expect(actualList, hasLength(expectedList.length));
        expectedList.sort((a, b) => a.registration.compareTo(b.registration));
        actualList.sort((a, b) => a.registration.compareTo(b.registration));
        for (int i = 0; i < expectedList.length; i++) {
          expect(
            actualList[i],
            isA<Student>()
                .having(
                    (p0) => p0.individual.individualRegistration,
                    'individualRegistration',
                    equals(expectedList[i].individual.individualRegistration))
                .having((p0) => p0.individual.name, 'name',
                    equals(expectedList[i].individual.name))
                .having((p0) => p0.individual.surname, 'surname',
                    equals(expectedList[i].individual.surname))
                .having((p0) => p0.registration, 'data', equals(expectedList[i].registration)),
          );
        }
      }
    });

    test('getTeacherFromRegistration', () {
      final expected = <String, Teacher?>{
        modelsCollection.teachers[0].registration: modelsCollection.teachers[0],
        modelsCollection.teachers[1].registration: modelsCollection.teachers[1],
        'aRegistration': null,
      };

      final actual = repo.getTeacherFromRegistration(
        expected.keys,
      );

      expect(actual, hasLength(expected.length));
      for (final e in expected.keys) {
        final expectedElement = expected[e];
        final actualElement = actual[e];
        if (expectedElement == null) {
          expect(actualElement, isNull);
        }
        else {
          expect(
            actualElement,
            isA<Teacher>()
                .having(
                    (p0) => p0.individual.individualRegistration,
                    'individualRegistration',
                    equals(expectedElement.individual.individualRegistration))
                .having((p0) => p0.individual.name, 'name',
                    equals(expectedElement.individual.name))
                .having((p0) => p0.individual.surname, 'surname',
                    equals(expectedElement.individual.surname))
                .having((p0) => p0.registration, 'registration',
                    equals(expectedElement.registration)),
          );
        }
      }
    });

    test('getAllSubjects', () {
      final expected = [...modelsCollection.subjects];
      final actual = [...repo.getAllSubjects()];

      expect(actual, hasLength(expected.length));
      expected.sort((a, b) => a.code.compareTo(b.code));
      actual.sort((a, b) => a.code.compareTo(b.code));
      for (int i=0; i<expected.length; i++) {
        final expectedElement = expected[i];
        final actualElement = actual[i];
        expect(
            actualElement,
            isA<Subject>()
                .having((p0) => p0.code, 'code', equals(expectedElement.code))
                .having((p0) => p0.name, 'name', equals(expectedElement.name)));
      }
    });

    test('getSubjectClass', () {
      final expected = [...modelsCollection.classes];

      for (final e in expected) {
        final actual = repo.getSubjectClass(
          subjectCode: e.subject.code,
          year: e.year,
          semester: e.semester,
          name: e.name
        );
        expect(
          actual,
          isA<SubjectClass>()
              .having((p0) => p0.subject.code, 'subjectCode', equals(e.subject.code))
              .having((p0) => p0.subject.name, 'subjectName', equals(e.subject.name))
              .having((p0) => p0.year, 'year', equals(e.year))
              .having((p0) => p0.semester, 'semester', equals(e.semester))
              .having((p0) => p0.name, 'name', equals(e.name))
              .having((p0) => p0.teacher.registration, 'teacherRegistration', equals(e.teacher.registration))
              .having((p0) => p0.teacher.individual.individualRegistration, 'teacherRegistration', equals(e.teacher.individual.individualRegistration))
              .having((p0) => p0.teacher.individual.name, 'teacherName', equals(e.teacher.individual.name))
              .having((p0) => p0.teacher.individual.surname, 'teacherSurname', equals(e.teacher.individual.surname)),
        );
      }
    });

    // test('getEnrollment', () {});

    test('getLessonFromSubjectClass', () {
      final extra = SubjectClass(
          subject: modelsCollection.subjects[0],
          year: 2024,
          semester: 0,
          name: '_',
          teacher: modelsCollection.teachers[0],
      );
      final expected = <SubjectClass, List<Lesson>>{
        modelsCollection.classes[0]: [modelsCollection.lessons[0]],
        modelsCollection.classes[1]: [modelsCollection.lessons[1]],
        extra: []
      };

      final actual = repo.getLessonFromSubjectClass(
        expected.keys,
      );

      expect(actual, hasLength(expected.length));
      // ignore: prefer_function_declarations_over_variables
      final lessonSortKey = (Lesson e) => '${e.subjectClass.subject.code}${e.subjectClass.year}${e.subjectClass.semester}${e.subjectClass.name}${e.utcDateTime}${e.subjectClass.teacher.registration}';
      for (final e in expected.keys) {
        final expectedList = expected[e]!;
        final actualList = actual[e]!;
        expect(expectedList, isNotNull);
        expect(actualList, isNotNull);
        expect(actualList, hasLength(expectedList.length));
        expectedList.sort((a, b) => lessonSortKey(a).compareTo(lessonSortKey(b)));
        actualList.sort((a, b) => lessonSortKey(a).compareTo(lessonSortKey(b)));
        for (int i = 0; i < expectedList.length; i++) {
          expect(
            actualList[i],
            isA<Lesson>()
                .having((p0) => p0.subjectClass.subject.code, 'subjectCode',
                    equals(expectedList[i].subjectClass.subject.code))
                .having((p0) => p0.subjectClass.subject.name, 'subjectName',
                    equals(expectedList[i].subjectClass.subject.name))
                .having((p0) => p0.subjectClass.year, 'classYear',
                    equals(expectedList[i].subjectClass.year))
                .having((p0) => p0.subjectClass.semester, 'classSemester',
                    equals(expectedList[i].subjectClass.semester))
                .having((p0) => p0.subjectClass.name, 'className',
                    equals(expectedList[i].subjectClass.name))
                .having((p0) => p0.utcDateTime, 'utcDateTime',
                    equals(expectedList[i].utcDateTime))
                .having((p0) => p0.subjectClass.teacher.registration, 'teacherRegistration',
                    equals(expectedList[i].subjectClass.teacher.registration))
                .having((p0) => p0.subjectClass.teacher.individual.individualRegistration, 'teacherIndividualRegistration',
                    equals(expectedList[i].subjectClass.teacher.individual.individualRegistration))
                .having((p0) => p0.subjectClass.teacher.individual.name, 'teacherName',
                    equals(expectedList[i].subjectClass.teacher.individual.name))
                .having((p0) => p0.subjectClass.teacher.individual.surname, 'teacherSurname',
                    equals(expectedList[i].subjectClass.teacher.individual.surname)),
          );
        }
      }
    });

    test('getSubjectClassAttendance', () {
      final extra = SubjectClass(
          subject: modelsCollection.subjects[0],
          year: 2024,
          semester: 0,
          name: '_',
          teacher: modelsCollection.teachers[0],
      );
      final expected = <SubjectClass, Map<Student, List<Attendance>>>{
        modelsCollection.classes[0]: {
          modelsCollection.students[0]: [
            modelsCollection.attendances[0],
          ],
          // modelsCollection.students[1]: [],
          modelsCollection.students[2]: [],
          modelsCollection.students[3]: [
            modelsCollection.attendances[1],
          ],
        },
        modelsCollection.classes[1]: {
          modelsCollection.students[0]: [
            modelsCollection.attendances[2],
          ],
          modelsCollection.students[1]: [
            modelsCollection.attendances[3],
          ],
          modelsCollection.students[2]: [],
          modelsCollection.students[3]: [],
        },
        extra: {}
      };

      final actual = repo.getSubjectClassAttendance(
        expected.keys,
      );

      for (final e1 in actual.entries) {
        print('class: ${e1.key.subject.code} ${e1.key.year} ${e1.key.semester} ${e1.key.name}');
        for (final e2 in e1.value.entries) {
          print('student: ${e2.key.registration}');
          for (final e3 in e2.value) {
            print('attendance: ${e3.lesson.utcDateTime}');
          }
        }
      }

      expect(actual, hasLength(expected.length));
      // ignore: prefer_function_declarations_over_variables
      final attendanceSortKey = (Attendance e) => '${e.lesson.subjectClass.subject.code}${e.lesson.subjectClass.year}${e.lesson.subjectClass.semester}${e.lesson.subjectClass.name}${e.lesson.subjectClass.teacher.registration}';
      for (final e in expected.keys) {
        final expectedMap = expected[e]!;
        final actualMap = actual[e]!;
        expect(expectedMap, isNotNull);
        expect(actualMap, isNotNull);
        expect(actualMap, hasLength(expectedMap.length));
        for (final i in expectedMap.keys) {
          final expectedList = expectedMap[i]!;
          final actualList = actualMap[i]!;
          expect(expectedList, isNotNull);
          expect(actualList, isNotNull);
          expect(actualList, hasLength(expectedList.length));
          expectedList.sort((a, b) => attendanceSortKey(a).compareTo(attendanceSortKey(b)));
          actualList.sort((a, b) => attendanceSortKey(a).compareTo(attendanceSortKey(b)));

          for (int i=0; i<expectedList.length; i++) {
            expect(
              actualList[i],
              isA<Attendance>()
                  .having((p0) => p0.student.registration, 'studentRegistration', equals(expectedList[i].student.registration))
                  .having((p0) => p0.student.individual.individualRegistration, 'studentRegistration', equals(expectedList[i].student.individual.individualRegistration))
                  .having((p0) => p0.student.individual.name, 'studentName', equals(expectedList[i].student.individual.name))
                  .having((p0) => p0.student.individual.surname, 'studentSurname', equals(expectedList[i].student.individual.surname))
                  .having((p0) => p0.lesson.subjectClass.subject.code, 'subjectCode', equals(expectedList[i].lesson.subjectClass.subject.code))
                  .having((p0) => p0.lesson.subjectClass.subject.name, 'subjectName', equals(expectedList[i].lesson.subjectClass.subject.name))
                  .having((p0) => p0.lesson.subjectClass.year, 'classYears', equals(expectedList[i].lesson.subjectClass.year))
                  .having((p0) => p0.lesson.subjectClass.semester, 'classSemester', equals(expectedList[i].lesson.subjectClass.semester))
                  .having((p0) => p0.lesson.subjectClass.name, 'className', equals(expectedList[i].lesson.subjectClass.name))
                  .having((p0) => p0.lesson.subjectClass.teacher.registration, 'classTeacherRegistration', equals(expectedList[i].lesson.subjectClass.teacher.registration))
                  .having((p0) => p0.lesson.subjectClass.teacher.individual.individualRegistration, 'classTeacherIndividualRegistration', equals(expectedList[i].lesson.subjectClass.teacher.individual.individualRegistration))
                  .having((p0) => p0.lesson.subjectClass.teacher.individual.name, 'classTeacherName', equals(expectedList[i].lesson.subjectClass.teacher.individual.name))
                  .having((p0) => p0.lesson.subjectClass.teacher.individual.surname, 'classTeacherSurname', equals(expectedList[i].lesson.subjectClass.teacher.individual.surname))
                  .having((p0) => p0.lesson.utcDateTime, 'lessonUtcDateTime', equals(expectedList[i].lesson.utcDateTime))
                  .having((p0) => p0.lesson.teacher.registration, 'lessonTeacherRegistration', equals(expectedList[i].lesson.teacher.registration))
                  .having((p0) => p0.lesson.teacher.individual.individualRegistration, 'lessonTeacherIndividualRegistration', equals(expectedList[i].lesson.teacher.individual.individualRegistration))
                  .having((p0) => p0.lesson.teacher.individual.name, 'lessonTeacherName', equals(expectedList[i].lesson.teacher.individual.name))
                  .having((p0) => p0.lesson.teacher.individual.surname, 'lessonTeacherSurname', equals(expectedList[i].lesson.teacher.individual.surname))
            );
          }
        }
      }
    });
  });
}
