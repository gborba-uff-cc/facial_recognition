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
call testBody, call postTest after it, show and return whether testBody succeded
*/
bool test(
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
  bool succeded = false;
  try {
    succeded = testBody();
  } catch (e) {
    succeded = false;
  }
  finally {
    String logMessage = '$testName... ';
    if (succeded) {
      logMessage += 'OK';
    }
    else {
      logMessage += 'FAIL';
    }
    stdout.writeln(logMessage);
  }
  if (postTest != null) {
    postTest();
  }
  return succeded;
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
  bool allTestsSucceded = true;

  // NOTE - from dbModelagemDados.md
  const tables = <String, List<String>>{
    'individual': ['auto_id', 'individualRegistration', 'name', 'surname'],
    'facialData': ['data', 'individualId'],
    'student': ['registration', 'individualId'],
    'teacher': ['registration', 'individualId'],
    'subject': ['code', 'name'],
    'class': ['auto_id', 'subjectCode', 'year', 'semester', 'name', 'teacherRegistration'],
    'lesson': ['auto_id', 'classId', 'utcDateTime', 'teacherRegistration'],
    'enrollment': ['studentRegistration', 'classId'],
    'attendance': ['studentRegistration', 'lessonId'],
  };
  final SqlStatementsLoader statementsLoader = SqlStatementsLoader(sqlStatementsResourcePath);
  pkg_sqlite3_open.open.overrideFor(pkg_sqlite3_open.OperatingSystem.windows, () => DynamicLibrary.open(databaseLibPath));
  final pkg_sqlite3.Database db = pkg_sqlite3.sqlite3.openInMemory();
  db.execute('PRAGMA foreign_keys = ON;');

  allTestsSucceded &= test(
    'creating database tables',
    () {
      pkg_sqlite3.ResultSet tableList = getTableList(db);
      final allPresent =
        // tableList-2 because of the builtin sqlite tables
        tables.keys.length == (tableList.length-2) &&
        tables.keys.every(
          (tableName) => tableList.any(
            (row) => row['name'] == tableName));
      return allPresent;
  },
  preTest: () => createTables(db, tables.keys.toList(), statementsLoader),
  );

  for (final entry in tables.entries) {
    final tableName = entry.key;
    final expectedColumns = entry.value;

    allTestsSucceded &= test(
      'table $tableName has expected columns',
      () {
        final pkg_sqlite3.ResultSet tableInfo = getTableInfo(db, tableName);
        final bool hasColumns =
          expectedColumns.length == tableInfo.length &&
          expectedColumns.every(
            (column) => tableInfo.any(
              (row) => row['name'] == column));
        return hasColumns;
      },
    );
  }

  allTestsSucceded &= test(
    'droping database tables',
    () {
      pkg_sqlite3.ResultSet tableList;

      tableList = getTableList(db);
      final beforeAllPresent =
        // tableList-2 because of the builtin sqlite tables
        tables.keys.length == tableList.length-2 &&
        tables.keys.every(
          (tableName) => tableList.any(
            (row) => row['name'] == tableName));

      dropTables(db, tables.keys.toList(), statementsLoader);

      tableList = getTableList(db);
      final afterAllAbsent =
        // tableList-2 because of the builtin sqlite tables
        tableList.length-2 == 0 &&
        tables.keys.every(
          (tableName) => !tableList.any(
            (row) => row['name'] == tableName));
      return beforeAllPresent && afterAllAbsent;
    },
  );

  db.dispose();

  String message = 'all tests succeded?';
  stdout.writeln('');
  stdout.writeln('-'*(message.length+5));
  if (allTestsSucceded) {
    stdout.writeln('$message Yes');
    exitCode = 0;
  }
  else {
    stdout.writeln('$message No');
    exitCode = 1;
  }
  stdout.writeln('='*(message.length+5));
  exit(exitCode);
}
