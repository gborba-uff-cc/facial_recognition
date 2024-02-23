// dart -DsqliteLibPath='' -DsqlStatementsResourcePath='' .\bin\server_main.dart

import 'dart:ffi';
import 'dart:io';

import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:sqlite3/sqlite3.dart' as pkg_sqlite3;
import 'package:sqlite3/open.dart' as pkg_sqlite3_open;

import './core.dart';

void createTables(
  final pkg_sqlite3.Database database,
  final List<String> tableNames,
  final SqlStatementsLoader sqlLoader,
) {
  final sqlBeginTransaction = sqlLoader.getStatement(['tcl', 'begin']);
  final sqlCommitTransaction = sqlLoader.getStatement(['tcl', 'commit']);
  final keySequences = tableNames.map((name) => [name, 'ddl', 'create']);
  final loadedSqls = sqlLoader.getStatements(keySequences.toList());

  database.execute(sqlBeginTransaction);
  for (final String sql in loadedSqls) {
    database.execute(sql);
  }
  database.execute(sqlCommitTransaction);
}

void dropTables(
  final pkg_sqlite3.Database database,
  final List<String> tableNames,
  final SqlStatementsLoader sqlLoader,
) {
  final sqlBeginTransaction = sqlLoader.getStatement(['tcl', 'begin']);
  final sqlCommitTransaction = sqlLoader.getStatement(['tcl', 'commit']);
  final sqlRollbackTransaction = sqlLoader.getStatement(['tcl', 'rollback']);
  final keySequences = tableNames.map((name) => [name, 'ddl', 'drop']);
  final loadedSqls = sqlLoader.getStatements(keySequences.toList());

  try {
    // NOTE - transaction remains open until a successful commit or a rollback
    database.execute(sqlBeginTransaction);
    // REVIEW - update ddl to define foreign_keys as deferred?
    database.execute('PRAGMA defer_foreign_keys = on;');
    loadedSqls.forEach(database.execute);
    database.execute(sqlCommitTransaction);
  } catch (e) {
    database.execute(sqlRollbackTransaction);
    stdout.writeln(e);
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

void sqlPrepareBindExecute(
  pkg_sqlite3.Database db,
  String sqlStatement,
  List<Map<String, Object?>>params
) {
  final stmt = db.prepare(sqlStatement);

  try {
    params.forEach(stmt.executeMap);
  }
  catch (e) {
    stdout.writeln('${e.runtimeType} at sqlPrepareBindExecute(..., $sqlStatement, ...):\n$e');
    rethrow;
  }
  finally {
    stmt.dispose();
  }
}

pkg_sqlite3.ResultSet sqlPrepareBindSelect(
  pkg_sqlite3.Database db,
  String sqlStatement,
  Map<String, Object?>params
) {
  final stmt = db.prepare(sqlStatement);
  pkg_sqlite3.ResultSet result = pkg_sqlite3.ResultSet([], [], []);

  try {
    result = stmt.selectMap(params);
  }
  catch (e) {
    stdout.writeln('${e.runtimeType} at sqlPrepareBindSelect(..., $sqlStatement, ...):\n$e');
    rethrow;
  }
  finally {
    stmt.dispose();
  }

  return result;
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

  final sqlBeginTransaction = statementsLoader.getStatement(['tcl', 'begin']);
  final sqlCommitTransaction = statementsLoader.getStatement(['tcl', 'commit']);
  final sqlInsertIndividual = statementsLoader.getStatement(['individual', 'dml', 'insert', 'default']);
  final sqlInsertFacialData = statementsLoader.getStatement(['facialData','dml', 'insert']);
  final sqlInsertStudent = statementsLoader.getStatement(['student','dml', 'insert']);
  final sqlInsertTeacher = statementsLoader.getStatement(['teacher','dml', 'insert']);
  final sqlInsertSubject = statementsLoader.getStatement(['subject','dml', 'insert']);
  final sqlInsertClass = statementsLoader.getStatement(['class','dml', 'insert', 'default']);
  final sqlInsertLesson = statementsLoader.getStatement(['lesson','dml', 'insert', 'default']);
  final sqlInsertAttendance = statementsLoader.getStatement(['attendance','dml', 'insert']);
  final sqlInsertEnrollment = statementsLoader.getStatement(['enrollment','dml', 'insert']);

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

  allTestsSucceded &= test(
    'registration and facial data from all students within a class that has facial data',
    () {
      db.execute(sqlBeginTransaction);
      sqlPrepareBindExecute(db, sqlInsertIndividual, const [
        {':individualRegistration':'i0000000001',':name':'john',':surname':'doe'},
        {':individualRegistration':'i0000000002',':name':'john',':surname':'roe'},
        {':individualRegistration':'i0000000003',':name':'jane',':surname':'doe'},
        {':individualRegistration':'i0000000004',':name':'jane',':surname':'roe'},
        {':individualRegistration':'i0000000005',':name':'john',':surname':null},
        {':individualRegistration':'i0000000006',':name':'jane',':surname':null},
      ]);
      sqlPrepareBindExecute(db, sqlInsertFacialData, const [
        {':data':'fd01s02',':individualId':2},
        {':data':'fd01s03',':individualId':3},
        {':data':'fd02s03',':individualId':3},
        {':data':'fd03s03',':individualId':3},
        {':data':'fd01t02',':individualId':6},
      ]);
      sqlPrepareBindExecute(db, sqlInsertStudent, const [
        {':registration':'s00000001',':individualId':1},
        {':registration':'s00000002',':individualId':2},
        {':registration':'s00000003',':individualId':3},
        {':registration':'s00000004',':individualId':4},
      ]);
      sqlPrepareBindExecute(db, sqlInsertTeacher, const [
        {':registration':'t00000001',':individualId':5},
        {':registration':'t00000002',':individualId':6},
      ]);
      sqlPrepareBindExecute(db, sqlInsertSubject, const [
        {':code':'s00001',':name':'subjectA'},
        {':code':'s00002',':name':'subjectB'},
      ]);
      sqlPrepareBindExecute(db, sqlInsertClass, const [
        {':subjectCode':'s00001',':year':2024,':semester':1,':name':'classA',':teacherRegistration':'t00000001'},
        {':subjectCode':'s00002',':year':2024,':semester':1,':name':'classB',':teacherRegistration':'t00000002'},
      ]);
      sqlPrepareBindExecute(db, sqlInsertLesson, const [
        {':classId':1,':utcDateTime':"strftime('%F %R', 'now)",':teacherRegistration':'t00000001'},
        {':classId':2,':utcDateTime':"strftime('%F %R', 'now)",':teacherRegistration':'t00000002'},
      ]);
      sqlPrepareBindExecute(db, sqlInsertEnrollment, const [
        {':studentRegistration':'s00000001',':classId':1},
        {':studentRegistration':'s00000003',':classId':1},
        {':studentRegistration':'s00000004',':classId':1},
        {':studentRegistration':'s00000001',':classId':2},
        {':studentRegistration':'s00000002',':classId':2},
        {':studentRegistration':'s00000003',':classId':2},
        {':studentRegistration':'s00000004',':classId':2},
      ]);
      sqlPrepareBindExecute(db, sqlInsertAttendance, const [
        {':studentRegistration':'s00000001',':lessonId':1},
        {':studentRegistration':'s00000004',':lessonId':1},
        {':studentRegistration':'s00000001',':lessonId':2},
        {':studentRegistration':'s00000002',':lessonId':2},
      ]);
      db.execute(sqlCommitTransaction);

      final desiredResult = pkg_sqlite3.ResultSet(
        ['registration', 'data'],
        ['enrollment', 'class', 'student', 'facialData'],
        [
          ['s00000001',null],
          ['s00000003','fd01s03'],
          ['s00000003','fd02s03'],
          ['s00000003','fd03s03'],
          ['s00000004',null],
        ],
      );
      final query = statementsLoader.getStatement(['dql', 'studentRegistrationFacialDataFromClass']);
      final queryParameters = {':classSubjectCode':'s00001', ':classYear':2024, ':classSemester':1, ':className':'classA'};
      pkg_sqlite3.ResultSet result;
      result = sqlPrepareBindSelect(db, query, queryParameters);

      if (result.length != desiredResult.length) {
        return false;
      }
      for (int i=0; i<desiredResult.length; i++) {
        if (!equalMaps(result[i], desiredResult[i])) {
          return false;
        }
      }
      return true;
    },
    preTest: () => createTables(db, tables.keys.toList(), statementsLoader),
    postTest: () => dropTables(db, tables.keys.toList(), statementsLoader),
  );

  db.dispose();

  showTestssucceded(allTestsSucceded);
  exit(exitCode);
}
