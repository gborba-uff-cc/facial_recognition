import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/use_case/mark_attendance.dart';
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

    return Scaffold(
      appBar: AppBar(),
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
              itemBuilder: (buildContext, i) => LimitedBox(
                maxHeight: 150,
                child: MarkAttendanceFacialCard(
                  item: cameraRecognized.elementAt(i),
                  onCorrectRecognition: (recognizedEmbedding) => useCase.writeStudentAttendance([recognizedEmbedding.nearestStudent]),
                  onIncorrectRecognition: null,
                ),
              ),
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
              itemBuilder: (buildContext, i) => LimitedBox(
                maxHeight: 150,
                child: MarkAttendanceFacialCard(
                  item: cameraRecognized.elementAt(i),
                  onCorrectRecognition: null,
                  onIncorrectRecognition: null,
                ),
              ),
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
    required this.item,
    this.onCorrectRecognition,
    this.onIncorrectRecognition,
  });

  final EmbeddingRecognized item;
  final void Function(EmbeddingRecognized recognizedEmbedding)? onCorrectRecognition;
  final void Function(EmbeddingRecognized recognizedEmbedding)? onIncorrectRecognition;

  @override
  Widget build(BuildContext context) {
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
          child: Image.memory(item.inputFace),
        ),
      ],
    );
    final columnRegistered = Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Flexible(
          child: Text(
            'cadastrado',
            maxLines: 1,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Icon(Icons.person),
        ),
      ],
    );
    final columnActions = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            'É ${item.nearestStudent.individual.displayFullName}?',
            maxLines: 1,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextButton(
                  onPressed: () {
                    if (onCorrectRecognition != null) {
                      onCorrectRecognition!(item);
                    }
                  },
                  child: const Text('Sim'),
                ),
              ),
              Flexible(
                child: TextButton(
                  onPressed: () {
                    if (onIncorrectRecognition != null) {
                      onIncorrectRecognition!(item);
                    }
                  },
                  child: const Text('Não'),
                ),
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
