# Raciocinios

## TODO

- [x] fazer a modelagem de dados para o banco.
- [x] escrever a query correta para consultar os dados faciais dos alunos por turma.
- [x] alterar uso da classe _Structure2 to Duple.
- [x] armazenar embeddings para manipulacao futura.
- [x] criar tela para marcar a presença dos alunos.
- [X] corrigir manipulação do controlador da camera na tela que visualiza os frames da camera.
- [ ] remover duplicatas dentre as faces reconhecidas.

## Comportamento da aplicação

### Observações

- pricipal caso de uso da aplicação:

```dart
int useCaseRecognizeFaces({image}) {

  const minimumFaceConfidence = 97.0;
  const minimumResultConfidence = 97.0;

  final faces = detectFaces(image);

  for (var face in faces) {
    if (face.confidence * 100.0 < minimumFaceConfidence) {
      return -1;
    }

    final List<int> boundingBox = List.unmodifiable([0,0,0,0]);

    final faceImage = resizeImage(cropImage(image, boundingBox), 160, 160);

    final embedding = newEmbedding(faceImage);

    final result = searchFace();
    if (result.confidence * 100.0 < minimumResultConfidence) {
      return -1;
    }
  }
  return 0;
}
```

- as classes de nome `(.+)DAO` são compostas por Database

modelo original que extrai face features aceita multiplas entradas de uma vez:

- input  have shape=(n, 160, 160, 3) where (160, 160, 3) is face matrix
- output have shape=(n, 512) where (512) is face matrix

mesmo modelo no formato tflite:

- aceitando uma entrada:
  - input  have shape=(1, 160, 160, 3) where (160, 160, 3) is face matrix
  - output have shape=(512) where dim=(512) is feature array
- aceitando multiplas entradas de uma vez:
  - input  have shape=(1, n, 160, 160, 3) where (160, 160, 3) is face matrix
  - output have shape=(n, 512) where (512) is feature array

- lib/models/image_handler function \_biToUniDimCoord duplicated at lib/domain as mapBiToUniDimCoord

### MVP

pensando na ideia de usar mvp na aplicação

```dart
abstract class IModel {
  // {add|read|update|delete|transform}
}

abstract class IView {
  // {get|clear} something
}

abstract class IPresenter {
  // handle comunication between the user, views and models
}
```

### Fluxo: Marcar presenças

1. indicar turma
1. obter imagemns das faces
1. reconhecer faces no banco de dados
1. marcar as presenças

### Fluxo: Atualizar dados faciais

1. indicar turma
1. obter imagens das faces
1. reconhecer faces no banco de dados
1. atualizar banco de dados se faces disponiveis para um individuo estiverem muito diferentes

## API Web

### Desenvolvimento: adicionar capacidade ao cliente/servidor

1. escrever funcao em ClientApi
1. escrever rota em webApiRoutes.json
1. escrever funcao em ServerApi
1. escrever funcao em Database se necessário

## Banco de Dados

### Modelagem de dados

ver o arquivo [bdModelagemDados.md](./bdModelagemDados.md)
