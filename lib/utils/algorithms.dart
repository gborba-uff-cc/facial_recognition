import 'dart:typed_data';

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

Uint8List listDoubleToBytes(List<double> list) {
  const bytesSize = 8;
  final buffer = ByteData(bytesSize * list.length);
  for (int i = 0; i < list.length; i++) {
    buffer.setFloat64(i * bytesSize, list[i], Endian.big);
  }
  final bufferBytes = buffer.buffer.asUint8List();
  return bufferBytes;
}

List<double> listBytesToDouble(Uint8List list) {
  const sizeBytes = 8;
  final buffer = List.filled(list.length ~/ sizeBytes, 0.0);
  final byteData = list.buffer.asByteData();
  for (int i = 0; i < buffer.length; i++) {
    final value = byteData.getFloat64(sizeBytes * i, Endian.big);
    buffer[i] = value;
  }
  return buffer;
}

void main(List<String> args) {
  final i1 = [[],1,2,3];
  final i2 = [0,1,2,3];

  areIterablesEquivalents(i1, i2);
}
