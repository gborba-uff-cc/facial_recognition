import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/use_case/mark_attendance.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class MarkAttendanceScreen extends StatelessWidget {
  const MarkAttendanceScreen({
    super.key,
    required this.useCase,
  });

  final MarkAttendance useCase;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Revisão',
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineLarge,
          overflow: TextOverflow.fade,
        ),
      ),
      body: Center(
        child: RecognitionReviewer(useCase: useCase),
      ),
    );
  }
}

class RecognitionReviewer extends StatefulWidget {
  const RecognitionReviewer({
    super.key,
    required this.useCase,
  });

  final MarkAttendance useCase;

  @override
  State<RecognitionReviewer> createState() => _RecognitionReviewerState();
}

class _RecognitionReviewerState extends State<RecognitionReviewer> {
  @override
  void initState() {
    cameraRecognized = widget.useCase.getFaceRecognizedFromCamera();
    cameraNotRecognized = widget.useCase.getFaceNotRecognizedFromCamera();
    studentFacePicture = widget.useCase.getStudentFaceImage();
    super.initState();
  }

  Iterable<EmbeddingRecognized> cameraRecognized = [];
  Iterable<EmbeddingNotRecognized> cameraNotRecognized = [];
  Map<Student, FacePicture?> studentFacePicture = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cameraRecognized.length,
      itemBuilder: (buildContext, i) {
        final item = cameraRecognized.elementAt(i);
        return ReviewCard(
          key: ObjectKey(item),
          recognition: item,
          identifiedStudentFacePicture:
              studentFacePicture[item.identifiedStudent]?.faceJpeg,
          onCorrectAction: _handleConfirmRecognition,
          onReviseAction: _handleReviseRecognition,
          onDiscardAction: _handleDiscardRecognition,
        );
      },
    );
  }

  void _handleConfirmRecognition(
    EmbeddingRecognized recognition,
  ) {
    if (recognition.identifiedStudent == null) {
      projectLogger.severe('a recognition without a student was confirmed.');
      return;
    }
    widget.useCase.writeStudentAttendance([recognition.identifiedStudent]);
    widget.useCase.removeFaceRecognizedFromCamera([recognition]);
    setState(() {
      cameraRecognized = widget.useCase.getFaceRecognizedFromCamera();
    });
  }

  void _handleReviseRecognition(
    EmbeddingRecognized recognition,
    Student? other,
  ) {
    widget.useCase.updateFaceRecognitionFromCamera(recognition, other);
    setState(() {
      cameraRecognized = widget.useCase.getFaceRecognizedFromCamera();
    });
  }

  void _handleDiscardRecognition(
    EmbeddingRecognized recognition,
  ) {
    widget.useCase.removeFaceRecognizedFromCamera([recognition]);
    setState(() {
      cameraRecognized = widget.useCase.getFaceRecognizedFromCamera();
    });  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    super.key,
    required this.recognition,
    this.identifiedStudentFacePicture,
    this.onCorrectAction,
    this.onReviseAction,
    this.onDiscardAction,
  });

  final EmbeddingRecognized recognition;
  final Uint8List? identifiedStudentFacePicture;
  final void Function(
    EmbeddingRecognized recognition,
  )? onCorrectAction;
  final void Function(
    EmbeddingRecognized recognition,
    Student? student,
  )? onReviseAction;
  final void Function(
    EmbeddingRecognized recognition,
  )? onDiscardAction;

  @override
  Widget build(BuildContext context) {
    final studentFullName =
        recognition.identifiedStudent.individual.displayFullName;
    final columnDetected = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: Image.memory(recognition.inputFace),
        ),
        Text(
          'Detectado',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
    final columnRegistered = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: identifiedStudentFacePicture != null
              ? Image.memory(identifiedStudentFacePicture!)
              : const Icon(Icons.person),
        ),
        Text(
          'Cadastrado',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: 0.0,
          vertical: 0.0,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                studentFullName != null ? 'É $studentFullName?' : '',
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: columnDetected,
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: columnRegistered,
                  ),
                ],
              ),
              const Divider(indent: 16.0, endIndent: 16.0),
              Wrap(
                direction: Axis.horizontal,
                spacing: 8.0,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                runSpacing: 0.0,
                children: [
                  FilledButton.icon(
                    icon: const Icon(Icons.done),
                    label: const Text(
                      'Confirmar',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    onPressed: (onCorrectAction != null)
                        ? () => onCorrectAction!(recognition)
                        : null,
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      'Corrigir',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    onPressed: (onReviseAction != null)
                        ? () => onReviseAction!(recognition, null)
                        : null,
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text(
                      'Descartar',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    onLongPress: (onDiscardAction != null)
                        ? () => onDiscardAction!(recognition)
                        : null,
                    onPressed: (onDiscardAction != null)
                        ? () => _showSnackBar(
                            context,
                            const Text(
                              'Toque e segure o botão.',
                              textAlign: TextAlign.center,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showSnackBar(BuildContext context, Widget content) {
  ScaffoldMessenger.of(context)
    ..removeCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: content),
    );
}
