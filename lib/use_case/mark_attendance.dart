import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';

class MarkAttendance {
  MarkAttendance(
    this.domainRepository,
    this.lesson,
  );

  final Lesson lesson;
  final DomainRepository domainRepository;

  Iterable<EmbeddingRecognized> getFaceRecognizedFromCamera() {
    final result = domainRepository.getCameraRecognized([lesson]);
    return result[lesson] ?? [];
  }

  void removeFaceRecognizedFromCamera(
    Iterable<EmbeddingRecognized> recognition,
  ) {
    domainRepository.removeFaceEmbeddingRecognizedFromCamera(recognition, lesson);
  }

  Iterable<EmbeddingNotRecognized> getFaceNotRecognizedFromCamera() {
    final result = domainRepository.getCameraNotRecognized([lesson]);
    return result[lesson] ?? [];
  }

  void writeStudentAttendance(
    Iterable<Student> students,
  ) {
    if (students.isEmpty) {
      return;
    }

    final a = students.map((s) => Attendance(student: s, lesson: lesson));
    domainRepository.addAttendance(a);
  }

  Map<Student, FacePicture?> getStudentFaceImage() {
    final students = domainRepository.getStudentFromSubjectClass([lesson.subjectClass])[lesson.subjectClass]!;
    return domainRepository.getFacePictureFromStudent(students);
  }
}
