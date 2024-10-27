// try differents SVM, KNN, multilayer perceptron, xgboost, adaboost
import 'dart:math';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';

typedef TConfidence = double;
typedef TDistance = double;

class FaceRecognitionResult<TLabel> implements IFaceRecognitionResult<TLabel> {
  FaceRecognitionResult({
    required this.label,
    required this.recognitionValue,
    required this.status,
  });

  @override
  final TLabel label;

  @override
  final double recognitionValue;

  @override
  final FaceRecognitionStatus status;
}

class DistanceClassifier<TElement extends List<num>, TLabel>
    implements IFaceRecognizer<TLabel, TElement> {
  DistanceClassifier({
    required this.distanceFunction,
    recognitionThreshold = 20.0,
  }) : _recognitionThreshold = recognitionThreshold;

  final DistanceFunction<TElement> distanceFunction;
  final double _recognitionThreshold;

  @override
  double get recognitionThreshold => _recognitionThreshold;

  @override
  Map<TElement, IFaceRecognitionResult<TLabel>> recognize(
    final Iterable<TElement> unknown,
    final Map<TLabel, Iterable<TElement>> dataSet,
  ) {
    // generate once and update every round to avoid generating every time
    // the list of distances between an unknown and a dataSet element
    final distanceStructure = [
      for (final labelValues in dataSet.entries)
        for (final value in labelValues.value)
          _LabelValueDistance(label: labelValues.key, element: value)
    ];

    // the result mapping an unknown element to the new category and the
    // confidence value of the category
    final tmp = FaceRecognitionResult(
      label: dataSet.entries.first.key,
      recognitionValue: 0.0,
      status: FaceRecognitionStatus.notRecognized,
    );
    final result = { for (final u in unknown) u : tmp };

    if (distanceStructure.isEmpty) {
      return result;
    }

    int nRecognized = 0;
    // compute for all the inputs
    for (final anInput in unknown) {
      //measure the distances
      for (final lvd in distanceStructure) {
        lvd.distance = distanceFunction(anInput, lvd.element);
      }

      // sort the distances for the nearest
      distanceStructure.sort(
        (a, b) => a.distance.compareTo(b.distance),
      );

      // get the nearest
      final nearest = distanceStructure.first;
      final status = _recognitionStatus(nearest.distance) ? FaceRecognitionStatus.recognized : FaceRecognitionStatus.notRecognized;
      result[anInput] = FaceRecognitionResult(
        label: nearest.label,
        recognitionValue: nearest.distance,
        status: _recognitionStatus(nearest.distance) ? FaceRecognitionStatus.recognized : FaceRecognitionStatus.notRecognized,
      );
      if (status == FaceRecognitionStatus.recognized) {
        nRecognized += 1;
      }
    }
    projectLogger.info('[FaceRecognizer] total: ${unknown.length}, recognized: $nRecognized, not recognized: ${unknown.length-nRecognized}');
    return result;
  }

  bool _recognitionStatus(double distance) => distance > recognitionThreshold ? false : true;
}

class KnnClassifier<TElement extends List<num>, TLabel>
    implements IFaceRecognizer<TLabel, TElement> {
  /// [kNeighbors] is the number of neighbors being considered \
  /// [distanceFunction] is the distance metric used to determine proximity
  const KnnClassifier({
    this.kNeighbors = 5,
    required this.distanceFunction,
    recognitionThreshold = 20.0,
  }): _recognitionThreshold = recognitionThreshold,
      assert (kNeighbors > 0);

  final int kNeighbors;
  final DistanceFunction distanceFunction;
  final double _recognitionThreshold;

  @override
  double get recognitionThreshold => _recognitionThreshold;

  /// categorize the [unknown] element as one of the elements in the [dataSet]
  ///
  /// return in which category the unknown element belongs\
  /// [unknown] is an iterable of unknown elements\
  /// [dataSet] are the labeled data
  @override
  Map<TElement, IFaceRecognitionResult<TLabel>> recognize(
    final Iterable<TElement> unknown,
    final Map<TLabel, Iterable<TElement>> dataSet,
  ) {
    assert (unknown.isNotEmpty);

    // generate once and update every round to avoid generating every time
    // the list of distances between an unknown and a dataSet element
    final distanceStructure = [
      for (final labelValues in dataSet.entries)
        for (final value in labelValues.value)
          _LabelValueDistance(label: labelValues.key, element: value)
    ];

    // the result mapping an unknown element to the new category and the
    // confidence value of the category
    final tmp = FaceRecognitionResult(
      label: dataSet.entries.first.key,
      recognitionValue: 0.0,
      status: FaceRecognitionStatus.notRecognized,
    );
    final result = {for (final u in unknown) u: tmp};

    if (distanceStructure.isEmpty) {
      return result;
    }

    final Map<TLabel, double> scoreStructure = {};
    // compute for all the inputs
    for (final anInput in unknown) {
      scoreStructure.clear();

      //measure the distances
      for (final lvd in distanceStructure) {
        lvd.distance = distanceFunction(anInput, lvd.element);
      }

      // sort the distances for the nearest
      distanceStructure.sort(
        (a, b) => a.distance.compareTo(b.distance),
      );

      // count occurency of the kNearests neighbors
      for (final labelValueDistance in  distanceStructure.take(kNeighbors)) {
        double score = labelValueDistance.distance < recognitionThreshold ? 1/(pow(labelValueDistance.distance, 3).toDouble()) : 0.0;
        if (score.isInfinite || score.isNaN) {
          projectLogger.severe('invalid score; setting to zero');
          score = 0.0;
        }
        scoreStructure.update(labelValueDistance.label, (oldScore) => oldScore + score, ifAbsent: () => score,);
      }
      final labelByScore = scoreStructure.entries
          .map((labelScore) => Duple(labelScore.value, labelScore.key))
          .toList(growable: false)
        ..sort((a, b) => -a.value1.compareTo(b.value1));

      // get the most occurring
      final mostOccurring = labelByScore.first;
      result[anInput] = FaceRecognitionResult(
        label: mostOccurring.value2,
        recognitionValue: mostOccurring.value1,
        status: mostOccurring.value1 > 0.0 ? FaceRecognitionStatus.recognized : FaceRecognitionStatus.notRecognized,
      );
    }
    return result;
  }
}

class _LabelValueDistance<TLabel, TElement>{
  _LabelValueDistance({
    required this.label,
    required this.element,
    this.distance = 0.0,
  });

  final TLabel label;
  final TElement element;
  double distance;
}
