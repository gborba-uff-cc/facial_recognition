import 'package:facial_recognition/models/domain.dart';

import './core.dart';

class _ModelsCollection {
  final List<Individual> individuals;
  final List<FacialData> facialsData;
  final List<Student> students;
  final List<Teacher> teachers;
  final List<Subject> subjects;
  final List<SubjectClass> classes;
  final List<Lesson> lessons;
  final List<Enrollment> enrollments;
  final List<Attendance> attendances;

  _ModelsCollection({
    required this.individuals,
    required this.facialsData,
    required this.students,
    required this.teachers,
    required this.subjects,
    required this.classes,
    required this.lessons,
    required this.enrollments,
    required this.attendances,
  });
}

_ModelsCollection _newRepository() {
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
  final nowDateTime = DateTime.now().toUtc();
  final lessons = List<Lesson>.unmodifiable(<Lesson>[
    Lesson(subjectClass: classes[0], utcDateTime: nowDateTime, teacher: teachers[0]),
    Lesson(subjectClass: classes[1], utcDateTime: nowDateTime, teacher: teachers[1]),
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

  return _ModelsCollection(
    individuals: individuals,
    facialsData: facialsData,
    students: students,
    teachers: teachers,
    subjects: subjects,
    classes: classes,
    lessons: lessons,
    enrollments: enrollments,
    attendances: attendances
  );
}

int main() {
  int returnCode = 0;
  bool allTestsSucceded = true;
  final repo = _newRepository();

  allTestsSucceded &= test(
    'all students from a given class',
    () {
      // all students from a given class
      final expected = [
        ['s00000003', [0.0,0.1,0.0,0.3]],
        ['s00000003', [0.0,0.2,0.0,0.3]],
        ['s00000003', [0.0,0.3,0.0,0.3]],
      ];
      const targetSubjectClassName = 'classA';
      const targetSubjectClassYear = 2024;
      const targetSubjectClassSemester = 1;
      final selected = [];

      for (final e in repo.enrollments) {
        for (final fd in repo.facialsData) {
          if (e.student.individual.individualRegistration == fd.individual.individualRegistration && (
            e.subjectClass.name == targetSubjectClassName &&
            e.subjectClass.year == targetSubjectClassYear &&
            e.subjectClass.semester == targetSubjectClassSemester
          )) {
            selected.add([
              e.student.registration,
              fd.data
            ]);
          }
        }
      }

      if (selected.length != expected.length) {
        return false;
      }
      for (int i=0; i<expected.length; i++) {
        if (!equalLists(selected[i], expected[i])) {
          return false;
        }
      }
      return true;
    },
  );

  showTestssucceded(allTestsSucceded);
  return returnCode;
}
