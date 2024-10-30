import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/create_student.dart';
import 'package:facial_recognition/screens/common/submit_form_button.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:flutter/material.dart';

class CreateStudentScreen extends StatefulWidget {
  const CreateStudentScreen({
    super.key,
    required this.useCase,
  });

  final CreateModels useCase;

  @override
  State<CreateStudentScreen> createState() => _CreateStudentScreenState();
}

class _CreateStudentScreenState extends State<CreateStudentScreen> {
  final GlobalKey<FormState> _studentForm = GlobalKey();

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
          'Novo aluno(a)',
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
              key: _studentForm,
              child: CreateStudent(
                individualRegistrationController: _individualRegistration,
                registrationController: _registration,
                nameController: _name,
                surnameController: _surname,
              ),
            ),
            SubmitFormButton(
              formKey: _studentForm,
              action: () {
                try {
                  widget.useCase.createStudent(
                    individualRegistration: _individualRegistration.text,
                    registration: _registration.text,
                    name: _name.text,
                    surname: _surname.text,
                  );
                  /* final facePicture = _facePicture;
                  if (facePicture != null) {
                    widget.useCase.createStudentFacePicture(
                      jpegFacePicture: facePicture,
                      studentRegistration: _registration.text,
                    );
                  }
                  final faceEmbedding = _faceEmbedding;
                  if (faceEmbedding != null) {
                    widget.useCase.createStudentFacialData(
                      embedding: faceEmbedding,
                      studentRegistration: _registration.text,
                    );
                  } */
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
