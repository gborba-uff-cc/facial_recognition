import 'package:facial_recognition/screens/common/create_subject_class.dart';
import 'package:facial_recognition/screens/common/submit_form_button.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class CreateSubjectClassScreen extends StatefulWidget {
  const CreateSubjectClassScreen({
    super.key,
    required this.useCase,
  });

  final CreateModels useCase;

  @override
  State<CreateSubjectClassScreen> createState() => _CreateSubjectClassScreenState();
}

class _CreateSubjectClassScreenState extends State<CreateSubjectClassScreen> {
  final GlobalKey<FormState> _subjectClassForm = GlobalKey();

  final TextEditingController _codeOfSubject =
      TextEditingController.fromValue(null);
  final TextEditingController _registrationOfTeacher =
      TextEditingController.fromValue(null);
  final TextEditingController _year =
      TextEditingController.fromValue(null);
  final TextEditingController _semester =
      TextEditingController.fromValue(null);
  final TextEditingController _name =
      TextEditingController.fromValue(null);

  @override
  void dispose() {
    _codeOfSubject.dispose();
    _registrationOfTeacher.dispose();
    _year.dispose();
    _semester.dispose();
    _name.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nova turma',
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
              key: _subjectClassForm,
              child: CreateSubjectClass(
                codeOfSubject: _codeOfSubject,
                registrationOfTeacher: _registrationOfTeacher,
                year: _year,
                semester: _semester,
                name: _name,
              ),
            ),
            SubmitFormButton(
              formKey: _subjectClassForm,
              action: () {
                final year = _year;
                final semester = _semester;
                widget.useCase.createSubjectClass(
                  codeOfSubject: _codeOfSubject.text,
                  registrationOfTeacher: _registrationOfTeacher.text,
                  year: _year.text,
                  semester: _semester.text,
                  name: _name.text,
                );
                projectLogger
                    .fine('[subjectClass] year: $year, semester: $semester');
              },
            ),
          ],
        ),
      ),
    );
  }
}
