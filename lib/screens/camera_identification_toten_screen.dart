import 'dart:async';
import 'dart:typed_data';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/screens/common/grid_selector.dart';
import 'package:facial_recognition/screens/grid_student_selector_screen.dart';
import 'package:facial_recognition/use_case/mark_attendance.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:rxdart/rxdart.dart';

// made out of a camerawesome example (camerawesome-2.1.0/example/lib/ai_analysis_faces.dart)

enum _IdentificationMode {
  automatic,
  manual,
}

typedef _TotemScreenPayload = ({
  Uint8List face,
  Student? student,
  DateTime arriveUtcDateTime,
});

class CameraIdentificationTotemScreen extends StatefulWidget {
  factory CameraIdentificationTotemScreen({
    final Key? key,
    required final ICameraAttendance<AnalysisImage, JpegPictureBytes> cameraAttendanceUseCase,
    required final MarkAttendance markAttendanceUseCase,
  }) {
    return CameraIdentificationTotemScreen._private(
      cameraAttendanceUseCase,
      markAttendanceUseCase,
      markAttendanceUseCase.getStudentFaceImage(),
    );
  }

  const CameraIdentificationTotemScreen._private(
    this.cameraAttendanceUseCase,
    this.markAttendanceUseCase,
    this._facePicturesByStudent,
  );

  final ICameraAttendance<AnalysisImage, JpegPictureBytes> cameraAttendanceUseCase;
  final MarkAttendance markAttendanceUseCase;
  final Map<Student, FacePicture?> _facePicturesByStudent;

  @override
  State<CameraIdentificationTotemScreen> createState() => _CameraIdentificationTotemScreenState();
}

class _CameraIdentificationTotemScreenState extends State<CameraIdentificationTotemScreen> {
  // final _faceDetectionController = BehaviorSubject<FaceDetectionModel>();
  final _detectedFacesController = StreamController<_TotemScreenPayload>.broadcast();
  // final _canHandleImage = StreamController<bool>();
  // final StreamSubscription _canHandleImageStream =
  // final List _detectedFaces = [];
  _IdentificationMode _identificationMode = _IdentificationMode.automatic;
  bool _shouldCaptureImage = false;
  bool _isHandlingImage = false;

  void _clearIsHandlingImage() {
    _isHandlingImage = false;
  }

  void _handleRecognitionResult({
    final Iterable<EmbeddingRecognitionResult> notRecognized = const [],
    final Iterable<EmbeddingRecognitionResult> recognized = const [],
  }) {
    if (recognized.isEmpty && notRecognized.isEmpty) {
      // clearing _isHandlingImage (no face detected)
      _clearIsHandlingImage();
      return;
    }
    else if (recognized.isNotEmpty) {
      _detectedFacesController.add(
        (
          face: recognized.first.inputFace,
          student: recognized.first.nearestStudent,
          arriveUtcDateTime: recognized.first.utcDateTime,
        ),
      );
    }
    else {
      _detectedFacesController.add(
        (
          face: notRecognized.first.inputFace,
          student: null,
          arriveUtcDateTime: notRecognized.first.utcDateTime,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    widget.cameraAttendanceUseCase.onRecognitionResult = _handleRecognitionResult;
  }

  @override
  void dispose() {
    // _detectedFaces.clear();
    // _faceDetectionController.close();
    _detectedFacesController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0),
        child: CameraAwesomeBuilder.previewOnly(
          previewAlignment: Alignment.topCenter,
          previewFit: CameraPreviewFit.contain,
          sensorConfig: SensorConfig.single(
            sensor: Sensor.position(SensorPosition.front),
            aspectRatio: CameraAspectRatios.ratio_1_1,
          ),
          onImageForAnalysis: _handleAnalysisImage,
          // image analysis default use nv21 for android and bgra for ios
          // (width configuration not working for some reason)
          imageAnalysisConfig: AnalysisConfig(maxFramesPerSecond: 1),
          builder: (state, preview) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: _ConfirmationCameraPreviewDecorator(
                detectedFacesStream: _detectedFacesController.stream,
                onAccept: (accepted) {
                  _onTotemRecognitionAccepted(accepted);
                },
                onRevise: (beingRevised) async {
                  Student? newSelected;
                  final items = widget._facePicturesByStudent.entries
                      .map((e) => (student: e.key, jpg: e.value?.faceJpeg))
                      .toList()
                    ..sort((a, b) => a.student.individual.displayFullName
                        .compareTo(b.student.individual.displayFullName));
                  int initialySelectedIndex = items.indexWhere((element) =>
                      element.student.individual.displayFullName ==
                      beingRevised.student?.individual.displayFullName);
                  final initialySelected = initialySelectedIndex < 0
                      ? null
                      : items[initialySelectedIndex];
                  await showDialog(
                    context: context,
                    builder: (context) => Dialog.fullscreen(
                      child: StudentGridSelector(
                        items: items,
                        initialySelected: initialySelected,
                        onSelection: (selected) {
                          newSelected = selected?.student;
                          final router = GoRouter.of(context);
                          if (router.canPop()) {
                            router.pop();
                          }
                        },
                      ),
                    ),
                  );
                  if (newSelected == null) {
                    return;
                  }
                  else {
                    widget.markAttendanceUseCase.writeStudentAttendance([
                      (
                        student: newSelected!,
                        arriveUtcDateTime: beingRevised.arriveUtcDateTime
                      ),
                    ]);
                  }
                },
                // onRevise: () async {
                //   final items = widget._facePicturesByStudent.entries.toList();
                //   final newSelection = await GoRouter.of(context)
                //       .push<MapEntry<Student, FacePicture?>>(
                //     '/mark_attendance_edit_student',
                //     extra: GridStudentSelectorScreenArguments<
                //         MapEntry<Student, FacePicture?>>(
                //       items: items,
                //       initialySelected: null,
                //     ),
                //   );
                //   final student = newSelection?.key;
                //   if (student == null) {
                //     return;
                //   }
                //   else {
                //     widget.markAttendanceUseCase
                //         .writeStudentAttendance([student]);
                //   }
                // },
                onDiscard: () {},
                // clearing _isHandlingImage (after interaction)
                onClose: _clearIsHandlingImage,
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleAnalysisImage(AnalysisImage image) {
    // SECTION - always start with this
    if (_isHandlingImage) {
      return Future.value();
    }
    if (_identificationMode == _IdentificationMode.manual && !_shouldCaptureImage) {
      return Future.value();
    }
    projectLogger.fine('handling analysis image');
    // NOTE - must clear _isHandlingImage when:
    // no face detected or,
    // after interaction
    _isHandlingImage = true;
    _shouldCaptureImage = false;
    // !SECTION

    // run asyncronously
    return Future(() => widget.cameraAttendanceUseCase.onNewCameraInput(image));
  }

  void _onTotemRecognitionAccepted(_TotemScreenPayload item) {
    if (item.student == null) {
      return;
    }
    widget.markAttendanceUseCase.writeStudentAttendance([
      (student: item.student!, arriveUtcDateTime: item.arriveUtcDateTime),
    ]);
  }
}

class _ConfirmationCameraPreviewDecorator extends StatefulWidget {
  final Stream<_TotemScreenPayload> detectedFacesStream;
  final void Function()? onClose;
  final void Function(_TotemScreenPayload)? onAccept;
  final FutureOr<void> Function(_TotemScreenPayload)? onRevise;
  final void Function()? onDiscard;

  const _ConfirmationCameraPreviewDecorator({
    required this.detectedFacesStream,
    this.onClose,
    this.onAccept,
    this.onRevise,
    this.onDiscard,
  });

  @override
  State<_ConfirmationCameraPreviewDecorator> createState() => _ConfirmationCameraPreviewDecoratorState();
}

class _ConfirmationCameraPreviewDecoratorState extends State<_ConfirmationCameraPreviewDecorator> {
  _TotemScreenPayload? _latestData;
  _TotemScreenPayload? _latestBuiltData;
  StreamSubscription? _streamSubscription;

  @override
  void didUpdateWidget(covariant _ConfirmationCameraPreviewDecorator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _streamSubscription?.cancel();
    _startReceiveingFromStream();
  }

  @override
  void initState() {
    super.initState();
    _startReceiveingFromStream();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  _startReceiveingFromStream() {
    _streamSubscription = widget.detectedFacesStream.listen(
      (event) {
        if (mounted) {
          setState(() {_latestData = event;});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _latestData;
    if (identical(_latestBuiltData, data) || data == null) {
      return SizedBox.shrink();
    }
    _latestBuiltData = data;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 300, maxWidth: 600),
        child: AppDefaultTotenIdentificationCard(
          faceJpg: data.face,
          name: data.student?.individual.displayFullName ?? '(não reconhecido)',
          registration: data.student?.registration ?? '',
          onAccept: () {
            if (widget.onAccept != null) {
              widget.onAccept!(data);
            }
            if (widget.onClose != null) {
              widget.onClose!();
            }
            if (mounted) {
              setState(() {});
            }
          },
          onRevise: () async {
            if (widget.onRevise != null) {
              await widget.onRevise!(data);
            }
            if (widget.onClose != null) {
              widget.onClose!();
            }
            if (mounted) {
              setState(() {});
            }
          },
          onDiscard: () {
            if (widget.onDiscard != null) {
              widget.onDiscard!();
            }
            if (widget.onClose != null) {
              widget.onClose!();
            }
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }


  /* @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.detectedFacesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          if (widget.onClose != null) {
            widget.onClose!();
          }
          return SizedBox.shrink();
        }
        else {
          final data = snapshot.requireData;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal:  24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: 300,maxWidth: 600),
              child: AppDefaultTotenIdentificationCard(
                faceJpg: data.face,
                name: data.student?.individual.displayFullName ?? '(não reconhecido)',
                registration: data.student?.registration ?? '',
                onAccept: () {
                  if (widget.onAccept != null) {
                    widget.onAccept!(data.student);
                  }
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                },
                onRevise: () async  {
                  if (widget.onRevise != null) {
                    await widget.onRevise!();
                  }
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                },
                onDiscard: () {
                  if (widget.onDiscard != null) {
                    widget.onDiscard!();
                  }
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                },
              ),
            ),
          );
        }
      },
    );
  } */
}
