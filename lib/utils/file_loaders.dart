// import 'dart:convert';
// import 'dart:io';

abstract class JsonLoader {
  final _jsonRead;

  JsonLoader(dynamic json): _jsonRead = json;

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

class SqlStatementsLoader extends JsonLoader{
  SqlStatementsLoader(json): super(json);

  String getStatement(final List<String> keySequence) {
    return super._getValue<String>(keySequence);
  }

  List<String> getStatements(final List<List<String>> keySequences) {
    return keySequences.map((keySequence) => getStatement(keySequence)).toList();
  }
}
