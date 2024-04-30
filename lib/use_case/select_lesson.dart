import 'package:facial_recognition/models/domain.dart';

class SelectLesson {
  SelectLesson(
      this._domainRepository,
  );

  final DomainRepository _domainRepository;

  List<Subject> getSubjects() => _domainRepository.getAllSubjects();

  List<SubjectClass> getSubjectClasses(
    Subject subject,
  ) => _domainRepository.getSubjectClassFromSubject([subject])[subject]!;

  List<Lesson> getLessons(
    SubjectClass subjectClass,
  ) => _domainRepository.getLessonFromSubjectClass([subjectClass])[subjectClass]!;
}
