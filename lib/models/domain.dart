import 'dart:typed_data';

import 'package:facial_recognition/models/use_case.dart';

class Individual {
  String individualRegistration;
  String name;
  String? surname;

  Individual({
    required this.individualRegistration,
    required this.name,
    this.surname,
  });

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
  final Set<Student> _student = {};
  final Set<Teacher> _teacher = {};
  final Set<Subject> _subject = {};
  final Set<SubjectClass> _subjectClass = {};
  final Set<Lesson> _lesson = {};
  final Set<Enrollment> _enrollment = {};
  final Set<Attendance> _attendance = {};
  // ---
  final Map<Lesson, List<Duple<Uint8List, FaceEmbedding>>> _faceEmbeddingDeferredPool = {};
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
// ---------------------------

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
  // ---
  Map<Lesson, Iterable> getDeferredFacesEmbedding(Iterable<Lesson>? lesson) {
    final Map<Lesson, Iterable>result;
    if (lesson == null) {
      result = {
        for (final l in _faceEmbeddingDeferredPool.keys)
          l : _faceEmbeddingDeferredPool[l]!.toList()
      };
    }
    else {
      result = {
        for (final l in lesson)
          l : _faceEmbeddingDeferredPool[lesson]?.toList() ?? []
      };
    }
    return result;
  }
}
