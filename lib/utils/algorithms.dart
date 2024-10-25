import 'dart:typed_data';

// ignore: slash_for_doc_comments
/**
Map 2D coordinates to 1D coordinates.

Narrows 2D coordinates inside an area with size [xGroupLength] by [yGroupLength]
as the same 1D coordinate inside a group of size [length]

for a 2D matrix with width=6, heigth=4 and with an input of xGroupLength=2,
yGroupLength=2, xLength=8, length=2 this problem instance can be seem as:
```text
       0 1 2 3 4 5
       | | | | | |
  0 - A A B B C C
  1 - A A B B C C  -->  0 1 2 3 4 5 6 7 8 9 101112131415
  2 - D D E E F F  -->  A * B * C * * * D * E * F * * *
  3 - D D E E F F
```

where:
```text
  A A
  A A
```
is [xGroupLength] by [yGroupLength] in size

```text
  A *
```
is [length] in size

```text
  A * B * C * * *
```
is [xLength] in size and dictate the 1D index for the first 2D group on the
second line of groups

result in:
```text
  {(0,0), (0,1), (1,0), (1,1)} -> 0
  {(0,4), (0,5), (1,4), (1,5)} -> 4
  {(2,0), (2,1), (3,0), (3,1)} -> 8
```
*/
int map2dTo1dCoordinate(
  final int x,
  final int y, {
  final int xGroupLength = 1,
  final int yGroupLength = 1,
  required final int xLength,
  final int length = 1,
}) {
  return x ~/ xGroupLength * length + y ~/ yGroupLength * xLength;
}

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
