import 'dart:ui';

import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:camerawesome/camerawesome_plugin.dart' as pkg_awesome;
import 'package:image/image.dart' as pkg_image;

class ExtractFacePictureEmbeddingAnalysisResult {
  final Rect rect;
  final JpegPictureBytes jpg;
  final FaceEmbedding embedding;

  ExtractFacePictureEmbeddingAnalysisResult({
    required this.rect,
    required this.jpg,
    required this.embedding,
  });
}

class ExtractFacePictureEmbeddingForCamerawesome {
  final IRecognitionPipeline<
    pkg_awesome.AnalysisImage,
    pkg_image.Image,
    JpegPictureBytes,
    Student,
    List<double>> recognitionPipeline;
  final ICameraImageHandler<
    pkg_awesome.AnalysisImage,
    pkg_image.Image,
    JpegPictureBytes> imageHandler;

  ExtractFacePictureEmbeddingForCamerawesome({
    required this.recognitionPipeline,
    required this.imageHandler,
  });

  Future<({
    JpegPictureBytes inputImageJpg,
    List<ExtractFacePictureEmbeddingAnalysisResult> detectedFaces,
  })> analyse(
    pkg_awesome.AnalysisImage input,
  ) async {
    List<Rect> rects = await recognitionPipeline.detectFace(input);
    final image = imageHandler.fromCameraImage(input);
    final imageJpg = imageHandler.toJpg(image);
    final faces = imageHandler.cropFromImage(image, rects.isNotEmpty ? [rects.last] : []);
    final jpgs = faces.map<JpegPictureBytes>((e) => imageHandler.toJpg(image)).toList();
    final embeddings = await recognitionPipeline.extractEmbedding(faces);

    final List<ExtractFacePictureEmbeddingAnalysisResult> result = rects.indexed.map((indexAndRect) {
      final index = indexAndRect.$1;
      final r = indexAndRect.$2;
      final j = jpgs[index];
      final e = embeddings[index];
      return ExtractFacePictureEmbeddingAnalysisResult(
        rect: r,
        jpg: j,
        embedding: e,
      );
    }).toList();
    return (inputImageJpg: imageJpg, detectedFaces: result);
  }
}
