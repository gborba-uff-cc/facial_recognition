# Raciocinios

## TODO

- [x] fazer a modelagem de dados para o banco.
- [ ] escrever a query correta para consultar os dados faciais dos alunos por turma.

## Comportamento da aplicação

### Observações

- as classes de nome `(.+)DAO` são compostas por Database

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
