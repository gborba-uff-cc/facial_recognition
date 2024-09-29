-- ====================================
-- create

CREATE TABLE IF NOT EXISTS individual (auto_id INTEGER NOT NULL, individualRegistration TEXT NOT NULL, name TEXT NOT NULL, surname TEXT, UNIQUE (individualRegistration), PRIMARY KEY (auto_id)) STRICT;

CREATE TABLE IF NOT EXISTS facialData (auto_id INTEGER NOT NULL, data BLOB NOT NULL, individualId INTEGER NOT NULL, FOREIGN KEY (individualId) REFERENCES individual (auto_id), UNIQUE (data, individualId) , PRIMARY KEY (auto_id)) STRICT;

CREATE TABLE IF NOT EXISTS facePicture (auto_id INTEGER NOT NULL, Picture BLOB NOT NULL, individualId INTEGER NOT NULL, FOREIGN KEY (individualId) REFERENCES individual (auto_id), UNIQUE (Picture, individualId) , PRIMARY KEY (auto_id)) STRICT;

CREATE TABLE IF NOT EXISTS student (registration TEXT NOT NULL, individualId INTEGER NOT NULL, FOREIGN KEY (individualId) REFERENCES individual (auto_id), UNIQUE (individualId), PRIMARY KEY (registration)) STRICT;

CREATE TABLE IF NOT EXISTS teacher (registration TEXT NOT NULL, individualId INTEGER NOT NULL, FOREIGN KEY (individualId) REFERENCES individual (auto_id), UNIQUE (individualId), PRIMARY KEY (registration)) STRICT;

CREATE TABLE IF NOT EXISTS subject (code TEXT NOT NULL, name TEXT NOT NULL, PRIMARY KEY (code)) STRICT;

CREATE TABLE IF NOT EXISTS class (auto_id INTEGER NOT NULL, subjectCode TEXT NOT NULL, year INTEGER NOT NULL, semester INTEGER NOT NULL, name TEXT NOT NULL, teacherRegistration TEXT NOT NULL, FOREIGN KEY (subjectCode) REFERENCES subject (code), FOREIGN KEY (teacherRegistration) REFERENCES teacher (registration), UNIQUE (subjectCode, year, semester, name), PRIMARY KEY (auto_id)) STRICT;

CREATE TABLE IF NOT EXISTS lesson (auto_id INTEGER NOT NULL, classId INTEGER NOT NULL, utcDateTime TEXT NOT NULL, teacherRegistration TEXT NOT NULL, FOREIGN KEY (classId) REFERENCES class (auto_id), FOREIGN KEY (teacherRegistration) REFERENCES teacher (registration), UNIQUE (classId, utcDateTime), PRIMARY KEY (auto_id)) STRICT;

CREATE TABLE IF NOT EXISTS enrollment (studentRegistration TEXT NOT NULL, classId INTEGER NOT NULL, FOREIGN KEY (studentRegistration) REFERENCES student (registration), FOREIGN KEY (classId) REFERENCES class (auto_id), PRIMARY KEY (studentRegistration, classId)) STRICT;

CREATE TABLE IF NOT EXISTS attendance (studentRegistration TEXT NOT NULL, lessonId INTEGER NOT NULL, FOREIGN KEY (studentRegistration) REFERENCES student (registration), FOREIGN KEY (lessonId) REFERENCES lesson (auto_id), PRIMARY KEY (studentRegistration, lessonId)) STRICT;

CREATE TABLE IF NOT EXISTS notRecognizedFromCamera(picture BLOB NOT NULL, pictureMd5 TEXT NOT NULL, embedding BLOB NOT NULL, nearestStudentRegistration TEXT, lessonId INTEGER NOT NULL, FOREIGN KEY (nearestStudentRegistration) REFERENCES student (registration), FOREIGN KEY (lessonId) REFERENCES lesson (auto_id), PRIMARY KEY (pictureMd5)) STRICT;

CREATE TABLE IF NOT EXISTS recognizedFromCamera(picture BLOB NOT NULL, pictureMd5 TEXT NOT NULL, embedding BLOB NOT NULL, nearestStudentRegistration TEXT, lessonId INTEGER NOT NULL, FOREIGN KEY (nearestStudentRegistration) REFERENCES student (registration), FOREIGN KEY (lessonId) REFERENCES lesson (auto_id), PRIMARY KEY (pictureMd5)) STRICT;

CREATE TABLE IF NOT EXISTS deferredRecognitionPool(picture BLOB NOT NULL, pictureMd5 TEXT NOT NULL, embedding BLOB NOT NULL, lessonId INTEGER NOT NULL, FOREIGN KEY (lessonId) REFERENCES lesson (auto_id), PRIMARY KEY (pictureMd5)) STRICT;

-- =================================
-- insert

INSERT INTO individual (individualRegistration, name, surname) VALUES (:individualRegistration, :name, :surname);

WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = :individualRegistration) INSERT INTO facialData (data, individualId) SELECT :data, auto_id FROM _individual;

WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = :individualRegistration) INSERT INTO facePicture (picture, individualId) SELECT :picture, auto_id FROM _individual;

WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = :individualRegistration) INSERT INTO student (registration, individualId) SELECT :registration, auto_id FROM _individual;

WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = :individualRegistration) INSERT INTO teacher (registration, individualId) SELECT :registration, auto_id FROM _individual;

INSERT INTO subject (code, name) VALUES (:code, :name);

INSERT INTO class (subjectCode, year, semester, name, teacherRegistration) VALUES (:subjectCode, :year, :semester, :name, :teacherRegistration);

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name) INSERT INTO lesson (classId, utcDateTime, teacherRegistration) SELECT auto_id, :utcDateTime, :teacherRegistration FROM _class;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name) INSERT INTO enrollment (studentRegistration, classId) SELECT :studentRegistration, auto_id FROM _class;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name) INSERT INTO enrollment (studentRegistration, classId) SELECT :studentRegistration, auto_id FROM _class;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) INSERT INTO attendance (studentRegistration, lessonId) SELECT :studentRegistration, auto_id FROM _lesson;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT :picture, :pictureMd5, :embedding, :nearestStudentRegistration, auto_id FROM _lesson;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT :picture, :pictureMd5, :embedding, :nearestStudentRegistration, auto_id FROM _lesson;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) INSERT INTO recognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT :picture, :pictureMd5, :embedding, :nearestStudentRegistration, auto_id FROM _lesson;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) INSERT INTO deferredRecognitionPool (picture, pictureMd5, embedding, lessonId) SELECT :picture, :pictureMd5, :embedding, auto_id FROM _lesson;

-- =============================================
SELECT code, name FROM subject;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semestre = :semestre AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) SELECT Picture, pictureMd5, embedding, nearestStudentRegistration FROM notRecognizedFromCamera WHERE lessonId = (SELECT auto_id FROM _lesson);
