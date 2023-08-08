import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';

import '../interfaces.dart';

class ImageHandler
    implements IImageHandler<CameraImage, CameraDescription, Image, Uint8List> {
  ImageHandler();

  @override
  Image fromCameraImage(
    final CameraImage image,
    final CameraDescription? description,
  ) {
    final rgbBuffer = _yCbCr420ToRgbBuffer(
      width: image.width,
      height: image.height,
      planes: image.planes,
    );
    final newImage = _toLogicalImage(
      width: image.width,
      height: image.height,
      rgbBytes: rgbBuffer,
    );
    return newImage;
  }

  ByteBuffer _yCbCr420ToRgbBuffer({
    required final int width,
    required final int height,
    required final List<Plane> planes,
  }) {
    final yBytes = planes[0].bytes; // Y
    final cbBytes = planes[1].bytes; // U
    final crBytes = planes[2].bytes; // V
    final yBytesPerPixel = planes[0].bytesPerPixel ?? 1;
    final yBytesPerRow = planes[0].bytesPerRow;
    final cbCrBytesPerPixel = planes[1].bytesPerPixel ?? 1;
    final cbCrBytesPerRow = planes[1].bytesPerRow;

    final WriteBuffer rgbBytes = WriteBuffer(startCapacity: 3 * width * height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex =
            _biToUniDimCoord(x, y, 1, 1, yBytesPerPixel, yBytesPerRow);
        final int cbCrIndex =
            _biToUniDimCoord(x, y, 2, 2, cbCrBytesPerPixel, cbCrBytesPerRow);

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

  /// Find the coord for the element that hold information about the element at coord ([x], [y]).
  ///
  /// 1 element on unidimensional space represent a group of [xGroup] by [yGroup]
  /// [elementSize] and [xSize] serve to virtualy split the unidimensinal
  /// dimension.
  int _biToUniDimCoord(x, y, xGroup, yGroup, elementSize, xSize) {
    return x ~/ xGroup * elementSize + y ~/ yGroup * xSize;
  }

  Image _toLogicalImage({
    required final int width,
    required final int height,
    required final ByteBuffer rgbBytes,
  }) {
    final image = Image.fromBytes(
      width: width,
      height: height,
      bytes: rgbBytes,
      order: ChannelOrder.rgb,
    );
    return flipHorizontal(
      copyRotate(
        image,
        angle: 270,
      ),
    );
  }

  @override
  Image cropFromImage(
    final Image image,
    final Rect rect,
  ) {
    // REVIEW - (?) rect x axis origin is at top right (?)
    // image origin is (x,y)=(0,0) on the top left corner, x and y grow to the
    // right and bottom respectivelly.
    return copyCrop(
      image,
      x: (image.width - 1) - (rect.left + rect.width).toInt(),
      y: rect.top.toInt(),
      width: rect.width.toInt(),
      height: rect.height.toInt(),
    );
  }

  /// Resize the *image* to match [size]
  @override
  Image resizeImage(Image image, int width, int height) {
    return copyResize(image, width: width, height: height);
  }

  ///
  @override
  Uint8List toJpeg(Image image) {
    return encodeJpg(image);
  }

  @override
  List<List<List<int>>> toRgbMatrix(Image image) {
    final height = image.height;
    final width = image.width;
    final buffer = image.buffer.asUint8List();
    const nColorChannels = 3;

    // generate lines
    return List.generate(
      height,
      // generate colums
      (y) => List.generate(
        width,
        // generate list of 3 color values
        (x) => List.generate(
          nColorChannels,
          (z) => buffer[y * width * nColorChannels + x * nColorChannels + z],
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );
  }
}
