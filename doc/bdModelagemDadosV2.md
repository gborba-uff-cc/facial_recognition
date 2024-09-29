# Modelagem de dados (Revisão 2)

<!-- TODO - formato correto, esperando correções -->

## Modelo conceitual

### Modelo Entidade Relacionamento

#### Relacionamentos identificados

- Aluno assite aula
- Professor leciona aula
- Aluno é matriculado em turma
- Professor é designado para turma
- Turma agenda aulas
- Turma estuda disciplina

#### Entidades e atributos identificadas

- Individuo
  - Cpf
  - Nome
  - Surname
- Dado facial
- Imagem da face
- Aluno
  - matrícula
- Professor
  - Matrícula
- Disciplina
  - Codigo
  - Nome
- Turma
  - Disciplina
  - Professor
  - Ano
  - Semestre
  - Nome
- Aula
  - turma
  - Professor
  - Data
  - Hora

### Diagrama Entidade Relacionamento

<!-- TODO diagrama retangulos e losangos -->

## Modelo lógico

### Esquema Lógico Relacional

- individual(auto_id «Int, NN, AI, PK», individualRegistration «Char[\*], NN, AK1», name «Char[\*], NN», surname: «Char[\*]»)

- facialData(auto_id «Int, NN, AI, PK», data «Blob, NN, AK1», individualId «Int, NN, FK, AK1»)
  - individualId referencia individual(auto_id)

- facePicture(auto_id «Int, NN, AI, PK», picture «Blob, NN, AK1», individualId «Int, NN, FK, AK1»)
  - individualId referencia individual(auto_id)

- student(registration «Char[\*], NN, PK», individualId «Int, NN, FK, AK1»)
  - individualId referencia individual(auto_id)

- teacher(registration «Char[\*], NN, PK», individualId «Int, NN, FK, AK1»)
  - individualId referencia individual(auto_id)

- subject(code «Char[\*], NN, PK», name «Char[\*], NN»)

- class(auto_id «Int, NN, AI, PK», subjectCode  «Char[\*], NN, FK, AK1», year «Int, NN, AK1», semester «Int, NN, AK1», name «Char[\*], NN, AK1», teacherRegistration «Char[\*], NN, FK»)
  - subjectCode referencia subject(code)
  - teacherRegistration referencia teacher(registration)

- lesson(auto_id «Int, NN, AI, PK», classId «Int, NN, FK, AK1», utcDateTime «Char[\*], NN, AK1», teacherRegistration «Char[\*], NN, FK»)
  - classId referencia class(auto_id)
  - teacherRegistration referencia teacher(registration)

- attendance(studentRegistration «Char[\*], NN, FK, PK», lessonId «Int, NN, FK, PK»)
  - studentRegistration referencia student(registration)
  - lessonId referencia lesson(auto_id)

- enrollment(studentRegistration «Char[\*], NN, FK, PK», classId «Int, NN, FK, PK»)
  - studentRegistration referencia student(registration)
  - classId referencia class(auto_id)

**Acrônimos usados**

- NN: Não nulo (not null)
- AI: Auto incremento (auto increment)
- PK: Chave primária (primary key)
- AKn: Chave alternativa n (alternate key)
- FK: Chave estrangeira (foreign key)

## Físico

### Data Definition Language para SQLite

```sql
-- written as for SQLite v3.38
CREATE TABLE IF NOT EXISTS individual (
  auto_id                INTEGER NOT NULL,
  individualRegistration TEXT    NOT NULL,
  name                   TEXT    NOT NULL,
  surname                TEXT,
  UNIQUE      (individualRegistration),
  PRIMARY KEY (auto_id)
) STRICT;

CREATE TABLE IF NOT EXISTS facialData (
  auto_id      INTEGER NOT NULL,
  data         BLOB    NOT NULL,
  individualId INTEGER NOT NULL,
  FOREIGN KEY (individualId) REFERENCES individual (auto_id),
  UNIQUE      (data, individualId),
  PRIMARY KEY (auto_id)
) STRICT;

CREATE TABLE IF NOT EXISTS facePicture (
  auto_id      INTEGER NOT NULL,
  picture      BLOB    NOT NULL,
  individualId INTEGER NOT NULL,
  FOREIGN KEY (individualId) REFERENCES individual (auto_id),
  UNIQUE      (picture, individualId),
  PRIMARY KEY (auto_id)
) STRICT;

CREATE TABLE IF NOT EXISTS student (
  registration TEXT    NOT NULL,
  individualId INTEGER NOT NULL,
  FOREIGN KEY (individualId) REFERENCES individual (auto_id),
  UNIQUE      (individualId),
  PRIMARY KEY (registration)
) STRICT;

CREATE TABLE IF NOT EXISTS teacher (
  registration TEXT    NOT NULL,
  individualId INTEGER NOT NULL,
  FOREIGN KEY (individualId) REFERENCES individual (auto_id),
  UNIQUE      (individualId),
  PRIMARY KEY (registration)
) STRICT;

CREATE TABLE IF NOT EXISTS subject (
  code TEXT NOT NULL,
  name TEXT NOT NULL,
  PRIMARY KEY (code)
) STRICT;

CREATE TABLE IF NOT EXISTS class (
  auto_id             INTEGER NOT NULL,
  subjectCode         TEXT    NOT NULL,
  year                INTEGER NOT NULL,
  semester            INTEGER NOT NULL,
  name                TEXT    NOT NULL,
  teacherRegistration TEXT    NOT NULL,
  FOREIGN KEY (subjectCode)         REFERENCES subject (code),
  FOREIGN KEY (teacherRegistration) REFERENCES professsor (registration),
  UNIQUE      (subjectCode, year, semester, name),
  PRIMARY KEY (auto_id)
) STRICT;

CREATE TABLE IF NOT EXISTS lesson (
  auto_id             INTEGER NOT NULL,
  classId             INTEGER NOT NULL,
  utcDateTime         TEXT    NOT NULL,
  teacherRegistration TEXT    NOT NULL,
  FOREIGN KEY (classId)             REFERENCES class (auto_id),
  FOREIGN KEY (teacherRegistration) REFERENCES teacher (registration),
  UNIQUE      (classId, utcDateTime),
  PRIMARY KEY (auto_id)
) STRICT;

CREATE TABLE IF NOT EXISTS enrollment (
  studentRegistration TEXT    NOT NULL,
  classId             INTEGER NOT NULL,
  FOREIGN KEY (studentRegistration) REFERENCES student (registration),
  FOREIGN KEY (classId)             REFERENCES class (auto_id),
  PRIMARY KEY (studentRegistration, classId)
) STRICT;

CREATE TABLE IF NOT EXISTS attendance (
  studentRegistration TEXT    NOT NULL,
  lessonId            INTEGER NOT NULL,
  FOREIGN KEY (studentRegistration) REFERENCES student (registration),
  FOREIGN KEY (lessonId)            REFERENCES lesson (auto_id),
  PRIMARY KEY (studentRegistration, lessonId)
) STRICT;
```

"Except for WITHOUT ROWID tables, all rows within SQLite tables have a 64-bit signed integer key that uniquely identifies the row within its table. This integer is usually called the "rowid". [...] If a rowid table has a primary key that consists of a single column and the declared type of that column is "INTEGER" in any mixture of upper and lower case, then the column becomes an alias for the rowid."
[SQLite CREATE TABLE](https://www.sqlite.org/lang_createtable.html#rowid)

"3. On an INSERT, if the ROWID or INTEGER PRIMARY KEY column is not explicitly given a value, then it will be filled automatically with an unused integer, usually one more than the largest ROWID currently in use. This is true regardless of whether or not the AUTOINCREMENT keyword is used."
[SQLite Autoincrement](https://www.sqlite.org/autoinc.html)

"4. If the AUTOINCREMENT keyword appears after INTEGER PRIMARY KEY, that changes the automatic ROWID assignment algorithm to prevent the reuse of ROWIDs over the lifetime of the database. In other words, the purpose of AUTOINCREMENT is to prevent the reuse of ROWIDs from previously deleted rows."
[SQLite Autoincrement](https://www.sqlite.org/autoinc.html)