import 'dart:convert';

import 'package:facial_recognition/database.dart';
import 'package:facial_recognition/models/face_features.dart';
import 'package:facial_recognition/models/user.dart';
import 'package:facial_recognition/utils/file_loaders.dart';

abstract class Dao<T> {
  void delete(T t);
  T? get(int id);
  List<T> getAll();
  void save(T t);
  void update(T t);
}

class UserDAO implements Dao<User> {
  late final String _sqlCreate = statementsLoader.getStatement(['users', 'manipulation', 'create']);
  late final String _sqlDelete = statementsLoader.getStatement(['users', 'manipulation', 'delete']);
  late final String _sqlRead = statementsLoader.getStatement(['users', 'manipulation', 'read']);
  late final String _sqlReadAll = statementsLoader.getStatement(['users', 'manipulation', 'read_all']);
  late final String _sqlUpdate = statementsLoader.getStatement(['users', 'manipulation', 'update']);
  final SqlStatementsLoader statementsLoader;
  final Database database;

  UserDAO(
    this.statementsLoader,
    this.database,
  );

  User _userFromRow(Map<String, dynamic> row) => User(
        id: row['id'],
        name: row['name'],
      );

  @override
  void delete(
    User user
  ) {
    database.execute(_sqlDelete, [user.id]);
  }

  @override
  User? get(
    int id
  ) {
    try {
      final result = database.select(_sqlRead, [id]).single;
      return _userFromRow(result);
    }
    on StateError {
      return null;
    }
  }

  @override
  List<User> getAll() {
    final results = database.select(_sqlReadAll);
    return results
        .map<User>((result) => _userFromRow(result))
        .toList();
  }

  @override
  void save(
    User user
  ) {
    if (user.id != null) {
      throw ArgumentError("Can't save a user which already has an id, try the update method");
    }
    database.execute(_sqlCreate, [user.name]);
  }

  @override
  void update(
    User user
  ) {
    if (user.id == null) {
      throw ArgumentError("Can't update a user with no id");
    }
    database.execute(_sqlUpdate);
  }
}

class FaceFeaturesDao implements Dao<FaceFeatures> {
  late final String _sqlCreate = statementsLoader.getStatement(['face_features', 'manipulation', 'create']);
  late final String _sqlDelete = statementsLoader.getStatement(['face_features', 'manipulation', 'delete']);
  late final String _sqlRead = statementsLoader.getStatement(['face_features', 'manipulation', 'read']);
  late final String _sqlReadAll = statementsLoader.getStatement(['face_features', 'manipulation', 'read_all']);
  late final String _sqlUpdate = statementsLoader.getStatement(['face_features', 'manipulation', 'update']);

  final SqlStatementsLoader statementsLoader;
  final Database database;

  FaceFeaturesDao(
    this.statementsLoader,
    this.database,
  );

  FaceFeatures _faceFeaturesFromRow(Map<String, dynamic> row) => FaceFeatures(
        id: row['id'],
        userId: row['user_id'],
        data: (row['data'] as List).cast<int>(),
      );

  @override
  void delete(
    FaceFeatures faceFeatures
  ) => database.execute(_sqlDelete, [faceFeatures.id]);

  @override
  FaceFeatures? get(
    int id
  ) {
    try {
      final result = database.select(_sqlRead, [id]).single;
      return _faceFeaturesFromRow(result);
    }
    on StateError {
      return null;
    }
  }

  @override
  List<FaceFeatures> getAll() {
    final results = database.select(_sqlReadAll);
    return results
        .map<Map<String, dynamic>>((result) =>
            Map.from(result)..update('data', (value) => json.decode(value)))
        .map<FaceFeatures>((editableRow) =>
            _faceFeaturesFromRow(editableRow))
        .toList();
  }

  @override
  void save(
    FaceFeatures faceFeatures
  ) {
    if (faceFeatures.id != null) {
      throw ArgumentError("Can't save a user which already has an id, try updating");
    }
    database.execute(_sqlCreate, [faceFeatures.userId, json.encode(faceFeatures.data)]);
  }

  @override
  void update(
    FaceFeatures faceFeatures
  ) {
    if (faceFeatures.id == null) {
      throw ArgumentError("Can't update a user with no id");
    }
    database.execute(_sqlUpdate, []);
  }
}
