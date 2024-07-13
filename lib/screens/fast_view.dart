import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class FastView extends StatelessWidget {
  FastView({super.key,});

  final items = List.filled(
    5,
    EmbeddingRecognized(
      identifiedStudent: Student(
        registration: '000000000',
        individual: Individual(
          individualRegistration: '000000000',
          name: 'john',
          surname: 'doe',
        ),
      ),
      inputFace: Uint8List.fromList([]),
      inputFaceEmbedding: [],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (buildContext, i) {
            final item = items.elementAt(i);
            return LimitedBox(
              // maxHeight: 350,
              child: MarkAttendanceFacialCard(
                detectedFaceImage: null,
                identifiedStudent: item.identifiedStudent,
                identifiedStudentFacePicture: null,
                onCorrectRecognition: (student) {},
                onEditRecognition: (student) {},
                onIncorrectRecognition: (student) {},
              ),
            );
          },
        ),
      ),
    );
  }
}

class MarkAttendanceFacialCard extends StatelessWidget {
  const MarkAttendanceFacialCard({
    super.key,
    this.detectedFaceImage,
    this.identifiedStudent,
    this.identifiedStudentFacePicture,
    this.onCorrectRecognition,
    this.onEditRecognition,
    this.onIncorrectRecognition,
  });

  final Uint8List? detectedFaceImage;
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
        AspectRatio(
          aspectRatio: 1.0,
          child: detectedFaceImage != null
              ? Image.memory(detectedFaceImage!)
              : const Icon(Icons.person),
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

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 0.0,
        vertical: 4.0,
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
            Container(
              width: 300,
              color: Colors.amber,
              child: Wrap(
                direction: Axis.horizontal,
                spacing: 8.0,
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                runSpacing: 0.0,
                children: [
                  if (onCorrectRecognition != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.done),
                      label: const Text(
                        'Confirmar',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      onPressed: () => onCorrectRecognition!(identifiedStudent),
                    ),
                  if (onEditRecognition != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit),
                      label: const Text(
                        'Corrigir',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      onPressed: () => onEditRecognition!(identifiedStudent),
                    ),
                  if (onIncorrectRecognition != null)
                    ElevatedButton.icon(
                      // onLongPress: () => onIncorrectRecognition!(identifiedStudent),
                      icon: const Icon(Icons.clear),
                      label: const Text(
                        'Descartar',
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      onLongPress: () => onIncorrectRecognition!(identifiedStudent),
                      onPressed: () { _showSnackBar(context, const Text('Toque e segure o botão.'));},
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, Widget content) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: content),
      );
  }
}
