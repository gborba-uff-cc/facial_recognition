import 'dart:ui';

import 'package:facial_recognition/interfaces.dart';

class FacialDataHandlerForCameraAwesome<CI, I, J, L, V>
    implements IFacialDataHandler<CI, J, V> {
  final IRecognitionPipeline<CI, I, J, L, V> recognitionPipeline;
  final ICameraImageHandler<CI, I, J> imageHandler;

  FacialDataHandlerForCameraAwesome({
    required this.recognitionPipeline,
    required this.imageHandler,
  });

  /// return the rect, face jpeg picture and embedding for the single face on
  /// the [input], return null if [input] camera image has more than 1 face
  @override
  Future<({Rect rect, J face, V embedding})?> processImage(CI input) async {
    final rects = recognitionPipeline.detectFace(input);
    if ((await rects).length != 1) {
      return Future.value(null);
    }
    final faces = recognitionPipeline.cropFaces(input: input, rects: await rects);
    final embeddings = recognitionPipeline.extractEmbedding(await faces);

    final jpg = imageHandler.toJpg((await faces).single);
    final rect = (await rects).single;
    final embedding = (await embeddings).single;
    return Future.value(
      (rect: rect, face: jpg, embedding: embedding),
    );
  }
}
