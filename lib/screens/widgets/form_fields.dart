import 'dart:typed_data';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/screens/one_shot_camera_return.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart' as pkg_camera;
import 'package:image/image.dart' as pkg_image;
import 'package:go_router/go_router.dart';

// TODO - move form fields here

abstract class _TextField extends StatelessWidget {
  const _TextField({
    super.key,
    required this.controller,
    required String labelText,
    required String helperText,
  }) : _labelText = labelText,
       _helperText = helperText;

  final TextEditingController controller;
  final String _labelText;
  final String _helperText;
}

class Student_ extends _TextField {
  Student_({
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class TeacherFieldRegistration extends _TextField {
  const TeacherFieldRegistration({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );
  }
}

class SubjectFieldCode extends _TextField {
  const SubjectFieldCode({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );
  }
}

class SubjectClassFieldYear extends _TextField {
  const SubjectClassFieldYear({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    const fYear = 2020;
    const lYear = 2040;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      keyboardType: TextInputType.number,
      maxLength: 4,
      validator: (input) {
        final valueClear = input?.trim();
        if (valueClear == null) {
          return 'Entre um ano';
        } else if (valueClear.characters.length < 4 ||
            valueClear.characters.length > 4) {
          return 'Deve ter 4 digitos';
        } else {
          final valueNum = int.tryParse(valueClear);
          if (valueNum == null) {
            return 'Entre apenas dígitos';
          } else if (valueNum < fYear || valueNum > lYear) {
            return '$fYear <= ano <= $lYear';
          }
        }
        return null;
      },
    );
  }
}

class SubjectClassFieldSemester extends _TextField {
  const SubjectClassFieldSemester({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      keyboardType: TextInputType.number,
      maxLength: 1,
      validator: (input) {
        final valueClear = input?.trim();
        if (valueClear == null || valueClear.characters.isEmpty) {
          return 'Entre um período';
        } else {
          final valueNum = int.tryParse(valueClear);
          if (valueNum == null) {
            return 'Entre apenas dígitos';
          } else if (valueNum < 1) {
            return 'Não válido';
          }
        }
        return null;
      },
    );
  }
}

class SubjectClassFieldName extends _TextField {
  const SubjectClassFieldName({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );
  }
}

class Lesson_ extends _TextField {
  Lesson_({
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class Enrollment_ extends _TextField {
  Enrollment_({
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class CameraImageField extends StatefulWidget {
  const CameraImageField({
    super.key,
    required this.validator,
    required this.onSaved,
  });

  final String? Function(
    FormFieldState<Duple<pkg_camera.CameraImage, pkg_camera.CameraDescription>>,
    pkg_camera.CameraImage?,
    pkg_camera.CameraDescription?,
  )? validator;
  final void Function(
    pkg_camera.CameraImage?,
    pkg_camera.CameraDescription?,
  )? onSaved;

  @override
  State<CameraImageField> createState() => _CameraImageFieldState();
}

class _CameraImageFieldState extends State<CameraImageField> {
  Uint8List? _jpg;
  final GlobalKey<FormFieldState<_CameraImageFieldType>> _cameraImageFormField = GlobalKey();

  _CandidatePicture _candidateImage;
  _FacePictureValidationStatus _facePictureValidationStatus =
      _FacePictureValidationStatus.isValid;

  @override
  Widget build(BuildContext context) {
    final validator = widget.validator;
    final saver = widget.onSaved;
    final field = _cameraImageFormField.currentState;
    return FormField<_CameraImageFieldType>(
      key: _cameraImageFormField,
      initialValue: null,
      autovalidateMode: AutovalidateMode.disabled,
      // validator: validator != null && field != null
      //     ? (value) => validator(field, value?.value1, value?.value2)
      //     : null,
      validator: (final value) {
        final cameraImage = value?.value1;
        final cameraDescription = value?.value2;
        final oldCandidate = _candidateImage;
        final oldStatus = _facePictureValidationStatus;
        final isValidating =
            oldStatus == _FacePictureValidationStatus.validating;
        final isAnotherImage = (oldCandidate == null && cameraImage != null) ||
            (oldCandidate != null && cameraImage == null) ||
            (oldCandidate != null &&
                cameraImage != null &&
                oldCandidate.value1 != cameraImage);

        projectLogger.fine('validating: $isValidating; isAnotherImage: $isAnotherImage');
        // update and validate a candidate picture when:
        // 1. not validating another picture, 2. is another picture
        if (!isValidating && isAnotherImage) {
          if (cameraDescription == null) {
            projectLogger.severe(
              'CreateStudentScreen: missing cameraCamera description for the picture candidate',
            );
          } else if (cameraImage != null) {
            _candidateImage = _CandidatePicture(
              cameraImage,
              cameraDescription,
            );
            _facePictureValidationStatus =
                _FacePictureValidationStatus.validating;
            // change later the validation status
            _validateFacePicture(
              cameraImage,
              cameraDescription.sensorOrientation,
            ).then((status) {
              if (field.mounted) {
                field.setState(() {
                  projectLogger.fine('validation status updated');
                  _facePictureValidationStatus = status;
                });
              }
              // validate after updating status
              field.validate();
            });
          } else {
            _candidateImage = null;
            _facePictureValidationStatus = _FacePictureValidationStatus.isValid;
          }
        }
        // still validating or is the same image
        else {}

        // validation result
        switch (_facePictureValidationStatus) {
          case _FacePictureValidationStatus.notValid:
            return 'Can not use as a face picture';
          case _FacePictureValidationStatus.validating:
            return 'Validating picture';
          case _FacePictureValidationStatus.isValid:
            return 'Valid';
        }
      },
      onSaved:
          saver != null ? (value) => saver(value?.value1, value?.value2) : null,
      builder: (FormFieldState<_CameraImageFieldType> field) {
        final jpg = _jpg;
        final theme = Theme.of(field.context);
        final router = GoRouter.of(field.context);
        var inputDecoration = theme.inputDecorationTheme;
        inputDecoration = inputDecoration.copyWith(
          errorStyle: inputDecoration.errorStyle?.apply(
            color: theme.colorScheme.error,
          ),
        );
        return Column(
          children: [
            Row(
              children: [
                Text(
                  'Foto da Face',
                  style: field.hasError
                      ? theme.inputDecorationTheme.labelStyle
                          ?.copyWith(color: theme.colorScheme.error)
                      : theme.inputDecorationTheme.labelStyle,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () => router
                      .push<
                          OneShotCameraReturn<
                              pkg_camera.CameraImage,
                              pkg_camera.CameraDescription,
                              Uint8List>>('/take_photo')
                      .then((value) {
                    field.didChange(
                      value != null
                          ? _CameraImageFieldType(
                              value.cameraImage,
                              value.cameraDescription,
                            )
                          : null,
                    );
                    if (mounted) {
                      setState(() => _jpg = value?.jpg);
                    }
                  }),
                  child: Container(
                    foregroundDecoration: BoxDecoration(
                      border: Border.all(
                        color: theme.primaryColor,
                        width: 2.0,
                      ),
                    ),
                    width: 180,
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: jpg == null
                            ? const Icon(Icons.add)
                            : Image.memory(jpg),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  field.hasError ? field.errorText! : '',
                  style: field.hasError
                      ? theme.inputDecorationTheme.errorStyle
                          ?.copyWith(color: theme.colorScheme.error)
                      : theme.inputDecorationTheme.errorStyle,
                ),
              ],
            )
          ],
        );
      },
    );
  }
}

typedef _CameraImageFieldType = Duple<pkg_camera.CameraImage, pkg_camera.CameraDescription>;

typedef _CandidatePicture = Duple<pkg_camera.CameraImage, pkg_camera.CameraDescription>;

enum _FacePictureValidationStatus {
  notValid,
  validating,
  isValid,
}
