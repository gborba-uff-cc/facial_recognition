import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';

class MarkAttendance {
  MarkAttendance(this.domainRepository, this.lesson);

  final Lesson lesson;
  final DomainRepository domainRepository;

  Iterable<EmbeddingRecognized> getFaceRecognizedFromCamera() {
    return domainRepository.getCameraRecognized([lesson])[lesson] ?? [];
  }
}
