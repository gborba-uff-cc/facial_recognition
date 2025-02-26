# Aluno em Aula

Uma aplicação para contabilizar a presença de alunos em aula através do reconhecimento facial.

![Tela inicial](./readme_images/landing.jpg)
![Tela do checkin individual](./readme_images/checkIn_individual.jpg)
![Tela de resumo das presenças](./readme_images/resumo.jpg)

App desenvolvido como projeto final para o bacharelado em Ciência da Computação.

**Aluno**: Gabriel Borba

**Orientadora**: Daniela Trevisan

## Obter o modelo de representação de faces

1. criar um ambiente virtual python:

```
py -3.11 -m venv --symlinks .python3_11_venv
```

2. ativar o ambiente virtual:

```
.\.python3_11_venv\Scripts\Activate.ps1
```

3. instalar e atualizar no ambiente virtual: pip, setuptools, wheel, tensorflow (versão 2.13.0), deepface (versão 0.0.79):

```
python -m pip install --upgrade pip setuptools wheel autopep8 tensorflow==2.13.0 deepface==0.0.79
```

4. baixar do pacote deepface e converter o modelo FaceNet-512:

```
python .\assets\generate_facenet512.py
```


## Pontos de entrada do código

Aplicativo: `.\lib\main.dart` (desenvolvido e testado em smarphone android)

Compilar e executar (com flutter instalado):
```
flutter run --release --flavor professor --device-id <android-device-bridge-partial-or-full-id-or-name> -t .\lib\main.dart
```
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
