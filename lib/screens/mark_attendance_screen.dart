import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/use_case/mark_attendance.dart';
import 'package:flutter/material.dart';

class MarkAttendanceScreen extends StatelessWidget {
  factory MarkAttendanceScreen({
    Key? key,
    required DomainRepository domainRepository,
    required Lesson lesson,
  }) =>
      MarkAttendanceScreen._private(
        key: key,
        useCase: MarkAttendance(
          domainRepository,
          lesson,
        ),
      );

  const MarkAttendanceScreen._private({
    super.key,
    required MarkAttendance useCase,
  }) : _useCase = useCase;

  final MarkAttendance _useCase;

  @override
  Widget build(BuildContext context) {
    final Iterable<EmbeddingRecognized> cameraRecognized =
        _useCase.getFaceRecognizedFromCamera();

    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemBuilder: (buildContext, i) => LimitedBox(
          maxHeight: 150,
          child: MarkAttendanceFacialCard(
            item: cameraRecognized.elementAt(i),
          ),
        ),
        itemCount: cameraRecognized.length,
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
  final void Function(EmbeddingRecognized)? onCorrectRecognition;
  final void Function(EmbeddingRecognized)? onIncorrectRecognition;

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
            '${item.nearestStudent.individual.name} ${item.nearestStudent.individual.surname}?',
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
