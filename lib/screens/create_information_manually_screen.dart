import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateInformationManuallyScreen extends StatelessWidget {
  const CreateInformationManuallyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String createDestinationTitle = 'Entrada Manual';
    final List<({void Function() action, String text})> createTriggers = [
      (
        action: () => GoRouter.of(context).push('/create_teacher'),
        text: 'Professor(a)'
      ),
      (
        action: () => GoRouter.of(context).push('/create_subject'),
        text: 'Disciplina',
      ),
      (
        action: () => GoRouter.of(context).push('/create_subject_class'),
        text: 'Turma'
      ),
      (
        action: () => GoRouter.of(context).push('/create_lesson_manually'),
        text: 'Aula'
      ),
      (
        action: () => GoRouter.of(context).push('/create_student_manually'),
        text: 'Aluno(a)'
      ),
      (
        action: () => GoRouter.of(context).push('/create_enrollment'),
        text: 'Inscrição em turma'
      ),
      (
        action: () => GoRouter.of(context).push('/create_face_picture_embedding'),
        text: 'Foto e embeddings',
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
