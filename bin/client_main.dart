// dart -DserverOrigin='' -DserverPort='' -DwebRoutesResourcePath='' .\bin\client_main.dart

import 'package:facial_recognition/models/face_features.dart';
import 'package:facial_recognition/models/user.dart';
import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:facial_recognition/client_api.dart';
import 'package:facial_recognition/utils/project_logger.dart';

Future<void> main(List<String> args) async {
  const serverOrigin = String.fromEnvironment('serverOrigin');
  const serverPort = int.fromEnvironment('serverPort');
  const webRoutesResourcePath = String.fromEnvironment('webRoutesResourcePath');

  final serverRoutes = RoutesLoader(webRoutesResourcePath);
  final clientApi = ClientApi(serverOrigin, serverPort, serverRoutes);

  await clientApi.addUser(User(name: 'nameA'));
  await clientApi.addUser(User(name: 'nameB'));
  final resA = await clientApi.getAllUsers();
  await clientApi.addFaceFeatures(FaceFeatures(userId: 1, data: [1,3,5,2,4,6]));
  await clientApi.addFaceFeatures(FaceFeatures(userId: 2, data: [2,4,6,1,3,5]));
  final resB = await clientApi.getFaceFeaturesByClass(1);
  projectLogger.info('resA:\n'
      '${resA.map((user) => '${user.id},${user.name}').reduce((value, element) => '$value\n$element')}');
  projectLogger.info('resB:\n'
      '${resB.map((feceFeatures) => '${feceFeatures.id},${feceFeatures.userId},${feceFeatures.data}').reduce((value, element) => '$value\n$element')}');
}
