import tensorflow
from deepface import DeepFace
import hashlib
import os

# get pretrained David Sandberg Facenet512 keras model from python deepface
model = DeepFace.build_model('Facenet512')

# show model information
model.summary(line_length=120)
print(f'{model.inputs=}\n{model.outputs=}')

# convert to tflite model
converter = tensorflow.lite.TFLiteConverter.from_keras_model(model)
tfliteModel = converter.convert()

# write tflite model on disk
tfliteModelHash = hashlib.blake2b(digest_size=6, usedforsecurity=False)
tfliteModelHash.update(tfliteModel)
outPath = os.path.normpath(
    os.path.join('.','assets',f'facenet512_{tfliteModelHash.hexdigest()}.tflite'))
with open(outPath, 'wb') as outFile:
    outFile.write(tfliteModel)
