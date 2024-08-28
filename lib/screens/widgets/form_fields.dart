import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/models/use_case.dart';
import 'package:facial_recognition/screens/one_shot_camera_return.dart';
import 'package:facial_recognition/utils/project_logger.dart';
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

class StudentFieldRegistration extends _TextField {
  const StudentFieldRegistration({
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

class FacePictureField extends StatefulWidget {
  const FacePictureField({
    super.key,
    bool isOptional = true,
    required this.onSaved,
    Future<List<pkg_image.Image>> Function(pkg_camera.CameraImage cameiraImage, pkg_camera.CameraDescription cameraDescription)? faceDetector,
    Future<List<Duple<Uint8List, List<double>>>> Function(pkg_image.Image face,)? faceEmbedder,
    // Future<Uint8List> Function(pkg_image.Image)? jpgConverter,
  })  : _isOptional = isOptional,
        _faceDetector = faceDetector,
        _faceEmbedder = faceEmbedder;
        // _jpgConverter = jpgConverter;

  final bool _isOptional;
  final void Function(
    pkg_camera.CameraImage?,
    pkg_camera.CameraDescription?,
    FaceEmbedding?,
  )? onSaved;
  final Future<List<pkg_image.Image>> Function(
    pkg_camera.CameraImage cameiraImage,
    pkg_camera.CameraDescription cameraDescription,
  )? _faceDetector;
  final Future<List<Duple<Uint8List, List<double>>>> Function(
    pkg_image.Image face,
  )? _faceEmbedder;
  // final Future<Uint8List> Function(
  //   pkg_image.Image face,
  // )? _jpgConverter;

  @override
  State<FacePictureField> createState() => _FacePictureFieldState();
}

class _FacePictureFieldState extends State<FacePictureField> {
  final GlobalKey<FormFieldState<_CandidateFacePicture>> _facePictureFormField = GlobalKey();

  // _candidatePicture.embedding may have a value other than null because of the
  // validation and embedding extraction
  _CandidateFacePicture? _validatingPicture;

  @override
  Widget build(BuildContext context) {
    projectLogger.fine('_FacePictureFieldState.build');
    final saver = widget.onSaved;
    return FormField<_CandidateFacePicture>(
      key: _facePictureFormField,
      initialValue: const _CandidateFacePicture(
        status: _FacePictureValidationStatus.isValid,
        image: null,
        description: null,
        embedding: null,
        jpg: null,
      ),
      autovalidateMode: AutovalidateMode.disabled,
      // value.embedding is always null because the value is the image returned
      // from camera without embedding
      // REVIEW - move to camera the detection and extraction actions?
      validator: (final value) {
        projectLogger.fine('FormField<_CandidateFacePicture>.validator');
        final cameraImage = value?.image;
        final cameraDescription = value?.description;
        final validatingPicture = _validatingPicture;
        final status = value?.status;
        final isValidating =
            status == _FacePictureValidationStatus.validating;
        final isAnotherPicture = _areDifferrentPictures(
          validatingPicture?.image,
          cameraImage,
        );
        final isFirstValidation = _validatingPicture == null;

        // update and validate a candidate picture when:
        // 1. not validating a picture, 2. is another picture
        if ((!isValidating && isAnotherPicture) || isFirstValidation) {
          // change later the validation status
          final thisField = _facePictureFormField.currentState;
          if (cameraImage != null && cameraDescription == null) {
            projectLogger.severe(
              'CreateStudentScreen: missing camera description for the picture candidate',
            );
          }
          // new picture to validate
          else if (cameraImage != null) {
            // keep track of the image being validated
            final newValue = _CandidateFacePicture(
              status: _FacePictureValidationStatus.validating,
              image: value?.image,
              description: value?.description,
              embedding: value?.embedding,
              jpg: value?.jpg,
            );
            thisField?.didChange(newValue);
            _validatingPicture = newValue;
            if (thisField != null) {
              asyncValidation(thisField, value);
            }
          }
          else if (cameraImage == null) {
            _CandidateFacePicture newValue;
            if (widget._isOptional) {
              newValue = _CandidateFacePicture(
                status: _FacePictureValidationStatus.isValid,
                image: value?.image,
                description: value?.description,
                embedding: value?.embedding,
                jpg: value?.jpg,
              );
            }
            else {
              newValue = _CandidateFacePicture(
                status: _FacePictureValidationStatus.notValid,
                image: value?.image,
                description: value?.description,
                embedding: value?.embedding,
                jpg: value?.jpg,
              );
            }
            thisField?.didChange(newValue);
            _validatingPicture = newValue;
          }
        }
        // still validating or is the same image
        else {}

        // validation result
        switch (_validatingPicture?.status) {
          case _FacePictureValidationStatus.notValid:
            return 'Can not use as a face picture';
          case _FacePictureValidationStatus.validating:
            return 'Validating picture';
          case null:
          case _FacePictureValidationStatus.isValid:
            return null;
        }
      },
      onSaved: saver == null
          ? null
          : (value) {
              final cameraImage = value?.image;
              final candidatePicture = _validatingPicture?.image;
              final candidateCameraDescription = _validatingPicture?.description;
              final candidateEmbedding = _validatingPicture?.embedding;
              if (_areDifferrentPictures(candidatePicture, cameraImage)) {
                projectLogger.severe('tried to save a not validated picture');
              } else {
                saver(candidatePicture, candidateCameraDescription, candidateEmbedding);
              }
            },
      builder: (FormFieldState<_CandidateFacePicture> field) {
        final jpg = field.value?.jpg;
        final theme = Theme.of(field.context);
        final router = GoRouter.of(field.context);
        var inputDecoration = theme.inputDecorationTheme;
        inputDecoration = inputDecoration.copyWith(
          errorStyle: inputDecoration.errorStyle?.apply(
            color: theme.colorScheme.error,
          ),
        );
        final String thirdLineText = field.hasError
            ? (field.errorText ?? '')
            : widget._isOptional
                ? 'opcional'
                : '';
        final thirdLineStyle = field.hasError
            ? theme.inputDecorationTheme.errorStyle?.copyWith(color: theme.colorScheme.error)
            : null;
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
                          ? _CandidateFacePicture(
                              status: _FacePictureValidationStatus.notValid,
                              image: value.cameraImage,
                              description: value.cameraDescription,
                              embedding: null,
                              jpg: value.jpg,
                            )
                          : null,
                    );
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
                  thirdLineText,
                  style: thirdLineStyle,
                ),
              ],
            )
          ],
        );
      },
    );
  }

  bool _areDifferrentPictures(
    pkg_camera.CameraImage? imageA,
    pkg_camera.CameraImage? imageB,
  ) =>
      (imageA == null && imageB != null) ||
      (imageA != null && imageB == null) ||
      (imageA != null && imageB != null && !identical(imageA,imageB));

  /// detect if there is only one face on the form field image
  /// extracts the face embedding if there is a face
  /// returns if the camera image is a valid face picture
  Future<void> asyncValidation(
    FormFieldState<_CandidateFacePicture> thisField,
    _CandidateFacePicture? currentValue,
  ) async {
    final detector = widget._faceDetector;
    List<pkg_image.Image> detectedFaces = [];
    if (detector != null &&
        currentValue != null &&
        currentValue.image != null &&
        currentValue.description != null) {
      detectedFaces = await detector(currentValue.image!, currentValue.description!);
    } else {
      detectedFaces = [];
    }

    pkg_image.Image? detectedFace;
    _FacePictureValidationStatus newStatus;
    if (detectedFaces.length == 1) {
      newStatus = _FacePictureValidationStatus.isValid;
      detectedFace = detectedFaces.first;
    } else {
      newStatus = _FacePictureValidationStatus.notValid;
      detectedFace = null;
    }

    FaceEmbedding? newEmbedding;
    final embedder = widget._faceEmbedder;
    if (embedder != null && detectedFace != null) {
      newEmbedding = (await embedder(detectedFace)).first.value2;
    }

    // Uint8List? newJpg;
    // final jpgConverter = widget._jpgConverter;
    // if (jpgConverter != null && detectedFace != null) {
    //   newJpg = await jpgConverter(detectedFace);
    // }

    final newValue = _CandidateFacePicture(
      status: newStatus,
      image: currentValue?.image,
      description: currentValue?.description,
      embedding: newEmbedding,
      jpg: /*newJpg ??*/ currentValue?.jpg,
    );

    if (thisField.mounted) {
      thisField.didChange(newValue);
    }
    if (mounted) {
      setState(() {
        _validatingPicture = newValue;
      });
      thisField.validate();
    }

    return;
  }
}

class _CandidateFacePicture {
  const _CandidateFacePicture({
    required this.status,
    required this.image,
    required this.description,
    required this.embedding,
    required this.jpg,
  });

  final _FacePictureValidationStatus status;
  final pkg_camera.CameraImage? image;
  final pkg_camera.CameraDescription? description;
  final FaceEmbedding? embedding;
  final Uint8List? jpg;
}

enum _FacePictureValidationStatus {
  notValid,
  validating,
  isValid,
}
