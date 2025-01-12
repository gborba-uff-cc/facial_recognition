import 'dart:math';

double euclideanDistance<T extends List<num>>(T list1, T list2) {
  if (list1.length != list2.length) {
    throw ArgumentError('expected both lists to have the same length');
  }

  double res = 0.0;
  for (var i = 0; i < list1.length; i++) {
    res += pow(list2[i] - list1[i], 2);
  }
  return sqrt(res);
}
