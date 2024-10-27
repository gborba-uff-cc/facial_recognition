import 'dart:ui';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/algorithms.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as pkg_image;

class CameraImageConverter implements
    ICameraImageConverter<PackageCameraMethodsInput, pkg_image.Image> {
  /// return a manipulable image from the camera image
  @override
  pkg_image.Image fromCameraImage(
    final PackageCameraMethodsInput input,
  ) {
    final image = input.image;
    switch (image.format.group) {
      case pkg_camera.ImageFormatGroup.yuv420:
        final rgba = rgbaFromPlanes(
            width: image.width,
            height: image.height,
            format: PlanesFormatsToRgbaPacked.yuv420,
            planes: image.planes
                .map((plane) => (
                      bytes: plane.bytes,
                      bytesPerPixel: plane.bytesPerPixel ?? 1,
                      bytesPerRow: plane.bytesPerRow
                    ))
                .toList());
        final aux = pkg_image.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: ByteData.sublistView(rgba).buffer,
          numChannels: 4,
          order: pkg_image.ChannelOrder.rgba,
        );
        return aux;
      case pkg_camera.ImageFormatGroup.nv21:
        final rgba = rgbaFromPlanes(
            width: image.width,
            height: image.height,
            format: PlanesFormatsToRgbaPacked.nv21,
            planes: image.planes
                .map((plane) => (
                      bytes: plane.bytes,
                      bytesPerPixel: plane.bytesPerPixel ?? 1,
                      bytesPerRow: plane.bytesPerRow
                    ))
                .toList());
        final aux = pkg_image.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: ByteData.sublistView(rgba).buffer,
          numChannels: 4,
          order: pkg_image.ChannelOrder.rgba,
        );
        return aux;
      case pkg_camera.ImageFormatGroup.bgra8888:
        return pkg_image.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes.single.bytes.buffer,
          numChannels: 4,
          order: pkg_image.ChannelOrder.bgra,
        );
      case pkg_camera.ImageFormatGroup.jpeg:
        final newImage = pkg_image.decodeJpg(image.planes.single.bytes);
        if (newImage == null) {
          return pkg_image.Image(width: 64, height: 64);
        }
        return newImage;
      default:
        // defaults to a black image
        return pkg_image.Image(width: 64, height: 64);
    }
  }
}

class CameraImageConverterForCamerawesome implements
    ICameraImageConverter<pkg_awesome.AnalysisImage, pkg_image.Image> {
  @override
  pkg_image.Image fromCameraImage(pkg_awesome.AnalysisImage input) {
    final image = input.when(
      yuv420: (image) {
        final planesInfos = [
          (
            bytes: image.planes[0].bytes,
            bytesPerPixel: image.planes[0].bytesPerPixel ?? 1,
            // NOTE - here is correct
            bytesPerRow: image.planes[0].bytesPerRow
          ),
          (
            bytes: image.planes[1].bytes,
            bytesPerPixel: image.planes[1].bytesPerPixel ?? 1,
            // NOTE - must divide by two because nv21 is a 4:2:0 subsamplig
            // (implying in half width resolution) and received information do
            // not account for that
            bytesPerRow: image.planes[1].bytesPerRow ~/ 2
          ),
          (
            bytes: image.planes[2].bytes,
            bytesPerPixel: image.planes[2].bytesPerPixel ?? 1,
            // NOTE - must divide by two because nv21 is a 4:2:0 subsamplig
            // (implying in half width resolution) and received information do
            // not account for that
            bytesPerRow: image.planes[2].bytesPerRow ~/ 2
          ),
        ];
        final rgba = rgbaFromPlanes(
          width: image.width,
          height: image.height,
          format: PlanesFormatsToRgbaPacked.yuv420,
          planes: planesInfos,
        );
        final aux = pkg_image.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: ByteData.sublistView(rgba).buffer,
          numChannels: 4,
          order: pkg_image.ChannelOrder.rgba,
        );
        return aux;
      },
      nv21: (image) {
        final yPlaneSize = image.height * image.planes.first.bytesPerRow;
        final yPlane = Uint8List.sublistView(
            image.bytes, 0, yPlaneSize);
        final vuPlane = Uint8List.sublistView(
            image.bytes, yPlaneSize, image.bytes.length);
        final planesInfos = [
          (
            bytes: yPlane,
            bytesPerPixel: image.planes[0].bytesPerPixel ?? 1,
            // NOTE - here is correct
            bytesPerRow: image.planes[0].bytesPerRow
          ),
          (
            bytes: vuPlane,
            bytesPerPixel: image.planes[1].bytesPerPixel ?? 1,
            // NOTE - must divide by two because nv21 is a 4:2:0 subsamplig
            // (implying in half width resolution) and received information do
            // not account for that
            bytesPerRow: image.planes[1].bytesPerRow ~/ 2
          )
        ];
        final rgba = rgbaFromPlanes(
          width: image.width,
          height: image.height,
          format: PlanesFormatsToRgbaPacked.nv21,
          planes: planesInfos,
        );
        final aux = pkg_image.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: ByteData.sublistView(rgba).buffer,
          numChannels: 4,
          order: pkg_image.ChannelOrder.rgba,
        );
        return aux;
      },
      bgra8888: (image) {
        return pkg_image.Image.fromBytes(
          width: image.width,
          height: image.height,
          bytes: image.planes.single.bytes.buffer,
          numChannels: 4,
          order: pkg_image.ChannelOrder.bgra,
        );
      },
      jpeg: (image) {
        final newImage = pkg_image.decodeJpg(image.bytes);
        if (newImage == null) {
          return pkg_image.Image(width: 64, height: 64);
        }
        return newImage;
      },
    );

    if (image == null) {
      return pkg_image.Image(width: 64, height: 64);
    }
    else {
      return image;
    }
  }
}

class ImageHanler implements
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

class CameraImageHandler implements
    ICameraImageHandler<
        PackageCameraMethodsInput,
        pkg_image.Image,
        JpegPictureBytes>
{
  ICameraImageConverter<PackageCameraMethodsInput, pkg_image.Image> cameraImageConverter = CameraImageConverter();
  IImageHandler<pkg_image.Image, JpegPictureBytes> imageHandler = ImageHanler();
  CameraImageHandler();

  @override
  List<pkg_image.Image> cropFromImage(pkg_image.Image image, List<Rect> rect) {
    return imageHandler.cropFromImage(image, rect);
  }

  @override
  pkg_image.Image flipHorizontal(pkg_image.Image image) {
    return imageHandler.flipHorizontal(image);
  }

  @override
  pkg_image.Image fromCameraImage(PackageCameraMethodsInput input) {
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

class CameraImageHandlerForCamerawesome implements
    ICameraImageHandler<
        pkg_awesome.AnalysisImage,
        pkg_image.Image,
        JpegPictureBytes>
{
  final ICameraImageConverter<pkg_awesome.AnalysisImage, pkg_image.Image>
      cameraImageConverter = CameraImageConverterForCamerawesome();
  final IImageHandler<pkg_image.Image, JpegPictureBytes> imageHandler =
      ImageHanler();

  @override
  List<pkg_image.Image> cropFromImage(pkg_image.Image image, List<Rect> rect) {
    return imageHandler.cropFromImage(image, rect);
  }

  @override
  pkg_image.Image flipHorizontal(pkg_image.Image image) {
    return imageHandler.flipHorizontal(image);
  }

  @override
  pkg_image.Image fromCameraImage(pkg_awesome.AnalysisImage input) {
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