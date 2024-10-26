import 'dart:typed_data';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/create_teacher.dart';
import 'package:facial_recognition/screens/common/submit_form_button.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;

class CreateTeacherScreen extends StatefulWidget {
  const CreateTeacherScreen({
    super.key,
    required this.createModelsUseCase,
    required this.facialDataHandlerUseCase,
  });

  final CreateModels createModelsUseCase;
  final IFacialDataHandler<pkg_awesome.AnalysisImage, JpegPictureBytes, FaceEmbedding> facialDataHandlerUseCase;

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
                // FIXME
                faceDetector: null,
                faceEmbedder: null,
                jpgConverter: null,
                facePictureOnSaved: null,
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
                  final facePicture = _facePicture;
                  if (facePicture != null) {
                    widget.createModelsUseCase.createTeacherFacePicture(
                      jpegFacePicture: facePicture,
                      teacherRegistration: _registration.text,
                    );
                  }
                  final faceEmbedding = _faceEmbedding;
                  if (faceEmbedding != null) {
                    widget.createModelsUseCase.createTeacherFacialData(
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