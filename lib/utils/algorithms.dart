bool areIterablesEquivalents<T>(
  Iterable<T> iterable1,
  Iterable<T> iterable2,
) {
  if (iterable1.length != iterable2.length) {
    return false;
  } else if (iterable1.isEmpty) {
    return true;
  } else {
    final iterator1 = iterable1.iterator;
    final iterator2 = iterable2.iterator;
    bool haveElement = false;
    haveElement = iterator1.moveNext();
    haveElement &= iterator2.moveNext();
    while (haveElement) {
      int numIterables = 0;
      numIterables += iterator1.current is Iterable ? 1 : 0;
      numIterables += iterator2.current is Iterable ? 1 : 0;

      bool bothEquivalents = false;
      if (numIterables == 2) {
        bothEquivalents = areIterablesEquivalents(
          iterator1.current as Iterable,
          iterator2.current as Iterable,
        );
      }

      if (
        (numIterables == 0 && iterator1.current != iterator2.current) ||
        (numIterables == 1) ||
        (numIterables == 2 && !bothEquivalents)
      ) {
        return false;
      }

      haveElement = iterator1.moveNext();
      haveElement &= iterator2.moveNext();
    }
    return true;
  }
}

void main(List<String> args) {
  final i1 = [[],1,2,3];
  final i2 = [0,1,2,3];

  areIterablesEquivalents(i1, i2);
}
