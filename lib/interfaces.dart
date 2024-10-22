import 'dart:typed_data';
import 'dart:ui';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';

abstract class IRecognitionPipeline<CI, CC, I, J, L, V> {
  Future<List<I>> detectFace({
    required final CI cameraImage,
    required final CC cameraController,
  });

  Future<List<Duple<J, FaceEmbedding>>> extractEmbedding(
    final List<I> faces,
  );

  Duple<Iterable<EmbeddingRecognitionResult>, Iterable<EmbeddingRecognitionResult>>
      recognizeEmbedding(
    final Iterable<Duple<J, FaceEmbedding>> input,
    final Map<L, Iterable<V>>embeddingsByStudent,
  );
}

abstract class IFaceDetector<CI, CC> {
  Future<List<Rect>> detect({
    required final CI cameraImage,
    required final CC cameraController,
  });
}

abstract class IImageHandler<CI, CD, I, J> {
  I fromCameraImage(final CI cameraImage, CD cameraDescription);
  List<I> cropFromImage(final I image, final List<Rect> rect);
  I resizeImage(final I image, final int width, final int height);
  I flipHorizontal(final I image);
  I rotateImage(I image, num angle);
  J toJpg(final I image);
  I? fromJpg(final J jpgBytes);
  List<List<List<int>>> toRgbMatrix(final I image);
  Uint8List toBgraBuffer(I image);
}

abstract class IFaceEmbedder {
  int get neededImageWidth;
  int get neededImageHeight;
  Future<List<FaceEmbedding>> extractEmbedding(final List<List<List<List<num>>>> facesRgbMatrix);
}

abstract class IFaceRecognizer<TLabel, TElement> {
  /// return the most alike label among the data set and the a recognition value
  Map<TElement, IFaceRecognitionResult<TLabel>> recognize(
    final Iterable<TElement> unknown,
    final Map<TLabel, Iterable<TElement>> dataSet,
  );

  double get recognitionThreshold;
}

abstract class IFaceRecognitionResult<TLabel> {
  double get recognitionValue;
  FaceRecognitionStatus get status;
  TLabel get label;
}

enum FaceRecognitionStatus {
  recognized,
  notRecognized,
}

abstract class ICameraAttendance<CI, CD> {
  void onNewCameraImage(
    final CI cameraImage,
    final CD cameraDescription,
  );
}

typedef DistanceFunction<TElement> = double Function(TElement a, TElement b);

abstract class IDomainRepository{
  void dispose();

  void addAttendance(Iterable<Attendance> attendance);

  void addEnrollment(Iterable<Enrollment> enrollment);

  void addFaceEmbeddingToCameraNotRecognized(Iterable<EmbeddingRecognitionResult> notRecognized, Lesson lesson);

  void addFaceEmbeddingToCameraRecognized(Iterable<EmbeddingRecognitionResult> recognized, Lesson lesson);

  void addFaceEmbeddingToDeferredPool(Iterable<Duple<JpegPictureBytes, FaceEmbedding>> embedding, Lesson lesson);

  void addFacePicture(Iterable<FacePicture> facePicture);

  void addFacialData(Iterable<FacialData> facialData);

  void addIndividual(Iterable<Individual> individual);

  void addLesson(Iterable<Lesson> lesson);

  void addStudent(Iterable<Student> student);

  void addSubject(Iterable<Subject> subject);

  void addSubjectClass(Iterable<SubjectClass> subjectClass);

  void addTeacher(Iterable<Teacher> teacher);

  List<Subject> getAllSubjects();

  Map<Lesson, Iterable<EmbeddingRecognitionResult>> getCameraNotRecognized(Iterable<Lesson> lesson);

  Map<Lesson, Iterable<EmbeddingRecognitionResult>> getCameraRecognized(Iterable<Lesson> lesson);

  Map<Lesson, Iterable<Duple<JpegPictureBytes, FaceEmbedding>>> getDeferredFacesEmbedding(Iterable<Lesson> lesson);

  Map<Student, FacePicture?> getFacePictureFromStudent(Iterable<Student> student);

  Map<Teacher, FacePicture?> getFacePictureFromTeacher(Iterable<Teacher> teacher);

  Map<Student, List<FacialData>> getFacialDataFromStudent(Iterable<Student> student);

  Map<Teacher, List<FacialData>> getFacialDataFromTeacher(Iterable<Teacher> teacher);

  Map<String, Individual?> getIndividualFromRegistration(Iterable<String> individualRegistration);

  Map<SubjectClass, List<Lesson>> getLessonFromSubjectClass(Iterable<SubjectClass> subjectClass);

  Map<String, Student?> getStudentFromRegistration(Iterable<String> registration);

  Map<SubjectClass, List<Student>> getStudentFromSubjectClass(Iterable<SubjectClass> subjectClass);

  SubjectClass? getSubjectClass({required int year, required int semester, required String subjectCode, required String name});

  Map<SubjectClass, Map<Student, List<Attendance>>> getSubjectClassAttendance(Iterable<SubjectClass> subjectClass);

  Map<Subject, List<SubjectClass>> getSubjectClassFromSubject(Iterable<Subject> subject);

  Map<String, Subject?> getSubjectFromCode(Iterable<String> code);

  Map<String, Teacher?> getTeacherFromRegistration(Iterable<String> registration);

  void removeFaceEmbeddingNotRecognizedFromCamera(Iterable<EmbeddingRecognitionResult> recognition, Lesson lesson);

  void removeFaceEmbeddingRecognizedFromCamera(Iterable<EmbeddingRecognitionResult> recognition, Lesson lesson);

  void replaceRecordOfRecognitionResultFromCamera(EmbeddingRecognitionResult oldRecord, EmbeddingRecognitionResult newRecord, Lesson lesson);
}