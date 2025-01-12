import 'dart:typed_data';

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
