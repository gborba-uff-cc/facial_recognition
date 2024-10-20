import 'package:facial_recognition/screens/common/card_single_action.dart';
import 'package:flutter/material.dart';

class SpreadsheetSelectedSubjectClass extends StatelessWidget {
  const SpreadsheetSelectedSubjectClass({
    super.key,
    required this.subject,
    required this.subjectClass,
    this.action,
  });

  final String subject;
  final String subjectClass;
  final void Function()? action;

  @override
  Widget build(BuildContext context) {
    return SingleActionCard(
      action: action,
      actionName: 'Selecionar',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Turma selecionada',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Text(
                'Disciplina:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    subject,
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                'Turma:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Text(
                    subjectClass,
                    style: Theme.of(context).textTheme.labelMedium,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
