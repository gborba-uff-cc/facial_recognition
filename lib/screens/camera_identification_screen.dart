import 'package:camera/camera.dart';
import 'package:facial_recognition/screens/widgets/camera_wrapper.dart';
import 'package:facial_recognition/use_case/camera_identification.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraIdentificationScreen extends StatefulWidget {
  const CameraIdentificationScreen({
    super.key,
    required this.cameras,
    required this.useCase,
  });

  final CameraIdentification useCase;
  final List<CameraDescription> cameras;

  @override
  State<CameraIdentificationScreen> createState() => _CameraIdentificationScreenState();
}

class _CameraIdentificationScreenState extends State<CameraIdentificationScreen> with WidgetsBindingObserver {
  final List<Uint8List> facesPhotos = [];
  bool _isAutoMode = false;

  @override
  void initState() {
    super.initState();
    widget.useCase.showFaceImages =  (jpegImages) {
      if (mounted) {
        setState(() {
          facesPhotos.addAll(jpegImages);
        });
      }
    };
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraWidget = CameraWrapper(
      camerasAvailable: widget.cameras,
      imageCaptureHandler: _isAutoMode
          ? null
          : (cameraDescription, cameraImage) => widget.useCase.onNewCameraImage(
              cameraImage, cameraDescription.sensorOrientation),
      imageStreamHandler: !_isAutoMode
          ? null
          : (cameraDescription, cameraImage) => widget.useCase.onNewCameraImage(
              cameraImage, cameraDescription.sensorOrientation),
    );
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox.expand(
        child: Column(
          children: [
            Stack(
              children: [
                cameraWidget,
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.all(cameraWidget.basePadding),
                      child: SizedBox(
                        width: cameraWidget.baseIconSize,
                        height: cameraWidget.baseIconSize,
                        child: Center(
                          child: _isAutoMode
                              ? FilledButton(
                                  onPressed: () =>
                                      setState(() => _isAutoMode = !_isAutoMode),
                                  child: const Text('Auto'),
                                )
                              : FilledButton.tonal(
                                  onPressed: () =>
                                      setState(() => _isAutoMode = !_isAutoMode),
                                  child: const Text('Auto'),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ] ,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: facesPhotos.length,
                itemBuilder: (context, index) => Image.memory(facesPhotos[index]),
                scrollDirection: Axis.horizontal,
              ),
            )
          ],
        ),
      ),
    );
  }
}
