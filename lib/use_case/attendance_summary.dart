import 'package:facial_recognition/models/domain.dart';

class AttendanceSummary {
  AttendanceSummary(
    this.domainRepository,
    this.lesson,
  );

  final DomainRepository domainRepository;
  final Lesson lesson;

  Map<Student, List<Attendance>>? getSubjectClassAttendance() {
    return domainRepository.getSubjectClassAttendance([lesson.subjectClass])[lesson.subjectClass];
  }
}
