import 'package:facial_recognition/screens/widgets/create_subject.dart';
import 'package:facial_recognition/screens/widgets/submit_form_button.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:flutter/material.dart';

class CreateSubjectScreen extends StatefulWidget {
  const CreateSubjectScreen({
    super.key,
    required this.useCase,
  });

  final CreateModels useCase;

  @override
  State<CreateSubjectScreen> createState() => _CreateSubjectScreenState();
}

class _CreateSubjectScreenState extends State<CreateSubjectScreen> {
  final GlobalKey<FormState> _subjectForm = GlobalKey();

  final TextEditingController _code =
      TextEditingController.fromValue(null);
  final TextEditingController _name =
      TextEditingController.fromValue(null);

  @override
  void dispose() {
    _code.dispose();
    _name.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nova disciplina',
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineLarge,
          overflow: TextOverflow.fade,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Form(
              key: _subjectForm,
              child: CreateSubject(
                codeController: _code,
                nameController: _name,
              ),
            ),
            SubmitFormButton(
              formKey: _subjectForm,
              action: () {
                widget.useCase.createSubject(
                  code: _code.text,
                  name: _name.text,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
