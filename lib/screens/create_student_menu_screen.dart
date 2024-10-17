import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateStudentMenuScreen extends StatelessWidget {
  const CreateStudentMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<({Function() action, String text})> triggers = [
      (
        action: () => GoRouter.of(context).push('/create_student_manually'),
        text: 'Entrada manual',
      ),
      (
        action: () => GoRouter.of(context).push('/create_student_batch_read'),
        text: 'Ler de planilha',
      ),
    ];
    final List<Widget> menuItems = triggers
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
      appBar: AppBar(title: Text('Adicionar discente'),),
      body: AppDefaultMenuList(children: menuItems),
    );
  }
}
