import 'package:facial_recognition/screens/common/create_teacher.dart';
import 'package:facial_recognition/screens/common/submit_form_button.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:flutter/material.dart';

class CreateTeacherScreen extends StatefulWidget {
  const CreateTeacherScreen({
    super.key,
    required this.createModelsUseCase,
  });

  final CreateModels createModelsUseCase;

  @override
  State<CreateTeacherScreen> createState() => _CreateTeacherScreenState();
}

class _CreateTeacherScreenState extends State<CreateTeacherScreen> {
  final GlobalKey<FormState> _teacherForm = GlobalKey();

  final TextEditingController _individualRegistration =
      TextEditingController.fromValue(null);
  final TextEditingController _registration =
      TextEditingController.fromValue(null);
  final TextEditingController _name =
      TextEditingController.fromValue(null);
  final TextEditingController _surname =
      TextEditingController.fromValue(null);

  @override
  void dispose() {
    _individualRegistration.dispose();
    _registration.dispose();
    _name.dispose();
    _surname.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Novo professor(a)',
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
              key: _teacherForm,
              child: CreateTeacher(
                individualRegistrationController: _individualRegistration,
                registrationController: _registration,
                nameController: _name,
                surnameController: _surname,
              ),
            ),
            SubmitFormButton(
              formKey: _teacherForm,
              action: () {
                try {
                  widget.createModelsUseCase.createTeacher(
                    individualRegistration: _individualRegistration.text,
                    registration: _registration.text,
                    name: _name.text,
                    surname: _surname.text,
                  );
                } on ArgumentError catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}