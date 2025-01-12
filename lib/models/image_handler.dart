import 'dart:ui';

import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as pkg_image;

class CameraImageConverterForCamerawesome implements
    ICameraImageConverter<pkg_awesome.AnalysisImage, pkg_image.Image> {
  @override
  Future<pkg_image.Image> fromCameraImage(pkg_awesome.AnalysisImage input) async {
    final blackImage = pkg_image.Image(width: 64, height: 64);
    final Future<pkg_awesome.JpegImage>? jpgImage = input.when<Future<pkg_awesome.JpegImage>>(
      yuv420: (image) async {
        final jpg = image.toJpeg();
        return jpg;
      },
      nv21: (image) {
        final jpg = image.toJpeg();
        return jpg;
      },
      bgra8888: (image) {
        final jpg = image.toJpeg();
        return jpg;
      },
      jpeg: (image) async {
        return Future.value(image);
      },
    );

    if (jpgImage == null) {
      return blackImage;
    }
    else {
      final rotateAngle = switch (input.rotation) {
        pkg_awesome.InputAnalysisImageRotation.rotation0deg => 0,
        pkg_awesome.InputAnalysisImageRotation.rotation90deg => 90,
        pkg_awesome.InputAnalysisImageRotation.rotation180deg => 180,
        pkg_awesome.InputAnalysisImageRotation.rotation270deg => 270,
      };
      // REVIEW - iOS - how should be the handlig for iOS?
      final command = pkg_image.Command()
        ..decodeJpg((await jpgImage).bytes)
        ..copyRotate(angle: rotateAngle)
        ..flip(direction: pkg_image.FlipDirection.horizontal);
      await command.execute();
      final outputImage = command.outputImage;
      if (outputImage == null) {
        return blackImage;
      }
      else {
        return outputImage;
      }
    }
  }
}

class ImageHandler implements
    IImageHandler<pkg_image.Image, JpegPictureBytes> {
  /// Return new images from subareas of [image].
  @override
  List<pkg_image.Image> cropFromImage(
    final pkg_image.Image image,
    final List<Rect> rect,
  ) {
    // image origin is (x,y)=(0,0) on the top left corner, x and y grow to the
    // right and bottom respectivelly.
    return rect
        .map((r) => pkg_image.copyCrop(
              image,
              x: (image.width - 1) - (r.right).toInt(),
              y: r.top.toInt(),
              width: r.width.toInt(),
              height: r.height.toInt(),
            ))
        .toList(growable: false);
  }

  /// Resize the *image* to match [size]
  @override
  pkg_image.Image resizeImage(pkg_image.Image image, int width, int height) {
    return pkg_image.copyResize(image, width: width, height: height);
  }

  @override
  pkg_image.Image flipHorizontal(pkg_image.Image image) {
    return pkg_image.flipHorizontal(image);
  }

  @override
  pkg_image.Image rotateImage(
    pkg_image.Image image,
    num angle,
  ) {
    return pkg_image.copyRotate(
      image,
      angle: angle,
      interpolation: pkg_image.Interpolation.nearest,
    );
  }

  ///
  @override
  Uint8List toJpg(pkg_image.Image image) {
    return pkg_image.encodeJpg(image);
  }

  @override
  pkg_image.Image? fromJpg(Uint8List jpgBytes) {
    return pkg_image.decodeJpg(jpgBytes);
  }

  @override
  List<List<List<int>>> toRgbMatrix(pkg_image.Image image) {
    final height = image.height;
    final width = image.width;
    final buffer = image.buffer.asUint8List();
    const nColorChannels = 3;

    // generate lines
    return List.generate(height,
      // generate colums
      (y) => List.generate(width,
        // generate lists of 3 color values
        (x) => List.generate(nColorChannels,
          (z) => buffer[y * width * nColorChannels + x * nColorChannels + z],
          growable: false,
        ),
        growable: false,
      ),
      growable: false,
    );
  }
}

class CameraImageHandlerForCamerawesome implements
    ICameraImageHandler<
        pkg_awesome.AnalysisImage,
        pkg_image.Image,
        JpegPictureBytes>
{
  final ICameraImageConverter<pkg_awesome.AnalysisImage, pkg_image.Image>
      cameraImageConverter = CameraImageConverterForCamerawesome();
  final IImageHandler<pkg_image.Image, JpegPictureBytes> imageHandler =
      ImageHandler();

  @override
  List<pkg_image.Image> cropFromImage(pkg_image.Image image, List<Rect> rect) {
    return imageHandler.cropFromImage(image, rect);
  }

  @override
  pkg_image.Image flipHorizontal(pkg_image.Image image) {
    return imageHandler.flipHorizontal(image);
  }

  @override
  Future<pkg_image.Image> fromCameraImage(pkg_awesome.AnalysisImage input) {
    return cameraImageConverter.fromCameraImage(input);
  }

  @override
  pkg_image.Image? fromJpg(JpegPictureBytes jpgBytes) {
    return imageHandler.fromJpg(jpgBytes);
  }

  @override
  pkg_image.Image resizeImage(pkg_image.Image image, int width, int height) {
    return imageHandler.resizeImage(image, width, height);
  }

  @override
  pkg_image.Image rotateImage(pkg_image.Image image, num angle) {
    return imageHandler.rotateImage(image, angle);
  }

  @override
  JpegPictureBytes toJpg(pkg_image.Image image) {
    return imageHandler.toJpg(image);
  }

  @override
  List<List<List<int>>> toRgbMatrix(pkg_image.Image image) {
    return imageHandler.toRgbMatrix(image);
  }
}