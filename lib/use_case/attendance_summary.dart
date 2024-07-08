import 'package:facial_recognition/models/domain.dart';

class AttendanceSummary {
  AttendanceSummary(
    this.domainRepository,
    this.subjectClass,
  );

  final DomainRepository domainRepository;
  final SubjectClass subjectClass;

  Map<Student, List<Attendance>>? getSubjectClassAttendance() {
    return domainRepository.getSubjectClassAttendance([subjectClass])[subjectClass];
  }
}
