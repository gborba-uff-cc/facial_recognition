import 'dart:developer';
import 'dart:io';

import 'package:logging/logging.dart';

/// Root logger for the project.
///
/// Level | Description
/// ------|------------
/// SHOUT   | extra debugging loudness
/// SEVERE  | serious failures
/// WARNING | potential problems
/// INFO    | informational messages
/// CONFIG  | static configuration messages
/// FINE    | tracing information
/// FINER   | fairly detailed tracing
/// FINEST  | highly detailed tracing
late final Logger projectLogger;

void initializeLogging({
  bool logToStdout = false,
  bool logToDevConsole = false,
  File? logToFile,
}) {
  /*
  All messages at or above the level are handled.
  | Value |  Level  | Usage |
  |-------|---------|-------|
  | 2000  | OFF     | Special key to **turn off** all logging |
  | 1200  | SHOUT   | Key for extra debugging loudness |
  | 1000  | SEVERE  | Key for serious failures |
  | 900   | WARNING | Key for potential problems |
  | 800   | INFO    | Key for informational messages |
  | 700   | CONFIG  | Key for static configuration messages |
  | 500   | FINE    | Key for tracing information |
  | 400   | FINER   | Key for fairly detailed tracing |
  | 300   | FINEST  | Key for highly detailed tracing |
  | 0     | ALL     | Special key to *turn on* logging for **all** levels |
  */
  const level = Level.ALL;

  final root = Logger.detached('ProjectLogger');
  root.level = level;

  root.onRecord.listen((logRecord) {
    final text = _formatRecord(logRecord);
    if (logToStdout) {
      stdout.writeln(text);
    }
    if (logToDevConsole) {
      log(
        logRecord.message,
        level: logRecord.level.value,
        name: logRecord.loggerName,
        time: logRecord.time,
        sequenceNumber: logRecord.sequenceNumber,
        zone: logRecord.zone,
        error: logRecord.error,
        stackTrace: logRecord.stackTrace,
      );
    }
    if (logToFile != null) {
      logToFile.writeAsString('$text\n',
          mode: FileMode.writeOnlyAppend, flush: true);
    }
    }
  );
  root.config('${root.fullName} logger for the app configured.');
  projectLogger = root;
}

String _formatRecord(LogRecord record) {
  final String header = '${record.time} ${record.loggerName} [${record.level.name}]:';
  final String error = record.error == null ? '' : 'Error raised: ${record.error}';
  final String stackTrace = record.stackTrace == null ? '' : 'Stack trace: ${record.stackTrace}';
  return '$header ${record.message} $error $stackTrace';
}
