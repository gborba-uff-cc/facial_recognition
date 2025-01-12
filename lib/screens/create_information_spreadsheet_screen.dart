import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateInformationFromSpreadsheetScreen extends StatelessWidget {
  const CreateInformationFromSpreadsheetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String createDestinationTitle = 'Ler de planilha';
    final List<({void Function() action, String text})> createTriggers = [
      (
        action: () => GoRouter.of(context).push('/create_lesson_from_spreadsheet'),
        text: 'Aula'
      ),
      (
        action: () => GoRouter.of(context).push('/create_student_from_spreadsheet'),
        text: 'Aluno(a)'
      ),
      (
        action: () => GoRouter.of(context).push('/create_attendance_from_spreadsheet'),
        text: 'Presença'
      ),
    ];
    final List<Widget> createMenuItems = createTriggers
        .map(
          (destinationTrigger) => AppDefaultButton(
            onTap: destinationTrigger.action,
            child: Padding(
              padding: EdgeInsets.only(left: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(destinationTrigger.text),
              ),
            ),
          ),
        )
        .toList();

    return AppDefaultMenuScaffold(
      appBar: AppDefaultAppBar(title: createDestinationTitle),
      body: AppDefaultMenuList(
        children: createMenuItems,
      ),
    );
  }
}