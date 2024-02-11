// dart -DsqliteLibPath='' -DsqlStatementsResourcePath='' .\bin\server_main.dart

import 'dart:ffi';
import 'dart:io';

import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:sqlite3/sqlite3.dart' as pkg_sqlite3;
import 'package:sqlite3/open.dart' as pkg_sqlite3_open;


void beginTransaction(
  pkg_sqlite3.Database database
) => database.execute('BEGIN TRANSACTION;');  // REVIEW - to support transactions

void commitTransation(
  pkg_sqlite3.Database database
) => database.execute('COMMIT TRANSACTION;');  // REVIEW - to support transactions

void rollbackTransaction(
  pkg_sqlite3.Database database
) => database.execute('ROLLBACK TRANSACTION;');  // REVIEW - to support transactions


void createTables(
  final pkg_sqlite3.Database database,
  final List<String> tableNames,
  final SqlStatementsLoader sqlLoader,
) {
  final keySequences = tableNames.map((name) => [name, 'ddl', 'create']);
  final loadedSqls = sqlLoader.getStatements(keySequences.toList());
  beginTransaction(database);
  for (final String sql in loadedSqls) {
    database.execute(sql);
  }
  commitTransation(database);
}

void dropTables(
  final pkg_sqlite3.Database database,
  final List<String> tableNames,
  final SqlStatementsLoader sqlLoader,
) {
  final keySequences = tableNames.map((name) => [name, 'ddl', 'drop']);
  final loadedSqls = sqlLoader.getStatements(keySequences.toList());
  beginTransaction(database);
  for (final String sql in loadedSqls) {
    database.execute(sql);
  }
  commitTransation(database);
}
/*
call testBody, call postTest after it, show and return whether testBody failed
*/
void test(
  final String testName,
  final bool Function() testBody,
  {
    final void Function()? preTest,
    final void Function()? postTest
  }
) {
  if (preTest != null) {
    preTest();
  }
  bool fail = false;
  try {
    fail = testBody();
  } catch (e) {
    fail = true;
  }
  finally {
    String logMessage = '$testName... ';
    if (fail) {
      logMessage += 'FAIL';
    }
    else {
      logMessage += 'OK';
    }
    stdout.writeln(logMessage);
  }
  if (postTest != null) {
    postTest();
  }
}

pkg_sqlite3.ResultSet getTableList(
  pkg_sqlite3.Database database
) {
  return database.select('PRAGMA table_list;');
}

pkg_sqlite3.ResultSet getTableInfo(
  pkg_sqlite3.Database database,
  String tableName
) {
  // REVIEW - technically unsafe
  return database.select('PRAGMA table_info($tableName);');
}

void main() {
  const databaseLibPath = String.fromEnvironment('sqliteLibPath');
  const sqlStatementsResourcePath = String.fromEnvironment('sqlStatementsResourcePath');
  pkg_sqlite3_open.open.overrideFor(pkg_sqlite3_open.OperatingSystem.windows, () => DynamicLibrary.open(databaseLibPath));

  final SqlStatementsLoader statementsLoader = SqlStatementsLoader(sqlStatementsResourcePath);
  // NOTE - from dbModelagemDados.md
  const tables = <String, List<String>>{
    'individual': ['auto_id', 'individualRegistration', 'name'],
    'facialData': ['data', 'individualId'],
    'student': ['registration', 'individualId'],
    'teacher': ['registration', 'individualId'],
    'subject': ['code', 'name'],
    'class': ['auto_id', 'subjectCode', 'year', 'semester', 'name', 'teacherRegistration'],
    'lesson': ['auto_id', 'classId', 'utcDateTime', 'teacherRegistration'],
    'enrollment': ['studentRegistration', 'classId'],
    'attendance': ['studentRegistration', 'lessonId'],
  };
  final pkg_sqlite3.Database db = pkg_sqlite3.sqlite3.openInMemory();
  db.execute('PRAGMA foreign_keys = ON;');

  test('creating database tables', () {
    pkg_sqlite3.ResultSet tableList = getTableList(db);
    final allPresent = tables.keys.every(
      (tableName) => tableList.any(
        (row) => row['name'] == tableName));
    return !(allPresent);
  },
  preTest: () => createTables(db, tables.keys.toList(), statementsLoader));

  for (final entry in tables.entries) {
    final tableName = entry.key;
    final expectedColumns = entry.value;

    test('table $tableName has expected columns', () {
      final pkg_sqlite3.ResultSet tableInfo = getTableInfo(db, tableName);
      final bool hasColumns = expectedColumns.every(
        (column) => tableInfo.any(
          (row) => row['name'] == column));
      return !(hasColumns);
    });
  }

  test('droping database tables', () {
    pkg_sqlite3.ResultSet tableList;

    tableList = getTableList(db);
    final firstAllPresent = tables.keys.every(
      (tableName) => tableList.any(
        (row) => row['name'] == tableName));

    dropTables(db, tables.keys.toList(), statementsLoader);

    tableList = getTableList(db);
    final laterAllAbsent = tables.keys.every(
      (tableName) => !tableList.any(
        (row) => row['name'] == tableName));
    return !(firstAllPresent && laterAllAbsent);
  });

  db.dispose();
  exit(0);
}
