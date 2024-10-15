# facial_recognition

Uma aplicação para contabilizar a presença de alunos em aula através do reconhecimento facial destes.

App desenvolvido como projeto final para o bacharelado em Ciência da Computação.

---

## Pontos de Entrada no código

Aplicativo: `.\lib\main.dart`

    # executar em smartphone android
    flutter run --release --flavor professor --device-id <android-device-bridge-partial-or-full-id-or-name> -t .\lib\main.dart

Servidor banco de dados: `.\bin\database_server_main.dart`

    # executar em um computador
    // dart -DserverPort='49152' -Dsqlite3DllPath='.\bin\sqlite3.dll' -DdatabasePath='<location-to-store-database>' -DsqlStatementsResourcePath='.\assets\sqlStatements.json' -DwebRoutesResourcePath='.\assets\webApiRoutes.json' .\bin\server_main.dart

Um cliente do banco de dados: `.\bin\database_client_main.dart`

    # executar em um computador
    dart -DserverOrigin='http://127.0.0.1' -DserverPort='8080' -DwebRoutesResourcePath='.\assets\webApiRoutes.json' .\bin\client_main.dart


## Correções de bugs necessários

### Pacote: Excel

```dart
// SECTION - BUGFIX on excel>parser>parser.dart>_parseStyles
// parece que alguns editores de planilhas estão escrevendo formatos numéricos integrados (builtin numeric formats) juntamente com os formatos personalizados
/*
          if (numFmtId < 164) {
            throw Exception(
                'custom numFmtId starts at 164 but found a value of $numFmtId');
          }
 */
// possivel correção é ignorar formatos com id menor que 164
          if (numFmtId >= 164) {
            _excel._numFormats
                .add(numFmtId, NumFormat.custom(formatCode: formatCode));
          }
// !SECTION - BUGFIX
```

---
Aluno Desenvolvedor: Gabriel Borba

Professor Orientador:
