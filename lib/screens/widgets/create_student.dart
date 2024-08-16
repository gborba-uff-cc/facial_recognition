import "dart:typed_data";

import "package:camera/camera.dart" as pkg_camera;
import "package:facial_recognition/models/use_case.dart";
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
  _CandidatePicture? _candidatePicture;
  _FacePictureValidationStatus _facePictureValidationStatus =
      _FacePictureValidationStatus.isValid;

  @override
  Widget build(BuildContext context) {
    final inputPicture = CameraImageField(
      // validator: (final FormFieldState<
      //             Duple<pkg_camera.CameraImage, pkg_camera.CameraDescription>>
      //         field,
      //     final cameraImage,
      //     final cameraDescription) {
      //   final oldCandidate = _candidatePicture;
      //   final oldStatus = _facePictureValidationStatus;
      //   final isValidating =
      //       oldStatus == _FacePictureValidationStatus.validating;
      //   final isAnotherImage = (oldCandidate == null && cameraImage != null) ||
      //       (oldCandidate != null && cameraImage == null) ||
      //       (oldCandidate != null &&
      //           cameraImage != null &&
      //           oldCandidate.value1 != cameraImage);

      //   projectLogger.fine('validating: $isValidating; isAnotherImage: $isAnotherImage');
      //   // update and validate a candidate picture when:
      //   // 1. not validating another picture, 2. is another picture
      //   if (!isValidating && isAnotherImage) {
      //     if (cameraDescription == null) {
      //       projectLogger.severe(
      //         'CreateStudentScreen: missing cameraCamera description for the picture candidate',
      //       );
      //     } else if (cameraImage != null) {
      //       _candidatePicture = _CandidatePicture(
      //         cameraImage,
      //         cameraDescription,
      //       );
      //       _facePictureValidationStatus =
      //           _FacePictureValidationStatus.validating;
      //       // change later the validation status
      //       _validateFacePicture(
      //         cameraImage,
      //         cameraDescription.sensorOrientation,
      //       ).then((status) {
      //         if (field.mounted) {
      //           field.setState(() {
      //             projectLogger.fine('validation status updated');
      //             field.validate();
      //             _facePictureValidationStatus = status;
      //           });
      //         }
      //       });
      //     } else {
      //       _candidatePicture = null;
      //       _facePictureValidationStatus = _FacePictureValidationStatus.isValid;
      //     }
      //   }
      //   // still validating or is the same image
      //   else {}

      //   // validation result
      //   switch (_facePictureValidationStatus) {
      //     case _FacePictureValidationStatus.notValid:
      //       return 'Can not use as a face picture';
      //     case _FacePictureValidationStatus.validating:
      //       return 'Validating picture';
      //     case _FacePictureValidationStatus.isValid:
      //       return 'Valid';
      //   }
      // },
      onSaved: widget._facePictureOnSaved == null
          ? null
          : (final cameraImage, final cameraDescription) {
              final candidatePicture = _candidatePicture;
              if (cameraImage != candidatePicture?.value1) {
                projectLogger.severe('tried to save a not validated picture');
              } else {
                widget._facePictureOnSaved!(cameraImage, cameraDescription);
              }
            },
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

  Future<_FacePictureValidationStatus> _validateFacePicture(
    final pkg_camera.CameraImage picture,
    final int sensorOrientation,
  ) async {
    projectLogger.fine('validating image');
    bool valid = false;
    // there is one face on the picture
    valid = await widget._isValidFacePicture(
      picture,
      sensorOrientation,
    );

    return valid
        ? _FacePictureValidationStatus.isValid
        : _FacePictureValidationStatus.notValid;
  }
}

/*
typedef _CandidatePicture = Duple<pkg_camera.CameraImage, pkg_camera.CameraDescription>;

enum _FacePictureValidationStatus {
  notValid,
  validating,
  isValid,
}
 */
