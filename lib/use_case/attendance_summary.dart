import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';

class AttendanceSummary {
  AttendanceSummary(
    this.domainRepository,
    this.subjectClass,
  );

  final IDomainRepository domainRepository;
  final SubjectClass subjectClass;

  Map<Student, FacePicture?> getStudentFaceImage() {
    final students = domainRepository
        .getStudentFromSubjectClass([subjectClass])[subjectClass]!;
    return domainRepository.getFacePictureFromStudent(students);
  }

  Map<Student, List<Attendance>> getSubjectClassAttendance() {
    return domainRepository
        .getSubjectClassAttendance([subjectClass])[subjectClass] ?? Map.unmodifiable({});
  }
}
