import 'package:facial_recognition/utils/algorithms.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
    test('convertDoubleList', () {
    final List<List<double>> originalList = [
      [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 0.0],
      [1.0, 1e3, 1e5, 1e7, 1e9],
      [1.0, 1e-3, 1e-5, 1e-7, 1e-9],
      [1.111111111, 2.222222222, 3.333333333, 4.444444444, 5.555555555, 6.666666666, 7.777777777, 8.888888888, 9.999999999],
    ];
    final a = originalList.map(listDoubleToBytes);
    final b = a.map(listBytesToDouble).toList();

    for (int i=0; i<b.length; i++) {
      expect(b[i], equals(originalList[i]));
    }
  });
}