import 'package:facial_recognition/models/domain.dart';

class SelectInformationReturn {
  const SelectInformationReturn({
    this.subject,
    this.subjectClass,
    this.lesson,
  });

  final Subject? subject;
  final SubjectClass? subjectClass;
  final Lesson? lesson;
}
