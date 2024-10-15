import 'package:facial_recognition/screens/common/create_enrollment.dart';
import 'package:facial_recognition/screens/common/submit_form_button.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class CreateEnrollmentScreen extends StatefulWidget {
  const CreateEnrollmentScreen({
    super.key,
    required this.useCase,
  });

  final CreateModels useCase;

  @override
  State<CreateEnrollmentScreen> createState() => _CreateEnrollmentScreenState();
}

class _CreateEnrollmentScreenState extends State<CreateEnrollmentScreen> {
  final GlobalKey<FormState> _enrollmentForm = GlobalKey();

  final TextEditingController _registrationOfStudent =
      TextEditingController.fromValue(null);
  final TextEditingController _year =
      TextEditingController.fromValue(null);
  final TextEditingController _semester =
      TextEditingController.fromValue(null);
  final TextEditingController _codeOfSubject =
      TextEditingController.fromValue(null);
  final TextEditingController _name =
      TextEditingController.fromValue(null);

  @override
  void dispose() {
    _codeOfSubject.dispose();
    _registrationOfStudent.dispose();
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
          'Nova inscrição',
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
              key: _enrollmentForm,
              child: CreateEnrollment(
                codeOfSubject: _codeOfSubject,
                registrationOfStudent: _registrationOfStudent,
                year: _year,
                semester: _semester,
                name: _name,
              ),
            ),
            SubmitFormButton(
              formKey: _enrollmentForm,
              action: () {
                final year = _year;
                final semester = _semester;
                widget.useCase.createEnrollment(
                  codeOfSubject: _codeOfSubject.text,
                  registrationOfStudent: _registrationOfStudent.text,
                  year: _year.text,
                  semester: _semester.text,
                  name: _name.text,
                );
                projectLogger
                    .fine('[enrollment] year: $year, semester: $semester');
              },
            ),
          ],
        ),
      ),
    );
  }
}
