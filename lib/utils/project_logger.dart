import 'package:logging/logging.dart';

/// Root logger for the project.
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
  root.onRecord.listen(_showOnConsole);
  root.config('Root logger for the app created and configured.');
  return root;
}();

// ignore: avoid_print
void _showOnConsole(LogRecord log) => print(
    '${log.time} ${log.loggerName} [${log.level.name}]: ${log.message}${log.error == null ? '' : ' With error: ${log.error}'}');
