# Aluno em Aula

Uma aplicação para contabilizar a presença de alunos em aula através do reconhecimento facial.

App desenvolvido como projeto final para o bacharelado em Ciência da Computação.

**Aluno**: Gabriel Borba

**Orientadora**: Daniela Trevisan

---

## Pontos de Entrada no código

Aplicativo: `.\lib\main.dart` (desenvolvido e testado em smarphone android)

    flutter run --release --flavor professor --device-id <android-device-bridge-partial-or-full-id-or-name> -t .\lib\main.dart

## Correções de bugs necessários

### Pacote: Excel

```dart
// bug encontrado no pacote excel v4.0.6, que impede a leitura do arquivo caso o certas condições sejam satisfeitas
// BUGFIX para pub.dev>excel-v.v.v>lib>src>parser>parse.dart>Parser>_parseStyles

// parece que alguns editores de planilhas estão escrevendo formatos numéricos integrados (builtin numeric formats) juntamente com os formatos personalizados
      document.findAllElements('numFmts').forEach((node1) {
        node1.findAllElements('numFmt').forEach((node) {
          final numFmtId = int.parse(node.getAttribute('numFmtId')!);
          final formatCode = node.getAttribute('formatCode')!;
          /* original
          if (numFmtId < 164) {
            throw Exception(
                'custom numFmtId starts at 164 but found a value of $numFmtId');
          }
          */
          // SECTION - correção usada: ignorar formatos com id menor que 164
          if (numFmtId >= 164) {
            _excel._numFormats
                .add(numFmtId, NumFormat.custom(formatCode: formatCode));
          }
          // !SECTION
        });
      });
```

---

<!-- TODO screen shots -->
