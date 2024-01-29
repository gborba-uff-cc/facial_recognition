import 'dart:convert';

import 'package:facial_recognition/json_converter_classes.dart';
import 'package:facial_recognition/models/face_features.dart';
import 'package:facial_recognition/models/user.dart';
import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:requests/requests.dart' as pkg_requests;

class ClientApi {
  final RoutesLoader routes;
  final String serverOrigin;
  final int serverPort;
  final UserJsonConverter _userConverter = UserJsonConverter();
  final FaceFeaturesJsonConverter _faceFeaturesConverter = FaceFeaturesJsonConverter();

  ClientApi(this.serverOrigin, this.serverPort, this.routes);

  String _finalUrl(List<String> keySequence) => '$serverOrigin${routes.getRoute(keySequence)}';

  String _finalUrlWithParametersReplaced(
    List<String> keySequence,
    List<String> parametersValues
  ) {
    return '$serverOrigin${routes.getRouteReplacingParameters(keySequence, parametersValues)}';
  }

  // throws error;
  Future<void> addUser(
    User user
  ) async {
    final response = await pkg_requests.Requests.post(
        _finalUrl(['server', 'user']),
        port: serverPort,
        json: _userConverter.toJsonObject(user));
    if (response.hasError) {
      throw Error();
    }
  }

  /// throws error;
  Future<List<User>> getAllUsers() async {
    final response = await pkg_requests.Requests.get(
      _finalUrl(['server', 'user']),
      port: serverPort
    );
    if (response.hasError) {
      throw Error();
    }
    return (json.decode(response.body) as List)
        .map<User>((jsonObject) => _userConverter.fromJsonObject(jsonObject))
        .toList();
  }

  /// throws error;
  Future<void> addFaceFeatures(
    FaceFeatures faceFeatures,
  ) async {
    final response = await pkg_requests.Requests.post(
        _finalUrl(['server', 'face_features']),
        port: serverPort,
        json: _faceFeaturesConverter.toJsonObject(faceFeatures));
    if (response.hasError) {
      throw Error();
    }
  }

  /// throws error;
  Future<List<FaceFeatures>> getFaceFeaturesByClass(
    int classId
  ) async {
    final response = await pkg_requests.Requests.get(
      _finalUrlWithParametersReplaced(['server', 'face_features_by_class'], ['$classId']),
      port: serverPort
    );
    if (response.hasError) {
      throw Error();
    }
    return (json.decode(response.body) as List)
        .map<FaceFeatures>((jsonObject) => _faceFeaturesConverter.fromJsonObject(jsonObject))
        .toList();
  }
}
