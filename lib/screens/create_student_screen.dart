import 'dart:typed_data';

import 'package:camera/camera.dart' as pkg_camera;
import 'package:facial_recognition/screens/widgets/create_student.dart';
import 'package:facial_recognition/screens/widgets/submit_form_button.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:facial_recognition/utils/project_logger.dart';
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

  /// not used to build the widget, just hold retrieved value from the form
  Uint8List? _facePicture;

  String _individualRegistrationValue = '';
  String _registrationValue = '';
  String _nameValue = '';
  String _surnameValue = '';

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
                isValidFacePicture: widget.useCase.isOneFacePicture,
                facePictureOnSaved: (final cameraImage, final cameraDescription) {
                  // REVIEW - cameraDescription should not be null;
                  _facePicture = cameraDescription == null || cameraImage == null
                      ? null
                      : widget.useCase.toJpg(
                          cameraImage,
                          cameraDescription.sensorOrientation,
                        );
                },
                individualRegistrationController: _individualRegistration,
                registrationController: _registration,
                nameController: _name,
                surnameController: _surname,
              ),
            ),
            SubmitFormButton(
              formKey: _studentForm,
              action: () {
                widget.useCase.createStudent(
                  individualRegistration: _individualRegistration.text,
                  registration: _registration.text,
                  name: _name.text,
                  surname: _surname.text,
                );
                // TODO - ask for face picture
                // if (jpegFacePicture != null) {
                //   widget.useCase.createStudentFacePicture(
                //     jpegFacePicture: jpegFacePicture,
                //     studentRegistration: _individualRegistration.text,
                //   );
                //   widget.useCase.createStudentFacialData(
                //     embedding: embedding,
                //     studentRegistration: _individualRegistration.text,
                //   );
                // }
              },
            ),
          ],
        ),
      ),
    );
  }
}
