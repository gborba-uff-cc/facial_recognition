import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:image/image.dart';

import '../interfaces.dart';
import '../utils/project_logger.dart';

class CameraAttendance implements ICameraAttendance<CameraImage> {
  CameraAttendance(
    IFaceDetector<CameraImage> faceDetector,
    IImageHandler<CameraImage, Image, Uint8List> imageHandler,
    IFaceRecognizer faceRecognizer,
    DomainRepository domainRepository,
    this.showFaceImages,
    this.lesson,
  ) :
    _detector = faceDetector,
    _imageHandler = imageHandler,
    _recognizer = faceRecognizer,
    _domainRepo = domainRepository;

  final IFaceDetector<CameraImage> _detector;
  final IImageHandler<CameraImage, Image, Uint8List> _imageHandler;
  final IFaceRecognizer _recognizer;
  final DomainRepository _domainRepo;
  void Function(Iterable<Uint8List> jpegImages) showFaceImages;
  final Lesson lesson;

  final double _recognitionDistanceThreshold = 20.0;

  @override
  Future<void> onNewCameraImage(
    final CameraImage image,
    final int cameraSensorOrientation,
  ) async {
    //
    final Iterable<Duple<Uint8List, FaceEmbedding>> jpegsAndEmbeddings =
        await _detectFaceAndExtractEmbedding(image, cameraSensorOrientation);

    // call back the function to handle the detected faces image
    showFaceImages(jpegsAndEmbeddings.map((e) => e.value1));

    // recognize embedding now
    final Duple<Iterable<_EmbeddingRecognized>,
        Iterable<_EmbeddingNotRecognized>> recognizedAndNot;
    try {
      recognizedAndNot =
          _recognizeEmbedding(jpegsAndEmbeddings, lesson.subjectClass);
    }
    on _TryRecognizeLater {
      projectLogger.info('could not recognize embedding now', e);
      _deferRecognizeEmbedding(jpegsAndEmbeddings, lesson);
      return;
    }
    catch (e) {
      projectLogger.severe('for some reason, other than to try recognize later, could not recognize embedding', e);
      return;
    }

    final Iterable<_EmbeddingRecognized> recognized = recognizedAndNot.value1;
    final Iterable<_EmbeddingNotRecognized> notRecognized = recognizedAndNot.value2;
    projectLogger.fine('recognized students ${recognized.length}');
    projectLogger.fine('not recognized students: ${notRecognized.length}');

/* REVIEW
- for recognized, would be better to ask for a human comparison before marking
the attendance
- for not recognized, would be better ask to update known facial data for student
*/
    // handle recognized students
    _writeStudentAttendance(recognized.map((r) => r.student), lesson);

    // handle not recognized faces embedding
    _faceNotRecognized(notRecognized, lesson.subjectClass);
  }

  Future<Iterable<Duple<Uint8List, FaceEmbedding>>>
      _detectFaceAndExtractEmbedding(
    final CameraImage image,
    final int cameraSensorOrientation,
  ) async {
    // detect faces
    final faceRects = await _detector.detect(image, cameraSensorOrientation);
    projectLogger.fine('detected faces: ${faceRects.length}');

    // detach faces into manipulable images
    final manipulableImage = _imageHandler.fromCameraImage(image);
    final faceImages = _imageHandler.cropFromImage(manipulableImage, faceRects);

    // create jpegs images and rgbMatrixes of detected face images
    final List<Uint8List> detectedFaces = [];
    final List<List<List<List<int>>>> samples = [];
    for (final i in faceImages) {
      final jpeg = _imageHandler.toJpeg(i);
      detectedFaces.add(jpeg);

      final resizedImage = _imageHandler.resizeImage(i, 160, 160);
      final imageMatrix = _imageHandler.toRgbMatrix(resizedImage);
      samples.add(imageMatrix);
    }

    // generate faces embedding
    List<FaceEmbedding> facesEmbedding = await _recognizer.extractEmbedding(samples);

    final List<Duple<Uint8List, FaceEmbedding>> result = [
      for (int i=0; i<detectedFaces.length; i++)
        Duple(detectedFaces[i], facesEmbedding[i])
    ];
    return result;
  }

  void _deferRecognizeEmbedding(
    final Iterable<Duple<Uint8List, FaceEmbedding>> input,
    final Lesson lesson,
  ) {
    projectLogger.info('face recognition is going to be deferred');
    _domainRepo.addFaceEmbeddingToDeferredPool(input, lesson);
  }

  /// trows _TryRecognizeLater if, for some reason, can't access face embeddings
  Duple<Iterable<_EmbeddingRecognized>, Iterable<_EmbeddingNotRecognized>>
      _recognizeEmbedding(
    final Iterable<Duple<Uint8List, FaceEmbedding>> input,
    final SubjectClass subjectClass,
  ) {
    final List<_EmbeddingRecognized> recognized = [];
    final List<_EmbeddingNotRecognized> notRecognized = [];
    final result = Duple(recognized, notRecognized);

    // retrieve all students in this class that have facial data added
    final Map<Student, Iterable<FacialData>> facialDataByStudent;
    try {
      facialDataByStudent = _getFacialDataFromSubjectClass(subjectClass);
    }
    catch (e) {  // STUB - change to the correct condition
      throw _TryRecognizeLater();
    }

    // no facial data registered
    if(facialDataByStudent.isEmpty) {
      notRecognized.addAll(
        input.map(
          (i) => _EmbeddingNotRecognized(
              i.value1, i.value2, null, null),
        ),
      );
      projectLogger.info(
        'This subject class has no student with facial data registered'
      );
      return result;
    }

    // list to reduce the amount of allocations to compute the nearest embedding
    final List<_StudentFaceEmbeddingDistance> embeddingDistances = [
      for (final studentAndEmbeddings in facialDataByStudent.entries)
        for (final e in studentAndEmbeddings.value)
          _StudentFaceEmbeddingDistance(studentAndEmbeddings.key, e.data)
    ];

    // compute embedding distances for all the input
    for (final referenceInput in input) {
      final jpeg = referenceInput.value1;
      final referenceEmbedding = referenceInput.value2;
      // measure distances
      for (final other in embeddingDistances) {
        other.distance = _recognizer.facesDistance(
            referenceEmbedding, other.storedEmbedding);
      }

      // decide which face feature is the nearest
      embeddingDistances.sort((e1, e2) => e1.distance.compareTo(e2.distance));

      // dicide whether the embedding could be recognized
      projectLogger.fine('nearest distance: ${embeddingDistances.first.distance}; furtherst distance: ${embeddingDistances.last.distance}');
      final nearest = embeddingDistances.first;
      if (nearest.distance < _recognitionDistanceThreshold) {
        final newEntry = _EmbeddingRecognized(jpeg, referenceEmbedding, nearest.storedEmbedding, nearest.student);
        recognized.add(newEntry);
      }
      else {
        final newEntry = _EmbeddingNotRecognized(jpeg, referenceEmbedding, nearest.storedEmbedding, nearest.student);
        notRecognized.add(newEntry);
      }
    }

    return result;
  }

  Map<Student, Iterable<FacialData>> _getFacialDataFromSubjectClass(
    SubjectClass subjectClass,
  ) {
    final studentByClass =
        _domainRepo.getStudentFromSubjectClass([subjectClass]);
    final facialDataByStudent = _domainRepo
        .getFacialDataFromStudent(studentByClass[subjectClass]!);
    return facialDataByStudent;
  }

  void _writeStudentAttendance(
    Iterable<Student> students,
    Lesson lesson,
  ) {
    if (students.isNotEmpty) {
      return;
    }

    final a = students.map((s) => Attendance(student: s, lesson: lesson));
    _domainRepo.addAttendance(a);
  }

  void _faceNotRecognized(
    Iterable<_EmbeddingNotRecognized> notRecognized,
    SubjectClass subjectClass,
  ) {
    if (notRecognized.isNotEmpty) {
      return;
    }

    // TODO - code
  }
}

class _TryRecognizeLater implements Exception {}

class _EmbeddingNotRecognized {
  // inputFace as a UInt8List jpeg
  final Uint8List inputFace;
  final FaceEmbedding inputEmbedding;
  final FaceEmbedding? nearestEmbedding;
  // who the nearestEmbedding belong
  final Student? student;

  _EmbeddingNotRecognized(
    this.inputFace,
    this.inputEmbedding,
    this.nearestEmbedding,
    this.student,
  );
}

class _EmbeddingRecognized {
  // inputFace as a UInt8List jpeg
  final Uint8List inputFace;
  final FaceEmbedding inputEmbedding;
  final FaceEmbedding nearestEmbedding;
  // who the nearestEmbedding belong
  final Student student;

  _EmbeddingRecognized(
    this.inputFace,
    this.inputEmbedding,
    this.nearestEmbedding,
    this.student,
  );
}

class _StudentFaceEmbeddingDistance {
  final Student student;
  final FaceEmbedding storedEmbedding;
  double distance;

  _StudentFaceEmbeddingDistance(
    this.student,
    this.storedEmbedding,
    [this.distance = 0.0,]
  );
}
