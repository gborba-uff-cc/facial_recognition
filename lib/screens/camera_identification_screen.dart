import 'package:camera/camera.dart' as pkg_camera;
import 'package:facial_recognition/screens/common/camera_wrapper.dart';
import 'package:facial_recognition/use_case/camera_identification.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraIdentificationScreen extends StatefulWidget {
  const CameraIdentificationScreen({
    super.key,
    required this.cameras,
    required this.useCase,
  });

  final CameraIdentification useCase;
  final List<pkg_camera.CameraDescription> cameras;

  @override
  State<CameraIdentificationScreen> createState() => _CameraIdentificationScreenState();
}

class _CameraIdentificationScreenState extends State<CameraIdentificationScreen> with WidgetsBindingObserver {
  final List<Uint8List> facesPhotos = [];
  bool _isAutoMode = false;
  // final ImageHandler _imageHandler = ImageHandler();
  // late final Timer _autoclearFacePhotos;

  @override
  void initState() {
    super.initState();
    facesPhotos.clear();
/*     widget.useCase.onDetectedFaces = (jpegImages) async {
      if (mounted) {
        setState(() => facesPhotos.addAll(jpegImages));
      }
    }; */
/*
    // NOTE - remove one image at time from view
    _autoclearFacePhotos = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (facesPhotos.isNotEmpty) {
        if (mounted) {
          setState(() {
            facesPhotos.removeAt(0);
          });
        }
      }
    });
*/
  }

  @override
  void dispose() {
    // _autoclearFacePhotos.cancel();
    facesPhotos.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraWidget = CameraWrapper(
      camerasAvailable: widget.cameras,
      imageCaptureHandler: _isAutoMode
          ? null
          : (cameraController, cameraImage) => widget.useCase.onNewCameraInput(
              CameraIdentificationInputType(
                  image: cameraImage, controller: cameraController)),
      imageStreamHandler: !_isAutoMode
          ? null
          : (cameraController, cameraImage) => widget.useCase.onNewCameraInput(
              CameraIdentificationInputType(
                  image: cameraImage, controller: cameraController)),
    );
    return Scaffold(
      appBar: AppBar(),
      body: SizedBox.expand(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: facesPhotos.length,
                itemBuilder: (context, index) => Image.memory(facesPhotos[index]),
                scrollDirection: Axis.horizontal,
              ),
            ),
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
          ],
        ),
      ),
    );
  }
}
