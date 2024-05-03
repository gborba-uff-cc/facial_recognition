import 'dart:io';
import 'dart:math';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../interfaces.dart';

class FacenetFaceEmbedder implements IFaceEmbedder {
  static const _modelPath = 'assets/facenet512_00d21808fc7d.tflite';
  static const _modelOutputLength = 512;
  late final InterpreterOptions _interpreterOptions;
  late final Future<Interpreter> _interpreter;

  @override
  int get neededImageHeight => 160;

  @override
  int get neededImageWidth => 160;

  ///
  FacenetFaceEmbedder() {
    _interpreterOptions = InterpreterOptions();
    if (Platform.isAndroid) {
      _interpreterOptions.useNnApiForAndroid = true;
    }
    else if (Platform.isIOS) {
      _interpreterOptions.useMetalDelegateForIOS = true;
    }
    _interpreter = Interpreter.fromAsset(
      _modelPath,
      options: _interpreterOptions,
    );
    _interpreter.then((interpreter) {
      projectLogger.info('inputT: ${interpreter.getInputTensors()} outputT: ${interpreter.getOutputTensors()}');
    });
  }

  ///
  void close() async {
    (await _interpreter).close();
    _interpreterOptions.delete();
  }

  /// Generate a embedding for each face in facesRpgMatrix
  ///
  /// face `image` should be preprocessed as follows: 160x160x3 width, height
  /// and colors channels (in RGB order).
  @override
  Future<List<FaceEmbedding>> extractEmbedding(
    List<List<List<List<num>>>> facesRgbMatrix,
  ) async {
    if (facesRgbMatrix.isEmpty) {
      return List.empty(growable: false);
    }

    final stdRgbMatrix = facesRgbMatrix.map(_standardizeImage).toList();
    final results = <FaceEmbedding>[
      for (int i = 0; i < facesRgbMatrix.length; i++)
        List<double>.filled(_modelOutputLength, 0.0)
    ];

    (await _interpreter).runForMultipleInputs([stdRgbMatrix], { 0: results });
    return results;
  }


  ///
  List<List<List<double>>> _standardizeImage(List<List<List<num>>> image) {
    final nElements = image.length * image[0].length * image[0][0].length;

    var mean = 0.0;
    for (final line in image) {
      for (final column in line) {
        for (final channelValue in column) {
          mean += channelValue;
        }
      }
    }
    mean /= nElements;

    var squaredDeviation = 0.0;
    for (final line in image) {
      for (final column in line) {
        for (final channelValue in column) {
          squaredDeviation += pow(channelValue - mean, 2.0);
        }
      }
    }
    final std = sqrt(squaredDeviation / nElements);

    return image.map(
      (line) => line.map(
        (column) => column.map(
          (channelValue) => (channelValue - mean) / std,
        ).toList(growable: false),
      ).toList(growable: false),
    ).toList(growable: false);
  }
}
