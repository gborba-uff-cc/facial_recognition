import "dart:typed_data";

import "package:camera/camera.dart" as pkg_camera;
import "package:image/image.dart" as pkg_image;
import "package:facial_recognition/models/domain.dart";
import "package:facial_recognition/models/use_case.dart";
import "package:facial_recognition/screens/common/form_fields.dart";
import "package:flutter/material.dart";

class CreateStudent extends StatefulWidget {
  const CreateStudent({
    super.key,
    // [cameraSensorOrientation] degrees the camera image need to be rotated to be upright
    Future<List<pkg_image.Image>> Function(
      pkg_camera.CameraImage cameraImage,
      pkg_camera.CameraController cameraController,
    )? faceDetector,
    Future<List<Duple<Uint8List, List<double>>>> Function(
      pkg_image.Image face,
    )? faceEmbedder,
    void Function(pkg_camera.CameraImage?, pkg_camera.CameraController?,
            FaceEmbedding?)?
        facePictureOnSaved,
    Future<Uint8List> Function(pkg_image.Image)? jpgConverter,
    required TextEditingController individualRegistrationController,
    void Function(String?)? individualRegistrationOnSaved,
    required TextEditingController registrationController,
    void Function(String?)? registrationOnSaved,
    required TextEditingController nameController,
    void Function(String?)? nameOnSaved,
    required TextEditingController surnameController,
    void Function(String?)? surnameControllerOnSaved,
  })  : _faceDetector = faceDetector,
        _faceEmbedder = faceEmbedder,
        _jpgConverter = jpgConverter,
        _facePictureOnSaved = facePictureOnSaved,
        _individualRegistrationController = individualRegistrationController,
        _individualRegistrationOnSaved = individualRegistrationOnSaved,
        _registrationController = registrationController,
        _registrationOnSaved = registrationOnSaved,
        _nameController = nameController,
        _nameOnSaved = nameOnSaved,
        _surnameController = surnameController,
        _surnameOnSaved = surnameControllerOnSaved;

  final Future<List<pkg_image.Image>> Function(
    pkg_camera.CameraImage cameraImage,
    pkg_camera.CameraController cameraController,
  )? _faceDetector;
  final Future<List<Duple<Uint8List, List<double>>>> Function(
    pkg_image.Image face,
  )? _faceEmbedder;
  final Future<Uint8List> Function(
    pkg_image.Image face,
  )? _jpgConverter;
  final void Function(pkg_camera.CameraImage?, pkg_camera.CameraController?,
      FaceEmbedding?)? _facePictureOnSaved;
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
      isOptional: true,
      faceDetector: widget._faceDetector,
      faceEmbedder: widget._faceEmbedder,
      // jpgConverter: widget._jpgConverter,
      onSaved: widget._facePictureOnSaved,
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
