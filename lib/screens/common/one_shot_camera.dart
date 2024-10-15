import 'dart:typed_data';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/screens/common/one_shot_camera_return.dart';
import 'package:facial_recognition/screens/common/camera_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart' as pkg_camera;
import 'package:image/image.dart' as pkg_image;
import 'package:go_router/go_router.dart';

class OneShotCamera extends StatelessWidget {
  const OneShotCamera({
    super.key,
    required this.camerasAvailable,
    required this.imageHandler,
  });

  final IImageHandler<pkg_camera.CameraImage, pkg_camera.CameraDescription,
      pkg_image.Image, Uint8List> imageHandler;
  final List<pkg_camera.CameraDescription> camerasAvailable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CameraWrapper(
        camerasAvailable: camerasAvailable,
        imageCaptureHandler: (description, cameraImage) {
          final router = GoRouter.of(context);
          if (!router.canPop()) {
            return;
          } else {
            final image = imageHandler.fromCameraImage(
              cameraImage,
              description,
            );
            final jpg = imageHandler.toJpg(image);
            router.pop(
              OneShotCameraReturn(
                cameraImage: cameraImage,
                cameraDescription: description,
                jpg: jpg,
              ),
            );
          }
        },
      ),
    );
  }
}