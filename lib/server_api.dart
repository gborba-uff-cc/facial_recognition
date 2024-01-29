import 'dart:convert';

import 'package:facial_recognition/dao_classes.dart';
import 'package:facial_recognition/json_converter_classes.dart';
import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:shelf_router/shelf_router.dart' as pkg_shelf_router;
import 'package:shelf/shelf.dart' as pkg_shelf;

class ServerApi {
  final RoutesLoader routes;
  final Map<String, String> _headerContentTypeJson = {'Content-Type': 'application/json'};
  final UserDAO userDao;
  final UserJsonConverter _userConverter = UserJsonConverter();
  final FaceFeaturesDao faceFeaturesDao;
  final FaceFeaturesJsonConverter _faceFeaturesConverter = FaceFeaturesJsonConverter();

  ServerApi(this.routes, this.userDao, this.faceFeaturesDao);

  pkg_shelf.Handler get handler {
    return pkg_shelf.Cascade()
      .add(router.call)
      .add(notFound)
      .handler;
  }

  pkg_shelf_router.Router get router {
      // route example: /nearest_feature/<turma|[A-Za-z0-9]+>/<feature|[A-Za-z0-9]+>
    return pkg_shelf_router.Router()
      ..post(routes.getRoute(['server', 'user']), addUser)
      ..get(routes.getRoute(['server', 'user']), getAllUsers)
      ..post(routes.getRoute(['server', 'face_features']), addFaceFeatures)
      ..get(routes.getRoute(['server', 'face_features_by_class']), getFaceFeaturesByClass)
  }

  pkg_shelf.Response notFound(pkg_shelf.Request request) {
    return pkg_shelf.Response.notFound('no matching URI');
  }

/* template
  pkg_shelf.Response _(pkg_shelf.Request request) {
    return pkg_shelf.Response.ok('');
  }
*/
  Future<pkg_shelf.Response> addUser(
    pkg_shelf.Request request
  ) async {
    try {
      final bodyJson = json.decode(await request.readAsString());
      userDao.save(_userConverter.fromJsonObject(bodyJson));
      return pkg_shelf.Response.ok(null);
    }
    catch (e, s) {
      projectLogger.severe('could not add an user', e, s);
      return pkg_shelf.Response.badRequest();
    }
  }

  pkg_shelf.Response getAllUsers(
    pkg_shelf.Request request
  ) {
    final resultJson = json.encode(userDao
        .getAll()
        .map((user) => _userConverter.toJsonObject(user))
        .toList(growable: false));
    return pkg_shelf.Response.ok(
      resultJson,
      headers: _headerContentTypeJson
    );
  }

  Future<pkg_shelf.Response> addFaceFeatures(
    final pkg_shelf.Request request
  ) async {
    try {
      final bodyJson = json.decode(await request.readAsString());
      faceFeaturesDao.save(_faceFeaturesConverter.fromJsonObject(bodyJson));
      return pkg_shelf.Response.ok(null);
    }
    catch (e, s) {
      projectLogger.severe('could not add a face feature', e, s);
      return pkg_shelf.Response.badRequest();
    }
  }

  pkg_shelf.Response getFaceFeaturesByClass(
    final pkg_shelf.Request request,
    final String classId
  ) {
    final classIdAsInt = int.tryParse(classId);
    if (classIdAsInt == null) {
      return pkg_shelf.Response.badRequest();
    }
    // FIXME - retrieve only those related to classId
    final resultJson = json.encode(faceFeaturesDao
        .getAll()
        .map((e) => _faceFeaturesConverter.toJsonObject(e))
        .toList(growable: false));
    return pkg_shelf.Response.ok(
      resultJson,
      headers: _headerContentTypeJson
    );
  }
}
