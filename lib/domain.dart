import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:camera/camera.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as pkg_image;

import 'package:tflite_flutter/tflite_flutter.dart' as tflite;

/// Detect any faces on [image].
Future<List<Face>> detectFaces(InputImage image) {
  final detector = FaceDetector(
    options: FaceDetectorOptions(),
  );

  return detector.processImage(image);
}

/// Return logical images of subareas from [image].
List<pkg_image.Image> cropImage(
    pkg_image.Image image, final List<dart_ui.Rect> areas) {
  return List.generate(areas.length, (index) {
    // NOTE - (?) rect x axis origin is at top right (?)
    final rect = areas[index];
    return pkg_image.copyCrop(image,
        x: (image.width-1) - (rect.left+rect.width).toInt(),
        y: rect.top.toInt(),
        width: rect.width.toInt(),
        height: rect.height.toInt());
  }, growable: false);
}

/// Resize the *image* to match [size]
pkg_image.Image resizeImage(pkg_image.Image image, int width, int height) {
  return pkg_image.copyResize(image, width: width, height: height);
}

DomainRepository domainRepository = DomainRepository();

/// Search for a matching person that corresponds to [embedding]
Map<Student, Iterable<FacialData>> getFacialDataFromSubjectClass(
  SubjectClass subjectClass,
) {
  final studentByClass =
      domainRepository.getStudentFromSubjectClass([subjectClass]);
  final facialDataByStudent = domainRepository.getFacialDataFromStudent(studentByClass[subjectClass]!);
  projectLogger.info(studentByClass);
  projectLogger.info(facialDataByStudent);
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
              fd, studentFacialData.key, featuresDistance(embedding[0], fd.data)),
        );
      }
    }
  }
  return result;
}

const double recognitionDistanceThreshold = 0.20;

void writeStudentAttendance(
  Iterable<Student> student,
  Lesson lesson,
) {
  final a = student.map((s) => Attendance(student: s, lesson: lesson));
  domainRepository.addAttendance(a);
}

void AddStudentToSubjectClass(List<FacialData> facialData, SubjectClass) {
  // TODO - code
  return;
}

void faceNotRecognized(
  Map<FaceEmbedding, FacialDataDistance?> notRecognized,
  SubjectClass subjectClass
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

// HELPER ------
/// Convert a [image] from camera to an image used by the Google ML Kit
InputImage? toInputImage(CameraImage image, int controllerSensorOrientation) {
  final imageRotation =
      InputImageRotationValue.fromRawValue(controllerSensorOrientation);
  if (imageRotation == null) {
    projectLogger.severe("Couldn't identify the sensor orientation value");
    return null;
  }

  final inputImageFormat = InputImageFormatValue.fromRawValue(image.format.raw);
  if (inputImageFormat == null) {
    projectLogger.severe("Couldn't identify the image format type");
    return null;
  }

  final WriteBuffer allPlanesCopy = WriteBuffer(
      startCapacity: image.planes
          .map((Plane plane) => plane.bytes.length)
          .reduce((value, element) => value + element));
  for (final plane in image.planes) {
    allPlanesCopy.putUint8List(plane.bytes);
  }
  final bytes = allPlanesCopy.done().buffer.asUint8List();

  final imageSize = dart_ui.Size(image.width.toDouble(), image.height.toDouble());

  final planeData = image.planes
      .map(
        (Plane plane) => InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        ),
      )
      .toList();

  final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData);

  final inputImage =
      InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);

  return inputImage;
}

pkg_image.Image toLogicalImage({
  required int width,
  required int height,
  required ByteBuffer rgbBytes
}) {
  final image = pkg_image.Image.fromBytes(
    width: width,
    height: height,
    bytes: rgbBytes,
    order: pkg_image.ChannelOrder.rgb,
  );
  return pkg_image.flipHorizontal(pkg_image.copyRotate(image,angle: 270));
}

/// Convert YCbCr (called YUV) 4:2:0 3-plane to an RGB 1-plane.
///
/// RGB plane is generated by reading the image from left to right and top to
/// bottom and interleaving the color bytes as r1,g1,b1,r2,g2,b2,....
ByteBuffer yCbCr420ToRgb({
  required final int width,
  required final int height,
  required final List<Plane> planes
}) {
  final yBytes = planes[0].bytes;   // Y
  final cbBytes = planes[1].bytes;  // U
  final crBytes = planes[2].bytes;  // V
  final yBytesPerPixel = planes[0].bytesPerPixel ?? 1;
  final yBytesPerRow = planes[0].bytesPerRow;
  final cbCrBytesPerPixel = planes[1].bytesPerPixel ?? 1;
  final cbCrBytesPerRow = planes[1].bytesPerRow;

  final WriteBuffer rgbBytes = WriteBuffer(startCapacity: 3*width*height);

  for (int y = 0; y < height; y++){
    for (int x = 0; x < width; x++) {
      final int yIndex = mapBiToUniDimCoord(x, y, 1, 1, yBytesPerPixel, yBytesPerRow);
      final int cbCrIndex = mapBiToUniDimCoord(x, y, 2, 2, cbCrBytesPerPixel, cbCrBytesPerRow);

      final yV = yBytes[yIndex];
      final cbV = cbBytes[cbCrIndex];
      final crV = crBytes[cbCrIndex];

      final r = (yV + crV * 1436 / 1024 - 179).round().clamp(0, 255);
      final g = (yV - cbV * 46549 / 131072 + 44 - crV * 93604 / 131072 + 91)
          .round()
          .clamp(0, 255);
      final b = (yV + cbV * 1814 / 1024 - 227).round().clamp(0, 255);

      rgbBytes.putUint8(r);
      rgbBytes.putUint8(g);
      rgbBytes.putUint8(b);
    }
  }

  return rgbBytes.done().buffer;
}

Future<Uint8List> convertToJpg(pkg_image.Image image) async {
  if (image.format != pkg_image.Format.uint8 || image.numChannels != 4) {
    final cmd = pkg_image.Command()
      ..image(image)
      ..convert(format: pkg_image.Format.uint8, numChannels: 4);
    final rgba8 = await cmd.getImageThread();
    if (rgba8 != null) {
      image = rgba8;
    }
  }

  return pkg_image.encodeJpg(image);
}

/// Find the coord for the element that hold information about the element at coord ([x], [y]).
///
/// 1 element on unidimensional space represent a group of [xGroup] by [yGroup]
/// [elementSize] and [xSize] serve to virtualy split the unidimensinal
/// dimension.
int mapBiToUniDimCoord(int x, int y, int xGroup, int yGroup, int elementSize, int xSize) {
  return x~/xGroup*elementSize + y~/yGroup*xSize;
}

/// Create a facial recognition data for each face in [facesRgbMatrix]
///
/// faces features are encoded from a rgb matrix (with size 160x160) that
/// represent a face image
Future<List<List<double>>> extractFaceEmbedding(List<List<List<List<double>>>> facesRgbMatrix) async {
  const modelPath = 'assets/facenet512_00d21808fc7d.tflite';
  const modelOutputLength = 512;
  final interpreterOptions = tflite.InterpreterOptions();
  if (Platform.isAndroid) {
    interpreterOptions.useNnApiForAndroid = true;
  }
  else if (Platform.isIOS) {
    interpreterOptions.useMetalDelegateForIOS = true;
  }
  final interpreter = await tflite.Interpreter.fromAsset(modelPath, options: interpreterOptions);
  projectLogger.shout('inputT: ${interpreter.getInputTensors()} outputT: ${interpreter.getOutputTensors()}');

  final outputs = {
    0: [
      for (int i = 0; i < facesRgbMatrix.length; i++)
        List<double>.filled(modelOutputLength, 0.0)
    ]
  };
  interpreter.runForMultipleInputs([facesRgbMatrix], outputs);

  interpreter.close();
  interpreterOptions.delete();

  // retrieve the output list from the output map and return it
  return Future.value(outputs[0]);
}

///
double featuresDistance(List<double> embedding1, List<double> embedding2) {
  return euclideanDistance(embedding1, embedding2);
}

///
double euclideanDistance(List<num> A, List<num> B) {
  if (A.length != B.length) {
    throw ArgumentError('expected both vectors to have the same length');
  }
  double res = 0.0;
  for (var i = 0; i < A.length; i++) {
    res += pow(B[i] - A[i], 2);
  }
  return sqrt(res);
}

///
List<List<List<T>>> rgbListToMatrix<T>(List<T> buffer, int width, int height) {
  // image origin is (x,y)=(0,0) on the top left corner, x and y grow to the
  // right and bottom respectivelly
  const nColorChannels = 3;
  // generate lines
  return List.generate(height,
    // generate colums
    (y) => List.generate(width,
      // generate group of k colors
      (x) => List.generate(nColorChannels,
        (z) => buffer[y * width * nColorChannels + x * nColorChannels + z],
        growable: false,
      ),
      growable: false,
    ),
    growable: false,
  );
}

Float32List standardizeImage(Uint8List image, int width, int height) {
  final imageBuffer = image.buffer.asUint8List();
  // per row sum before calculating the mean
  final double mean = List<double>.generate(height,
    (row) {
      double rowSum = 0.0;
      // rgb (3 values) * imageWidth
      for (var column = 0; column < width*3; column++) {
        rowSum += imageBuffer[row*width+column];
      }
      return rowSum;
    }).reduce(
      (value, element) => value+element/height*width*3);
  final double std = sqrt(imageBuffer.fold<double>(0.0,
          (previousValue, element) => previousValue + pow(element - mean, 2)) /
      (width * height * 3));

  return Float32List.fromList([for (var i = 0; i < height*width*3; i++) (imageBuffer[i]-mean)/std]);
}
