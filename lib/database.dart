import 'dart:ffi';

import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:sqlite3/sqlite3.dart' as pkg_sqlite3;
import 'package:sqlite3/open.dart' as pkg_sqlite3_open;

class Database{
  final String databaseLibPath;
  final String databaseFilepath;
  final SqlStatementsLoader statementsLoader;
  late final _database = _openSQLiteDatabase();

  Database(
    this.databaseLibPath,
    this.databaseFilepath,
    this.statementsLoader
  ) {
    _createTables();
  }

  void close() {
    _database.dispose();
  }

  pkg_sqlite3.Database _openSQLiteDatabase() {
    pkg_sqlite3_open.open.overrideFor(
      pkg_sqlite3_open.OperatingSystem.windows, _windowsSQLite3);
    final db = pkg_sqlite3.sqlite3.open(databaseFilepath);
    db.execute('PRAGMA foreign_keys = ON;');
    return db;
  }

  DynamicLibrary _windowsSQLite3() {
    return DynamicLibrary.open(databaseLibPath);
  }

  void _createTables() {
    final statements = statementsLoader.getStatements([
      ['users','definition','create'],
      ['face_features','definition','create'],
    ]);
    for (final statement in statements) {
      _database.execute(statement);
    }
  }

  void execute(String sql, [List<Object?> parameters = const []]) => _database.execute(sql, parameters);

  pkg_sqlite3.ResultSet select(String sql, [List<Object?> parameters = const []]) => _database.select(sql, parameters);
}
