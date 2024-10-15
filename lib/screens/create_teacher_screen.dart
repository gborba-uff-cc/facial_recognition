import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/create_teacher.dart';
import 'package:facial_recognition/screens/common/submit_form_button.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:flutter/material.dart';

class CreateTeacherScreen extends StatefulWidget {
  const CreateTeacherScreen({
    super.key,
    required this.useCase,
  });

  final CreateModels useCase;

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

  /// not used to build the widget, just hold retrieved value from the form
  Uint8List? _facePicture;
  FaceEmbedding? _faceEmbedding;

  // String _individualRegistrationValue = '';
  // String _registrationValue = '';
  // String _nameValue = '';
  // String _surnameValue = '';

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
                faceDetector: widget.useCase.detectFaces,
                faceEmbedder: widget.useCase.extractEmbedding,
                jpgConverter: (image) async => widget.useCase.fromImageToJpg(image),
                facePictureOnSaved: (final cameraImage, final cameraDescription, final faceEmbedding) {
                  // REVIEW - cameraDescription should not be null?;
                  final facePicture = cameraDescription == null || cameraImage == null
                      ? null
                      : widget.useCase.fromCameraImagetoJpg(
                          cameraImage,
                          cameraDescription,
                        );
                  _facePicture = facePicture;
                  _faceEmbedding = faceEmbedding;
                },
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
                  widget.useCase.createTeacher(
                    individualRegistration: _individualRegistration.text,
                    registration: _registration.text,
                    name: _name.text,
                    surname: _surname.text,
                  );
                  final facePicture = _facePicture;
                  if (facePicture != null) {
                    widget.useCase.createTeacherFacePicture(
                      jpegFacePicture: facePicture,
                      teacherRegistration: _registration.text,
                    );
                  }
                  final faceEmbedding = _faceEmbedding;
                  if (faceEmbedding != null) {
                    widget.useCase.createTeacherFacialData(
                      embedding: faceEmbedding,
                      teacherRegistration: _registration.text,
                    );
                  }
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