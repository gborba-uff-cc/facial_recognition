import 'dart:math';

import 'package:tflite_flutter/tflite_flutter.dart';

import '../interfaces.dart';

class FacenetFaceRecognizer implements IFaceRecognizer {
  static const _modelPath = 'assets/facenet512_00d21808fc7d.tflite';
  static const _modelOutputLength = 512;
  late final InterpreterOptions _interpreterOptions;
  late final Future<Interpreter> _interpreter;

  @override
  int get neededImageHeight => 160;

  @override
  int get neededImageWidth => 160;

  ///
  FacenetFaceRecognizer() {
    _interpreterOptions = InterpreterOptions();
    _interpreterOptions.useNnApiForAndroid = true;
    _interpreterOptions.useMetalDelegateForIOS = true;
    _interpreter = Interpreter.fromAsset(
      _modelPath,
      options: _interpreterOptions,
    );
  }

  ///
  void close() {
    _interpreter.then(
      (interpreter) {
        interpreter.close();
        _interpreterOptions.delete();
      },
    );
  }

  /// Extract a feature vector from `image`
  ///
  /// face `image` should be preprocessed as follows: 160x160x3 width, height
  /// and colors channels (in RGB order).
  @override
  Future<List<double>> extractFeature(List<List<List<num>>> image) async {
    /*
    original model input (face matrix) shape=(160, 160, 3)
    tflite   model input (face matrix) shape=(1, 160, 160, 3)

    original model (multiple inputs at once):
    input  have ndim=4, shape=(None, 160, 160, 3) where dim=(160, 160, 3) is face matrix
    output have ndim=2, shape=(None, 512) where dim=(512,) is face matrix

    tflite   model (one input):
    input  have ndim=4, shape=(1, 160, 160, 3) where dim=(1, 160, 160, 3) is face matrix
    output have ndim=2, shape=(512,) where dim=(512,) is feature array

    tflite   model (multiple inputs at once):
    input  have ndim=5, shape=(None, 1, 160, 160, 3) where dim=(1, 160, 160, 3) is face matrix
    output have ndim=3, shape=(None, 1, 512) where dim=(1, 512) is feature array
    */

    return _interpreter.then<List<double>>(
      (interpreter) {
        final standadizedImage = _standardizeImage(image);
        final List<double> result =
            List<double>.filled(_modelOutputLength, 0.0);
        final output = {0: result};

        interpreter.run([standadizedImage], output);

        return result;
      },
    );
  }

  ///
  @override
  double facesDistance(List<double> face1, List<double> face2) {
    return _euclideanDistance(face1, face2);
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

  ///
  double _euclideanDistance<T extends num>(List<T> list1, List<T> list2) {
    if (list1.length != list2.length) {
      throw ArgumentError('expected both lists to have the same length');
    }

    double res = 0.0;
    for (var i = 0; i < list1.length; i++) {
      res += pow(list2[i] - list1[i], 2);
    }
    return sqrt(res);
  }
}
