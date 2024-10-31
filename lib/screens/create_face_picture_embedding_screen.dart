import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/screens/common/form_fields.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:facial_recognition/use_case/extract_face_picture_embedding.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateFacePictureEmbeddingForCamerawesome extends StatefulWidget {
  final CreateModels createModelsUseCase;
  final ExtractFacePictureEmbeddingForCamerawesome extractFacePictureEmbedding;
  const CreateFacePictureEmbeddingForCamerawesome({
    super.key,
    required this.createModelsUseCase,
    required this.extractFacePictureEmbedding,
  });

  @override
  State<CreateFacePictureEmbeddingForCamerawesome> createState() => _CreateFacePictureEmbeddingForCamerawesomeState();
}

class _CreateFacePictureEmbeddingForCamerawesomeState extends State<CreateFacePictureEmbeddingForCamerawesome> {
  /// faceSeen isselected embeddings are valid
  bool _isValid = false;

  ({
    JpegPictureBytes capturedImage,
    ExtractFacePictureEmbeddingAnalysisResult? detected,
  })? _imageSeen;
  JpegPictureBytes? _selectedForPicture;
  final Set<ExtractFacePictureEmbeddingAnalysisResult> _selectedForEmbedding = {};
  final TextEditingController _studentRegistration =
      TextEditingController.fromValue(null);
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void dispose() {
    _studentRegistration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final titleLargeStyle = Theme.of(context).textTheme.titleLarge;
    final List<Widget> screenWidgets = [
      // student registration
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('Aluno(a)', style: titleLargeStyle),
          ),
          Form(
            key: _formKey,
            child: StudentFieldRegistration(
              controller: _studentRegistration,
              labelText: 'Matrícula',
              helperText: 'Aluno inscrito',
              onChanged: (_) {
                if (context.mounted) {
                  setState(() {
                    _isValid = false;
                  });
                }
              },
            ),
          ),
        ],
      ),
      // captured image
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('Imagem', style: titleLargeStyle),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                final pkg_awesome.AnalysisImage? image = await router
                    .push<pkg_awesome.AnalysisImage?>('/take_photo');
                if (!context.mounted) {
                  return;
                }
                if (image == null) {
                  _showSnackbar(context, 'Nenhuma imagem capturada');
                }
                else {
                  final result = await widget.extractFacePictureEmbedding.analyse(image);
                  final inputImageJpg = result.inputImageJpg;
                  final facesDetected = result.detectedFaces;
                  if (facesDetected.isNotEmpty) {
                    facesDetected.sort((a, b) {
                      final rectA = a.rect;
                      final rectB = b.rect;
                      return (rectA.width * rectA.height)
                          .compareTo(rectB.width * rectB.height);
                    });
                    final biggestFace = facesDetected.last;
                    _imageSeen = (
                      capturedImage: inputImageJpg,
                      detected: biggestFace,
                    );
                  }
                  else {
                    _imageSeen = (
                      capturedImage: inputImageJpg,
                      detected: null,
                    );
                  }
                  if (context.mounted) {
                    setState(() {});
                  }
                }
              },
              child: Text('Capturar'),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100,
                minWidth: 100,
                maxHeight: 150,
                maxWidth: 150,
              ),
              child: _TappablePictureMiniature(
                onTap: null,
                onLongPress: null,
                jpg: _imageSeen?.capturedImage,
                noJpg: Icon(Icons.image_outlined),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _imageSeen?.capturedImage == null
                  ? null
                  : () {
                      if (mounted) {
                        setState(() {
                          _selectedForPicture = _imageSeen!.capturedImage;
                        });
                      }
                    },
              child: Text('Usar no perfil'),
            ),
          ),
          SizedBox(height: 8.0,),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _imageSeen?.detected == null
                  ? null
                  : () {
                      if (mounted) {
                        setState(() {
                          _selectedForEmbedding.add(_imageSeen!.detected!);
                        });
                      }
                    },
              child: Text('Usar como Embedding'),
            ),
          ),
        ],
      ),
      // student image
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('Imagem de perfil', style: titleLargeStyle),
          ),
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100,
                minWidth: 100,
                maxHeight: 150,
                maxWidth: 150,
              ),
              child: _TappablePictureMiniature(
                onTap: () => _showSnackbar(context, 'Toque e segure para descartar'),
                onLongPress: _selectedForPicture == null
                    ? null
                    : () {
                        if (mounted) {
                          setState(() {
                            _selectedForPicture = null;
                          });
                        }
                      },
                jpg: _selectedForPicture,
                noJpg: Icon(Icons.person),
              ),
            ),
          ),
        ],
      ),
      // embeddings
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('Embeddings', style: titleLargeStyle),
          ),
          if (_selectedForEmbedding.isNotEmpty)
            Center(
              child: Wrap(
                runSpacing: 8.0,
                spacing: 16.0,
                alignment: WrapAlignment.center,
                children: [
                  ..._selectedForEmbedding.map(
                    (item) {
                      final jpg = item.jpg;
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: 50,
                          minWidth: 50,
                          maxHeight: 70,
                          maxWidth: 70,
                        ),
                        child: _TappablePictureMiniature(
                          onTap: () => _showSnackbar(context, 'Toque e segure para descartar da lista'),
                          onLongPress: () {
                            if (mounted) {
                              setState(() {
                                _selectedForEmbedding.remove(item);
                              });
                            }
                          },
                          jpg: jpg,
                          noJpg: Icon(Icons.broken_image),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          else
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 50,
                minWidth: 50,
                maxHeight: 70,
                maxWidth: 70,
              ),
              child: SizedBox(height: double.infinity),
            ),
        ],
      ),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _isValid ? _onValid : _onInvalid,
          style: ButtonStyle(),
          child: Text(_isValid ? 'Confirmar' : 'Validar'),
        ),
      ),
    ];
    return AppDefaultScaffold(
      appBar: AppDefaultAppBar(title: 'Adicionar imagens'),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: AppDefaultMenuList(
          children: screenWidgets,
        ),
      ),
    );
  }

  void _onValid() {
    final formState = _formKey.currentState;
    if (formState == null) {
      return;
    }
    formState.save();
    final facePicture = _selectedForPicture;
    final studentRegistration = _studentRegistration.text;
    if (facePicture != null) {
      widget.createModelsUseCase.createStudentFacePicture(
        jpegFacePicture: facePicture,
        studentRegistration: studentRegistration,
      );
    }
    if (_selectedForEmbedding.isNotEmpty) {
      widget.createModelsUseCase.createStudentFacialData(
        embedding: _selectedForEmbedding
            .map(
              (e) => e.embedding,
            )
            .toList(),
        studentRegistration: studentRegistration,
      );
    }
    projectLogger.fine(_studentRegistration.text);

    // _studentRegistration.clear();
    formState.reset();
    _imageSeen = null;
    _selectedForPicture = null;
    _selectedForEmbedding.clear();
    _showSnackbar(context, 'Salvo');
    if (mounted) {
      setState(() {});
    }
  }

  void _onInvalid() {
    _isValid = _validate();
    if (mounted) {
      setState(() {});
    }
  }

  bool _validate() {
    final formState = _formKey.currentState;
    if (formState == null) {
      return false;
    }
    final isFormValid = formState.validate();
    final canSavePicture = isFormValid && _selectedForPicture != null;
    final canSaveEmbeddings = isFormValid && _selectedForEmbedding.isNotEmpty;
    if (!canSavePicture && !canSaveEmbeddings) {
      return false;
    }
    return true;
  }

  void _showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          elevation: 8,
        ),
      );
  }
}

class _TappablePictureMiniature extends StatelessWidget {
  const _TappablePictureMiniature({
    super.key,
    this.onTap,
    this.onLongPress,
    this.jpg,
    this.noJpg,
  }) : assert(!(jpg == null && noJpg == null));

  final void Function()? onTap;
  final void Function()? onLongPress;
  final JpegPictureBytes? jpg;
  final Widget? noJpg;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    child = jpg == null || (jpg?.isEmpty ?? true) ? noJpg : Image.memory(jpg!);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          child: child,
        ),
      ),
    );
  }
}