// import 'dart:convert';
// import 'dart:io';

abstract class JsonLoader {
  // final String jsonFilepath;
  /*late*/ final _jsonRead/* = _loadJson()*/;

  // JsonLoader(this.jsonFilepath);
  JsonLoader(dynamic json): _jsonRead = json;

  // dynamic _loadJson() {
  //   return jsonDecode(File(jsonFilepath).readAsStringSync());
  // }

  /// NOTE - key sequence should be made of only [String] and [int]
  T _getValue<T>(List keySequence) {
    var value = _jsonRead;
    for (final key in keySequence) {
      value = value[key];
    }
    if (value is T) {
      return value;
    }
    else {
      throw TypeError();
    }
  }
}

class RoutesLoader extends JsonLoader {
  final _routeParam = RegExp(r'(<[^>]+>)');

  RoutesLoader(String filepath): super(filepath);

  String getRoute(final List<String> keySequence) {
    return super._getValue<String>(keySequence);
  }

  String replaceParameters(final String route, final List<String> values) {
    final parameters = _routeParam.allMatches(route).map((match) => match.group(1)!).toList(growable: false);
    String result = route;
    if (parameters.length != values.length) {
      throw ArgumentError('Mismatch on the number of parameters and values needed to be replaced in this route');
    }
    for (int i=0; i<parameters.length; i++) {
      result = result.replaceFirst(parameters[i], values[i]);
    }
    return result;
  }

  String getRouteReplacingParameters(
    final List<String> keySequence,
    final List<String> values
  ) {
    return replaceParameters(getRoute(keySequence), values);
  }
}

class SqlStatementsLoader extends JsonLoader{
  SqlStatementsLoader(json): super(json);

  String getStatement(final List<String> keySequence) {
    return super._getValue<String>(keySequence);
  }

  List<String> getStatements(final List<List<String>> keySequences) {
    return keySequences.map((keySequence) => getStatement(keySequence)).toList();
  }
}
