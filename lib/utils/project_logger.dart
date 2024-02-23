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
final Logger projectLogger = () {
  const level = Level.ALL;

  // All messages at or above the level are handled.
  // | Value |  Level  | Usage |
  // |-------|---------|-------|
  // | 2000  | OFF     | Special key to **turn off** all logging |
  // | 1200  | SHOUT   | Key for extra debugging loudness |
  // | 1000  | SEVERE  | Key for serious failures |
  // | 900   | WARNING | Key for potential problems |
  // | 800   | INFO    | Key for informational messages |
  // | 700   | CONFIG  | Key for static configuration messages |
  // | 500   | FINE    | Key for tracing information |
  // | 400   | FINER   | Key for fairly detailed tracing |
  // | 300   | FINEST  | Key for highly detailed tracing |
  // | 0     | ALL     | Special key to **turn on** logging for all levels |

  final root = Logger.detached('RootProjectLogger');
  root.level = level;
  root.onRecord.listen(_showOnStdout);
  root.config('Root logger for the app created and configured.');
  return root;
}();

void _showOnStdout(LogRecord log) {
  final String header = '${log.time} ${log.loggerName} [${log.level.name}]:';
  final String error = log.error == null ? '' : 'Error raised: ${log.error}';
  final String stackTrace = log.stackTrace == null ? '' : 'Stack trace: ${log.stackTrace}';
  return stdout.write('$header ${log.message} $error $stackTrace\n');
}
