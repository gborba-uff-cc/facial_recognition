import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:camera/camera.dart' as pkg_camera;
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/facenet_face_recognizer.dart';
import 'package:facial_recognition/models/google_face_detector.dart';
import 'package:facial_recognition/models/image_handler.dart';
import 'package:facial_recognition/utils/distance.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as pkg_image;

// -----------------------------------------------------------------------------
final _faceDetector = GoogleFaceDetector();

/// Detect any faces on [image].
Future<List<dart_ui.Rect>> detectFaces({
  required final pkg_camera.CameraImage image,
  final int controllerSensorOrientation = 0,
}) async => await _faceDetector.detect(image, controllerSensorOrientation);

// -----------------------------------------------------------------------------
final _imageHandler = ImageHandler();

///
pkg_image.Image toLogicalImage({
  required final pkg_camera.CameraImage image,
}) => _imageHandler.fromCameraImage(image);

/// Return subareas from [image].
List<pkg_image.Image> cropImage({
    required final pkg_image.Image image,
    required final List<dart_ui.Rect> areas
}) => _imageHandler.cropFromImage(image, areas);

///
Uint8List convertToJpg(
  pkg_image.Image image,
) => _imageHandler.toJpeg(image);

/// Resize [image] to match [width] and [height]
pkg_image.Image resizeImage({
  required pkg_image.Image image,
  required int width,
  required int height,
}) => _imageHandler.resizeImage(image, width, height);

List<List<List<int>>> rgbListToMatrix(
  pkg_image.Image image,
) => _imageHandler.toRgbMatrix(image);

// -----------------------------------------------------------------------------
final _faceRecognizer = FacenetFaceEmbedder();

Future<List<FaceEmbedding>> extractFaceEmbedding(
  List<List<List<List<num>>>> facesRgbMatrix,
) => _faceRecognizer.extractEmbedding(facesRgbMatrix);

double faceEmbeddingDistance(
  FaceEmbedding embedding1,
  FaceEmbedding embedding2,
) => euclideanDistance(embedding1, embedding2);

// -----------------------------------------------------------------------------
DomainRepository domainRepository = DomainRepository();

/// Search for a matching person that corresponds to [embedding]
Map<Student, Iterable<FacialData>> getFacialDataFromSubjectClass(
  SubjectClass subjectClass,
) {
  final studentByClass =
      domainRepository.getStudentFromSubjectClass([subjectClass]);
  final facialDataByStudent = domainRepository.getFacialDataFromStudent(studentByClass[subjectClass]!);
  return facialDataByStudent;
}

class FacialDataDistance {
  final FacialData facialData;
  final Student student;
  final double distance;

  FacialDataDistance(
    this.facialData,
    this.student,
    this.distance,
  );
}

class CouldntSearchException implements Exception {}

/// give the distance
Map<FaceEmbedding, List<FacialDataDistance>> getFacialDataDistance(
  final List<List<double>> embedding,
  final Map<Student, Iterable<FacialData>> facialDataByStudent,
) {
  final result = { for (final e in embedding) e : <FacialDataDistance>[] };
  for (final e in embedding) {
    for (final studentFacialData in facialDataByStudent.entries) {
      for (final fd in studentFacialData.value) {
        result[e]?.add(
          FacialDataDistance(
              fd, studentFacialData.key, faceEmbeddingDistance(embedding[0], fd.data)),
        );
      }
    }
  }
  return result;
}

const double recognitionDistanceThreshold = 20.0;

void writeStudentAttendance(
  Iterable<Student> student,
  Lesson lesson,
) {
  final a = student.map((s) => Attendance(student: s, lesson: lesson));
  domainRepository.addAttendance(a);
}

void addStudentToSubjectClass(
  Map<FaceEmbedding, FacialDataDistance?> notRecognized,
  SubjectClass subjectClass,
) {
  final individuals = <Individual>[];
  final facialsData = <FacialData>[];
  final students = <Student>[];
  final enrollments = <Enrollment>[];
  for (final entry in notRecognized.entries) {
    final rand = Random();
    final ir = List.generate(11, (index) => rand.nextInt(10)).join();
    final name = List.generate(8, (index) => (rand.nextInt(26)+97)).map(String.fromCharCode).join();
    final reg = List.generate(9, (index) => rand.nextInt(10)).join();

    final i = Individual(individualRegistration: ir, name: name);
    final fd = FacialData(data: entry.key, individual: i);
    final s = Student(registration: reg, individual: i);
    final e = Enrollment(student: s, subjectClass: subjectClass);

    individuals.add(i);
    facialsData.add(fd);
    students.add(s);
    enrollments.add(e);
  }
  domainRepository.addIndividual(individuals);
  domainRepository.addFacialData(facialsData);
  domainRepository.addStudent(students);
  domainRepository.addEnrollment(enrollments);
}

void faceNotRecognized(
  Map<FaceEmbedding, FacialDataDistance?> notRecognized,
  SubjectClass subjectClass
) {
  // TODO - code
}

class _DeferredAttendanceRecord {
  final List<FaceEmbedding> facesEmbedding;
  final Lesson lesson;

  _DeferredAttendanceRecord(
    this.facesEmbedding,
    this.lesson,
  );
}

final _deferredAttendance = <_DeferredAttendanceRecord>[];

void deferAttendance(List<FaceEmbedding> facesEmbedding, lesson) {
  _deferredAttendance.add(
    _DeferredAttendanceRecord(facesEmbedding, lesson),
  );
}
