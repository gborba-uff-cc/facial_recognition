import "package:camera/camera.dart" as pkg_camera;
import "package:facial_recognition/screens/widgets/form_fields.dart";
import "package:facial_recognition/utils/project_logger.dart";
import "package:flutter/material.dart";

class CreateStudent extends StatefulWidget {
  const CreateStudent({
    super.key,
    required Future<bool> Function(pkg_camera.CameraImage, int) isValidFacePicture,
    void Function(pkg_camera.CameraImage?, pkg_camera.CameraDescription?)? facePictureOnSaved,
    required TextEditingController individualRegistrationController,
    void Function(String?)? individualRegistrationOnSaved,
    required TextEditingController registrationController,
    void Function(String?)? registrationOnSaved,
    required TextEditingController nameController,
    void Function(String?)? nameOnSaved,
    required TextEditingController surnameController,
    void Function(String?)? surnameControllerOnSaved,
  })  : _isValidFacePicture = isValidFacePicture,
        _facePictureOnSaved = facePictureOnSaved,
        _individualRegistrationController = individualRegistrationController,
        _individualRegistrationOnSaved = individualRegistrationOnSaved,
        _registrationController = registrationController,
        _registrationOnSaved = registrationOnSaved,
        _nameController = nameController,
        _nameOnSaved = nameOnSaved,
        _surnameController = surnameController,
        _surnameOnSaved = surnameControllerOnSaved;

  final Future<bool> Function(pkg_camera.CameraImage, int) _isValidFacePicture;
  final void Function(pkg_camera.CameraImage?, pkg_camera.CameraDescription?)? _facePictureOnSaved;
  final TextEditingController _individualRegistrationController;
  final void Function(String?)? _individualRegistrationOnSaved;
  final TextEditingController _registrationController;
  final void Function(String?)? _registrationOnSaved;
  final TextEditingController _nameController;
  final void Function(String?)? _nameOnSaved;
  final TextEditingController _surnameController;
  final void Function(String?)? _surnameOnSaved;

  @override
  State<CreateStudent> createState() => _CreateStudentState();
}

class _CreateStudentState extends State<CreateStudent> {
  @override
  Widget build(BuildContext context) {
    final inputPicture = FacePictureField(
      onSaved: widget._facePictureOnSaved,
      isValidFacePicture: widget._isValidFacePicture,
    );

    final inputRegistration = TextFormField(
      controller: widget._registrationController,
      decoration: const InputDecoration(
        labelText: 'Matrícula',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
      onSaved: widget._registrationOnSaved,
    );

    final inputIndividualRegistration = TextFormField(
      controller: widget._individualRegistrationController,
      decoration: const InputDecoration(
        labelText: 'CPF',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
      onSaved: widget._individualRegistrationOnSaved,
    );

    final inputName = TextFormField(
      controller: widget._nameController,
      decoration: const InputDecoration(
        labelText: 'Nome',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
      onSaved: widget._nameOnSaved,
    );

    final inputSurname = TextFormField(
      controller: widget._surnameController,
      decoration: const InputDecoration(
        labelText: 'Sobrenome',
        helperText: 'opcional'
      ),
      onSaved: widget._surnameOnSaved,
    );

    return Column(
      children: [
        inputPicture,
        inputRegistration,
        inputName,
        inputSurname,
        inputIndividualRegistration,
      ],
    );
  }
}
