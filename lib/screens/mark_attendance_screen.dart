import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/screens/grid_student_selector_screen.dart';
import 'package:facial_recognition/use_case/mark_attendance.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    recognitions = widget.useCase.getRecognitionFromCamera();
    studentFacePicture = widget.useCase.getStudentFaceImage();
    super.initState();
  }

  Iterable<EmbeddingRecognitionResult> recognitions = [];
  Map<Student, FacePicture?> studentFacePicture = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: recognitions.length,
      itemBuilder: (buildContext, i) {
        final item = recognitions.elementAt(i);
        return ReviewCard(
          key: ObjectKey(item.inputFace),
          recognition: item,
          identifiedStudentFacePicture:
              studentFacePicture[item.nearestStudent]?.faceJpeg,
          onCorrectAction: item.recognized ? () => _handleConfirmRecognition(item) : null,
          onReviseAction: () => _handleReviseRecognition(item),
          onDiscardAction: () => _handleDiscardRecognition(item),
        );
      },
    );
  }

  void _handleConfirmRecognition(
    EmbeddingRecognitionResult recognition,
  ) {
    final recognizedStudent = recognition.nearestStudent;
    if (recognizedStudent == null) {
      projectLogger.severe('a recognition without a student was confirmed.');
      return;
    }
    widget.useCase.writeStudentAttendance([
      (student: recognizedStudent, arriveUtcDateTime: recognition.utcDateTime),
    ]);
    widget.useCase.removeRecognitionFromCamera([recognition]);
    setState(() {
      recognitions = widget.useCase.getRecognitionFromCamera();
    });
  }

  void _handleReviseRecognition(
    EmbeddingRecognitionResult recognition,
  ) async {
    final items = studentFacePicture.entries.toList();
    final initialySelected = recognition.recognized
        ? items.firstWhere(
            (element) => element.key == recognition.nearestStudent,
          )
        : null;
    final newSelection =
        await GoRouter.of(context).push<MapEntry<Student, FacePicture?>>(
      '/mark_attendance_edit_student',
      extra: GridStudentSelectorScreenArguments(
        items: items,
        initialySelected: initialySelected,
      ),
    );
    final newStudent = newSelection?.key;
    widget.useCase.updateRecognitionFromCamera(recognition, newStudent);
    setState(() {
      recognitions = widget.useCase.getRecognitionFromCamera();
    });
  }

  void _handleDiscardRecognition(
    EmbeddingRecognitionResult recognition,
  ) {
    widget.useCase.removeRecognitionFromCamera([recognition]);
    setState(() {
      recognitions = widget.useCase.getRecognitionFromCamera();
    });
  }
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

  final EmbeddingRecognitionResult recognition;
  final Uint8List? identifiedStudentFacePicture;
  final void Function()? onCorrectAction;
  final void Function()? onReviseAction;
  final void Function()? onDiscardAction;

  @override
  Widget build(BuildContext context) {
    final studentFullName =
        recognition.nearestStudent?.individual.displayFullName;
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
                recognition.recognized ? 'É $studentFullName?' : 'Quem é?',
                maxLines: 1,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Row(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: PictureTile(
                      jpeg: recognition.inputFace,
                      footer: Text(
                        'Detectado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    child: PictureTile(
                      jpeg: recognition.recognized ? identifiedStudentFacePicture : null,
                      footer: Text(
                        'Cadastrado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
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
                    onPressed: onCorrectAction,
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text(
                      'Corrigir',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    onPressed: onReviseAction,
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.clear),
                    label: const Text(
                      'Descartar',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                    ),
                    onLongPress: onDiscardAction,
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

class PictureTile extends StatelessWidget {
  const PictureTile({
    super.key,
    this.jpeg,
    this.footer,
  });

  final Uint8List? jpeg;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: jpeg != null
              ? Image.memory(jpeg!, fit: BoxFit.contain)
              : const Center(
                  child: Icon(Icons.person),
                ),
        ),
        if(footer != null)
          footer!,
      ],
    );
  }
}