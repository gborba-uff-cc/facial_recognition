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
  Uint8List jpgFaceDetected,
  Uint8List? jpgFaceRecognized,
  Student? studentRecognized,
  DateTime arriveUtcDateTime,
});

final _confirmationSnackbarDuration = Duration(milliseconds: 1500);
const String _recognitionAcceptedMessage = 'Presença registrada';
const String _recognitionDiscardedMessage = 'Reconhecimento descartado';
const String _recognitionFailedMessage = 'Algo deu errado :(';

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
  final StreamController<Widget> _feedbackWidgetsController =
      StreamController<Widget>.broadcast();
  // final _faceDetectionController = BehaviorSubject<FaceDetectionModel>();
  final _detectedFacesController = StreamController<_TotemScreenPayload>.broadcast();
  // final _canHandleImage = StreamController<bool>();
  // final StreamSubscription _canHandleImageStream =
  // final List _detectedFaces = [];
  _IdentificationMode _identificationMode = _IdentificationMode.automatic;
  bool _shouldCaptureImage = false;
  bool _isHandlingImage = false;

  // NOTE - for the research on time expent on each interaction
  Stopwatch interactionTimer = Stopwatch();

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
      final student = recognized.first.nearestStudent;
      JpegPictureBytes? studentPicture;
      if (student != null) {
        studentPicture = widget._facePicturesByStudent[student]?.faceJpeg;
      }
      _detectedFacesController.add(
        (
          jpgFaceDetected: recognized.first.inputFace,
          jpgFaceRecognized: studentPicture,
          studentRecognized: student,
          arriveUtcDateTime: recognized.first.utcDateTime,
        ),
      );
    }
    else {
      _detectedFacesController.add(
        (
          jpgFaceDetected: notRecognized.first.inputFace,
          jpgFaceRecognized: null,
          studentRecognized: null,
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
    _feedbackWidgetsController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.black,
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
                  interactionTriggerStream: _detectedFacesController.stream,
                  interactionFeedbackStream:
                      _feedbackWidgetsController.stream,
                  onAccept: _onTotemRecognitionAccepted,
                  onRevise: _onTotemRecognitionRevision,
                  onDiscard: _onTotemRecognitionDiscarded,
                  // clearing _isHandlingImage (after interaction)
                  // calls _clearIsHandlingImage,
                  onClose: _onTotemRecognitionClosed,
                ),
              );
            },
          ),
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
    return Future(() {
      _startInteractionTimer();
      widget.cameraAttendanceUseCase.onNewCameraInput(image);
    });
  }

  void _onTotemRecognitionAccepted(
    _TotemScreenPayload item,
  ) {
    Theme.of(context).textTheme.titleMedium;
    if (item.studentRecognized == null) {
      _stopLogResetInteractionTimer(_TimerLabelInteractionType.acceptNotrecognized);
      _feedbackWidgetsController.add(
        _InteractionFeedback(
          child: Center(
            child: _FeedbackText(_recognitionDiscardedMessage),
          ),
        ),
      );
      return;
    }
    else {
      _stopLogResetInteractionTimer(_TimerLabelInteractionType.acceptRecognized);
      try {
        widget.markAttendanceUseCase.writeStudentAttendance([
          (
            student: item.studentRecognized!,
            arriveUtcDateTime: item.arriveUtcDateTime,
          ),
        ]);
        _feedbackWidgetsController.add(
          _InteractionFeedback(
            child: Center(
              child: _FeedbackText(_recognitionAcceptedMessage),
            ),
          ),
        );
      }
      on Exception {
        _feedbackWidgetsController.add(
          _InteractionFeedback(
            child: Center(
              child: _FeedbackText(_recognitionFailedMessage),
            ),
          ),
        );
      }
    }
  }

  void _onTotemRecognitionRevision(
    _TotemScreenPayload beingRevised,
  ) async {
    Student? newSelected;
    final items = widget._facePicturesByStudent.entries
        .map((e) => (student: e.key, jpg: e.value?.faceJpeg))
        .toList()
      ..sort((a, b) => a.student.individual.displayFullName
          .compareTo(b.student.individual.displayFullName));
    int initialySelectedIndex = items.indexWhere((element) =>
        element.student.individual.displayFullName ==
        beingRevised.studentRecognized?.individual.displayFullName);
    final initialySelected = initialySelectedIndex < 0
        ? null
        : items[initialySelectedIndex];
    newSelected = await showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: StudentGridSelector(
          items: items,
          initialySelected: initialySelected,
          onSelection: (selected) {
            // newSelected = selected?.student;
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop(selected?.student);
            }
          },
        ),
      ),
    );
    if (newSelected == null) {
      _stopLogResetInteractionTimer(
          _TimerLabelInteractionType.modifyAndDiscard);
      _feedbackWidgetsController.add(
        _InteractionFeedback(
          child: Center(
            child: _FeedbackText(_recognitionDiscardedMessage),
          ),
        ),
      );
      return;
    }
    else {
      _stopLogResetInteractionTimer(
          _TimerLabelInteractionType.modifyAndAccept);
      try {
        widget.markAttendanceUseCase.writeStudentAttendance([
          (
            student: newSelected,
            arriveUtcDateTime: beingRevised.arriveUtcDateTime
          ),
        ]);
        _feedbackWidgetsController.add(
          _InteractionFeedback(
            child: Center(
              child: _FeedbackText(_recognitionAcceptedMessage),
            ),
          ),
        );
      }
      on Exception {
        _feedbackWidgetsController.add(
          _InteractionFeedback(
            child: Center(
              child: _FeedbackText(_recognitionFailedMessage),
            ),
          ),
        );
      }
    }
  }

  void _onTotemRecognitionDiscarded() {
    _stopLogResetInteractionTimer(_TimerLabelInteractionType.discard);
    _feedbackWidgetsController.add(
      _InteractionFeedback(
        child: Center(
          child: _FeedbackText(_recognitionDiscardedMessage),
        ),
      ),
    );
  }

  void _onTotemRecognitionClosed() {
    _clearIsHandlingImage();
  }

  void _startInteractionTimer() {
    if (!interactionTimer.isRunning) {
      interactionTimer.start();
    }
  }

  void _stopLogResetInteractionTimer(_TimerLabelInteractionType type) {
    if (interactionTimer.isRunning) {
      interactionTimer.stop();
      projectLogger
          .info('[totem interaction time ms|${type.name}] ${interactionTimer.elapsedMilliseconds}');
      interactionTimer.reset();
    }
  }
}


/// types of user intent
enum _TimerLabelInteractionType {
  acceptRecognized,
  acceptNotrecognized,
  discard,
  modifyAndAccept,
  modifyAndDiscard,
}

/// the trasparent widget in front of camera
class _ConfirmationCameraPreviewDecorator extends StatefulWidget {
  final Stream<_TotemScreenPayload> interactionTriggerStream;
  final Stream<Widget> interactionFeedbackStream;
  final void Function()? onClose;
  final void Function(_TotemScreenPayload)? onAccept;
  final FutureOr<void> Function(_TotemScreenPayload)? onRevise;
  final void Function()? onDiscard;

  const _ConfirmationCameraPreviewDecorator({
    required this.interactionTriggerStream,
    required this.interactionFeedbackStream,
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
  StreamSubscription<_TotemScreenPayload>? _streamInteractionSubscription;
  Widget? _latestInteractionFeedback;
  StreamSubscription<Widget>? _streamInteractionFeedbackSubscription;

  @override
  void didUpdateWidget(covariant _ConfirmationCameraPreviewDecorator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _streamInteractionSubscription?.cancel();
    _streamInteractionFeedbackSubscription?.cancel();
    _startRecievingFromStream();
  }

  @override
  void initState() {
    super.initState();
    _startRecievingFromStream();
  }

  @override
  void dispose() {
    _streamInteractionSubscription?.cancel();
    _streamInteractionFeedbackSubscription?.cancel();
    super.dispose();
  }

  _startRecievingFromStream() {
    _streamInteractionSubscription = widget.interactionTriggerStream.listen(
      (event) {
        if (mounted) {
          setState(() {_latestData = event;});
        }
      },
    );
    _streamInteractionFeedbackSubscription = widget.interactionFeedbackStream.listen(
      (event) {
        if (mounted) {
          setState(() {_latestInteractionFeedback = event;});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _latestData;
    final feedback = _latestInteractionFeedback;

    // final canShowConfirmation = !identical(_latestBuiltData, data) && data != null;
    final canShowInteraction = data != null;
    final canShowInteractionFeedback = feedback != null;

    if (canShowInteraction) {
      return _showInteraction(data);
    }
    else if (canShowInteractionFeedback) {
      return _showInteractionFeedback(feedback);
    }
    else {
      return _showNothig();
    }
  }

  Widget _showNothig() {
    return SizedBox.shrink();
  }

  Widget _showInteraction(_TotemScreenPayload data) {
    return _InteractionPositionAndConstrain(
      child: AppDefaultTotenIdentificationCard(
        detectedFaceJpg: data.jpgFaceDetected,
        recognizedAsJpg: data.jpgFaceRecognized,
        name: data.studentRecognized?.individual.displayFullName ?? '(não reconhecido)',
        registration: data.studentRecognized?.registration ?? '',
        onAccept: () {
          if (widget.onAccept != null) {
            widget.onAccept!(data);
          }
          /* if (widget.onClose != null) {
            widget.onClose!();
          } */
          if (mounted) {
            setState(() {_latestData = null;});
          }
        },
        onRevise: () async {
          if (widget.onRevise != null) {
            await widget.onRevise!(data);
          }
          /* if (widget.onClose != null) {
            widget.onClose!();
          } */
          if (mounted) {
            setState(() {_latestData = null;});
          }
        },
        onDiscard: () {
          if (widget.onDiscard != null) {
            widget.onDiscard!();
          }
          /* if (widget.onClose != null) {
            widget.onClose!();
          } */
          if (mounted) {
            setState(() {_latestData = null;});
          }
        },
      ),
    );
  }

  Widget _showInteractionFeedback(Widget feedback) {
    Future.delayed(_confirmationSnackbarDuration, () {
      if (widget.onClose != null) {
        widget.onClose!();
      }
      if (mounted) {
        setState(() {
          _latestInteractionFeedback = null;
        });
      }
    });
    return _InteractionPositionAndConstrain(
      child: feedback,
    );
  }
}

class _InteractionPositionAndConstrain extends StatelessWidget {
  final Widget child;

  const _InteractionPositionAndConstrain({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: 300, maxWidth: 600),
          child: child,
        ),
      ),
    );
  }
}

class _InteractionFeedback extends StatelessWidget {
  final Widget child;

  const _InteractionFeedback({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _FeedbackText extends StatelessWidget {
  final String text;

  const _FeedbackText(
    this.text, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text,style: Theme.of(context).textTheme.titleMedium);
  }
}