// dart -DserverPort='' -Dsqlite3DllPath='' -DdatabasePath='' -DsqlStatementsResourcePath='' -DwebRoutesResourcePath='' .\bin\server_main.dart
/*
no servidor residem os:
bancos de dados
  das turmas
  dos alunos
  features
  imagens

usar no cliente 'requests'
*/
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:facial_recognition/dao_classes.dart';
import 'package:facial_recognition/database.dart';
import 'package:facial_recognition/server_api.dart';
import 'package:facial_recognition/utils/file_loaders.dart';
import 'package:shelf/shelf.dart' as pkg_shelf;
import 'package:shelf/shelf_io.dart' as pkg_shelf_io;

Future<int> main() async {
  const serverPort = int.fromEnvironment('serverPort');
  const sqlite3DllPath = String.fromEnvironment('sqlite3DllPath');
  const databasePath = String.fromEnvironment('databasePath');
  const sqlStatementsResourcePath = String.fromEnvironment('sqlStatementsResourcePath');
  const webRoutesResourcePath = String.fromEnvironment('webRoutesResourcePath');

  final stmtLoader = SqlStatementsLoader(sqlStatementsResourcePath);
  final database = Database(sqlite3DllPath, databasePath, stmtLoader);
  final serverRoutes = RoutesLoader(webRoutesResourcePath);
  final serverApi = ServerApi(
    serverRoutes,
    UserDAO(stmtLoader, database),
    FaceFeaturesDao(stmtLoader, database)
  );

  final server = await startFacialRecognitionServer(serverPort, serverApi);
  showServerInfo(server);

  final linesSubscription = listenNewLineFromStdin();
  linesSubscription.pause();
  final List<ServerCommand> serverCommands = [];
  serverCommands.addAll([
    ServerCommand('exit', 'Close this application', () async {
      await server.close();
      database.close();
      linesSubscription.cancel();
    }),
    ServerCommand('clear', 'Try clearing the terminal', () {
      if (stdout.supportsAnsiEscapes) {
        stdout.write('\x1B[2J\x1B[0;0H');
        showCommands(serverCommands);
      }
    }),
  ]);
  linesSubscription.onData((line) {
    for (var cmd in serverCommands) {
      if (line == cmd.trigger) {
        cmd.action();
      }
    }
  });
  linesSubscription.resume();

  showCommands(serverCommands);
  return 0;
}

Future<HttpServer> startFacialRecognitionServer(
  int port,
  ServerApi api
) {
  return pkg_shelf_io.serve(
    pkg_shelf.logRequests().addHandler(api.handler),
    InternetAddress.anyIPv4,
    port
  );
}

void showServerInfo(HttpServer server) {
  stdout.writeln('Serving at http://${server.address.host}:${server.port}');
}

StreamSubscription<String> listenNewLineFromStdin() {
  return stdin
    .transform(utf8.decoder)
    .transform(const LineSplitter())
    .listen(null);
}

class ServerCommand {
  final String trigger;
  final String help;
  final void Function() action;

  ServerCommand(this.trigger, this.help, this.action);
}

void showCommands(List<ServerCommand> commands) {
  stdout.writeln('Enter the following to perform an action:');
  for (var command in commands) {
    stdout.writeln('    ${command.trigger}: ${command.help}');
  }
  stdout.writeln('-'*stdout.terminalColumns);
}
