// import 'dart:typed_data';

import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:flutter/material.dart';
// import 'package:camera/camera.dart' as pkg_camera;
// import 'package:facial_recognition/interfaces.dart';
// import 'package:facial_recognition/screens/common/one_shot_camera_return.dart';
// import 'package:facial_recognition/screens/common/camera_wrapper.dart';
import 'package:go_router/go_router.dart';
// import 'package:image/image.dart' as pkg_image;
import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;

/* class OneShotCamera extends StatelessWidget {
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
        imageCaptureHandler: (controller, cameraImage) {
          final router = GoRouter.of(context);
          if (!router.canPop()) {
            return;
          } else {
            final image = imageHandler.fromCameraImage(
              cameraImage,
              controller.description,
            );
            final jpg = imageHandler.toJpg(image);
            router.pop(
              OneShotCameraReturn(
                cameraImage: cameraImage,
                cameraController: controller,
                jpg: jpg,
              ),
            );
          }
        },
      ),
    );
  }
} */

class OneShotCameraForCamerawesome extends StatefulWidget {
  const OneShotCameraForCamerawesome({super.key});

  @override
  State<OneShotCameraForCamerawesome> createState() => _OneShotCameraForCamerawesomeState();
}

class _OneShotCameraForCamerawesomeState extends State<OneShotCameraForCamerawesome> {
  bool _shouldCaptureImage = false;

  @override
  Widget build(BuildContext context) {
      return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: pkg_awesome.CameraAwesomeBuilder.previewOnly(
          previewAlignment: Alignment.topCenter,
          previewFit: pkg_awesome.CameraPreviewFit.contain,
          sensorConfig: pkg_awesome.SensorConfig.single(
            sensor: pkg_awesome.Sensor.position(pkg_awesome.SensorPosition.front),
            aspectRatio: pkg_awesome.CameraAspectRatios.ratio_1_1,
          ),
          onImageForAnalysis: _handleAnalysisImage,
          // image analysis default use nv21 for android and bgra for ios
          // (width configuration not working for some reason)
          imageAnalysisConfig: pkg_awesome.AnalysisConfig(maxFramesPerSecond: 1),
          builder: (state, preview) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppDefaultCameraEmptySpaceIcon(),
                    AppDefaultCameraShutter(
                      onTap: () => _shouldCaptureImage = true,
                    ),
                    AppDefaultCameraSwitcher(
                      onTap: state.switchCameraSensor,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleAnalysisImage(pkg_awesome.AnalysisImage analysisImage) {
    if (_shouldCaptureImage) {
      _shouldCaptureImage = false;

      final router = GoRouter.of(context);
      if (router.canPop()) {
        router.pop(analysisImage);
      }
    }
    return Future<void>.value();
  }
}
