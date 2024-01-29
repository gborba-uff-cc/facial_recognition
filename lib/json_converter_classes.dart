import 'dart:convert';

import 'package:facial_recognition/models/face_features.dart';
import 'package:facial_recognition/models/user.dart';

abstract class ModelJsonConverter<T> {
  T fromJsonObject(Map<String, dynamic> json);
  T fromJsonString(String s);
  Map<String, dynamic> toJsonObject(T t);
  String toJsonString(T t);
}

class UserJsonConverter implements ModelJsonConverter<User> {
  @override
  User fromJsonObject(Map<String, dynamic> userJson) => User(
        id: userJson['id'],
        name: userJson['name'],
      );

  @override
  User fromJsonString(String userJson) {
    final Map<String, dynamic> decoded = json.decode(userJson);
    return fromJsonObject(decoded);
  }

  @override
  Map<String, dynamic> toJsonObject(User user) => {
        'id': user.id,
        'name': user.name,
      };

  @override
  String toJsonString(User user) => json.encode(toJsonObject(user));
}

class FaceFeaturesJsonConverter implements ModelJsonConverter<FaceFeatures> {
  @override
  FaceFeatures fromJsonObject(Map<String, dynamic> faceFeatureJson) =>
      FaceFeatures(
        id: faceFeatureJson['id'],
        userId: faceFeatureJson['user_id'],
        data: (faceFeatureJson['data'] as List).cast<int>(),
      );

  @override
  FaceFeatures fromJsonString(String faceFeaturesJson) {
    final Map<String, dynamic> decoded = json.decode(faceFeaturesJson);
    return fromJsonObject(decoded);
  }

  @override
  Map<String, dynamic> toJsonObject(FaceFeatures faceFeatures) => {
        'id': faceFeatures.id,
        'user_id': faceFeatures.userId,
        'data': faceFeatures.data,
      };

  @override
  String toJsonString(FaceFeatures faceFeatures) =>
      json.encode(toJsonObject(faceFeatures));
}
