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
    final Iterable<EmbeddingRecognized> cameraRecognized =
        useCase.getFaceRecognizedFromCamera();
    final Iterable<EmbeddingNotRecognized> cameraNotRecognized =
        useCase.getFaceNotRecognizedFromCamera();
    final Map<Student, FacePicture?> studentFacePicture = useCase.getStudentFaceImage();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Revisão',
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineLarge,
          overflow: TextOverflow.fade,
        ),
      ),
      body: Column(
        children: [
          Text(
            'Manual',
            maxLines: 1,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Divider(),
          Text(
            'Reconhecido',
            maxLines: 1,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Flexible(
            fit: FlexFit.tight,
            child: ListView.builder(
              itemCount: cameraRecognized.length,
              itemBuilder: (buildContext, i) {
                final embeddingItem = cameraRecognized.elementAt(i);
                return LimitedBox(
                  maxHeight: 150,
                  child: MarkAttendanceFacialCard(
                    detectedFaceImage: embeddingItem.inputFace,
                    identifiedStudent: embeddingItem.identifiedStudent,
                    identifiedStudentFacePicture: studentFacePicture[embeddingItem.identifiedStudent]?.faceJpeg,
                    onCorrectRecognition: (student) => student == null
                        ? null
                        : useCase.writeStudentAttendance([student]),
                    onIncorrectRecognition: null,
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Text(
            'Não reconhecido',
            maxLines: 1,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Flexible(
            fit: FlexFit.tight,
            child: ListView.builder(
              itemCount: cameraNotRecognized.length,
              itemBuilder: (buildContext, i) {
                final embeddingItem = cameraNotRecognized.elementAt(i);
                return LimitedBox(
                  maxHeight: 150,
                  child: MarkAttendanceFacialCard(
                    detectedFaceImage: embeddingItem.inputFace,
                    identifiedStudent: null,
                    onCorrectRecognition: null,
                    onEditRecognition: (student) => projectLogger.fine(student),
                    onIncorrectRecognition: null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MarkAttendanceFacialCard extends StatelessWidget {
  const MarkAttendanceFacialCard({
    super.key,
    required this.detectedFaceImage,
    this.identifiedStudent,
    this.identifiedStudentFacePicture,
    this.onCorrectRecognition,
    this.onEditRecognition,
    this.onIncorrectRecognition,
  });

  final Uint8List detectedFaceImage;
  final Student? identifiedStudent;
  final Uint8List? identifiedStudentFacePicture;
  final void Function(Student? student)? onCorrectRecognition;
  final void Function(Student? student)? onEditRecognition;
  final void Function(Student? student)? onIncorrectRecognition;

  @override
  Widget build(BuildContext context) {
    final studentFullName =
        identifiedStudent?.individual.displayFullName;
    final columnDetected = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Flexible(
          child: Text(
            'detectado',
            maxLines: 1,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Image.memory(detectedFaceImage),
        ),
      ],
    );
    final columnRegistered = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Flexible(
          child: Text(
            'cadastrado',
            maxLines: 1,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: identifiedStudentFacePicture != null
              ? Image.memory(identifiedStudentFacePicture!)
              : const Icon(Icons.person),
        ),
      ],
    );
    final columnActions = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            studentFullName != null ? 'É $studentFullName?' : '',
            maxLines: 1,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (onCorrectRecognition != null)
                IconButton(
                  onPressed: () => onCorrectRecognition!(identifiedStudent),
                  icon: const Icon(Icons.done),
                ),
              if (onIncorrectRecognition != null)
                IconButton(
                  onPressed: () => onIncorrectRecognition!(identifiedStudent),
                  icon: const Icon(Icons.clear),
                ),
              if (onEditRecognition != null)
                IconButton(
                  onPressed: () => onEditRecognition!(identifiedStudent),
                  icon: const Icon(Icons.person_add),
                ),
            ],
          ),
        )
      ],
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(fit: FlexFit.tight, child: columnDetected),
        Flexible(fit: FlexFit.tight, child: columnRegistered),
        Flexible(flex: 2, fit: FlexFit.tight, child: columnActions),
      ],
    );
  }
}
