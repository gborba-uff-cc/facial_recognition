import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';

class MarkAttendance {
  MarkAttendance(
    this.domainRepository,
    this.lesson,
  );

  final Lesson lesson;
  final IDomainRepository domainRepository;

  Iterable<EmbeddingRecognitionResult> getRecognitionFromCamera() {
    final recognized = domainRepository.getCameraRecognized([lesson])[lesson];
    final notRecognized =
        domainRepository.getCameraNotRecognized([lesson])[lesson];
    final Iterable<EmbeddingRecognitionResult> result =
        List.unmodifiable(<EmbeddingRecognitionResult>[
      if (recognized != null && recognized.isNotEmpty) ...recognized,
      if (notRecognized != null && notRecognized.isNotEmpty) ...notRecognized,
    ]);
    return result;
  }

  void updateRecognitionFromCamera(
    EmbeddingRecognitionResult recognition,
    Student? other,
  ) {
    final aux = EmbeddingRecognitionResult(
      inputFace: recognition.inputFace,
      inputFaceEmbedding: recognition.inputFaceEmbedding,
      recognized: other != null ? true : false,
      nearestStudent: other,
    );
    domainRepository.replaceRecordOfRecognitionResultFromCamera(
      recognition,
      aux,
      lesson,
    );
  }

  void removeRecognitionFromCamera(
    final Iterable<EmbeddingRecognitionResult> recognition,
  ) {
    final List<EmbeddingRecognitionResult> recognized = [];
    final List<EmbeddingRecognitionResult> notRecognized = [];

    for (final r in recognition) {
      if (r.recognized) {
        recognized.add(r);
      }
      else {
        notRecognized.add(r);
      }
    }

    domainRepository.removeFaceEmbeddingRecognizedFromCamera(recognized, lesson);
    domainRepository.removeFaceEmbeddingNotRecognizedFromCamera(notRecognized, lesson);
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
