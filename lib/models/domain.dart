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

