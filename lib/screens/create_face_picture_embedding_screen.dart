import 'dart:typed_data';

import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/screens/common/form_fields.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:facial_recognition/use_case/extract_face_picture_embedding.dart';
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
  })? _faceSeen;
  JpegPictureBytes? _selectedForPicture;
  final List<ExtractFacePictureEmbeddingAnalysisResult> _selectedForEmbedding = [];
  final TextEditingController _studentRegistration =
      TextEditingController.fromValue(null);
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final titleLargeStyle = Theme.of(context).textTheme.titleLarge;
    final List<Widget> screenWidgets = [
      Column(
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
                    _faceSeen = (
                      capturedImage: inputImageJpg,
                      detected: biggestFace,
                    );
                  }
                  else {
                    _faceSeen = (
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
                jpg: _faceSeen?.detected?.jpg,
                noJpg: Icon(Icons.image_outlined),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _faceSeen == null || _faceSeen?.detected == null
                  ? null
                  : () {
                      _selectedForPicture = _faceSeen!.capturedImage;
                    },
              child: Text('Usar no perfil'),
            ),
          ),
          SizedBox(height: 8.0,),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _faceSeen == null || _faceSeen?.detected == null
                  ? null
                  : () {
                      _selectedForEmbedding.add(_faceSeen!.detected!);
                    },
              child: Text('Usar como Embedding'),
            ),
          ),
        ],
      ),
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
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text('Embeddings', style: titleLargeStyle),
          ),
          if (_selectedForEmbedding.isNotEmpty)
            Wrap(
              children: [
                ..._selectedForEmbedding.indexed.map(
                  (indexAndItem) {
                    final index = indexAndItem.$1;
                    final jpg = indexAndItem.$2.jpg;
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
                              _selectedForEmbedding.removeAt(index);
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
          onPressed: _isValid ? _onInvalid : _onValid,
          style: ButtonStyle(),
          child: Text(_isValid ? 'Confirmar' : 'Validar'),
        ),
      ),
    ];
    return AppDefaultScaffold(
      appBar: AppDefaultAppBar(title: 'Adicionar imagens'),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Flexible(
          child: AppDefaultMenuList(
            children: screenWidgets,
          ),
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
    //
    _showSnackbar(context, 'Salvo');
    formState.reset();
  }

  void _onInvalid() {
    _isValid = _validate();
    if (mounted) {
      setState(() {});
    }
  }

  // TODO
  bool _validate() {
    final formState = _formKey.currentState;
    if (formState == null) {
      return false;
    }
    return formState.validate();
  }

  void _showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          elevation: 4,
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