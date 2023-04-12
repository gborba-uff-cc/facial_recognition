/// main use case for the app
// FIXME - provide the missing components
int useCaseRecognizeFaces({image}) {

  const minimumFaceConfidence = 97.0;
  const minimumResultConfidence = 97.0;

  final faces = detectFaces(image);

  for (var face in faces) {
    if (face.confidence * 100.0 < minimumFaceConfidence) {
      return -1;
    }

    final List<int> boundingBox = List.unmodifiable([0,0,0,0]);

    final faceImage = resizeImage(cropImage(image, boundingBox), 160, 160);

    final embedding = newEmbedding(faceImage);

    final result = searchFace();
    if (result.confidence * 100.0 < minimumResultConfidence) {
      return -1;
    }
  }
  return 0;
}

/// Detect any faces on [image].
List detectFaces(image) {  // FIXME - method signature.
  // TODO - .
  var a,b,c=(const [1,2,3]);
  a+b+c;
  return [];
}

/// Return a subarea from [image]
void cropImage(image, final List<int> boundingBox) {  // FIXME - method signature.
  // TODO - .
  return;
}

/// Resize the *image* to match [size]
void resizeImage(image, width, height) {  // FIXME - method signature.
  // TODO - .
  return;
}

/// Create recognition data for the only face on [image]
void newEmbedding(image) {  // FIXME - method signature.
  // TODO - .
  return;
}

/// Search for a matching person that corresponds to [embedding]
void searchFace(embedding) {  // FIXME - method signature.
  // TODO - .
  return;
}