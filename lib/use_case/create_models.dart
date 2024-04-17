import 'package:facial_recognition/models/domain.dart';

class CreateModels {
  CreateModels(
    this._domainRepository,
  );

  final DomainRepository _domainRepository;

  void createLesson(
    SubjectClass subjectClass,
    DateTime utcDateTime,
    Teacher teacher,
  ) {
    final lesson = Lesson(
      subjectClass: subjectClass,
      utcDateTime: utcDateTime,
      teacher: teacher,
    );
    _domainRepository.addLesson([lesson]);
  }

  void createSubjectClass(
    Subject subject,
    int year,
    int semester,
    String name,
    Teacher teacher,
  ) {
    final subjectClass = SubjectClass(
      subject: subject,
      year: year,
      semester: semester,
      name: name,
      teacher: teacher,
    );
    _domainRepository.addSubjectClass([subjectClass]);
  }

  void createTeacher(
    String registration,
    Individual individual,
  ) {
    final teacher = Teacher(
      registration: registration,
      individual: individual,
    );
    _domainRepository.addTeacher([teacher]);
  }

  void createSubject(
    String code,
    String name,
  ) {
    final subject = Subject(code: code, name: name);
    _domainRepository.addSubject([subject]);
  }
}
