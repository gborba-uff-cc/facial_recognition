-- ====================================
-- create

CREATE TABLE IF NOT EXISTS individual (auto_id INTEGER NOT NULL, individualRegistration TEXT NOT NULL, name TEXT NOT NULL, surname TEXT, UNIQUE (individualRegistration), PRIMARY KEY (auto_id)) STRICT;

CREATE TABLE IF NOT EXISTS facialData (auto_id INTEGER NOT NULL, data BLOB NOT NULL, individualId INTEGER NOT NULL, FOREIGN KEY (individualId) REFERENCES individual (auto_id), UNIQUE (data, individualId) , PRIMARY KEY (auto_id)) STRICT;

CREATE TABLE IF NOT EXISTS facePicture (auto_id INTEGER NOT NULL, picture BLOB NOT NULL, individualId INTEGER NOT NULL, FOREIGN KEY (individualId) REFERENCES individual (auto_id), UNIQUE (Picture, individualId) , PRIMARY KEY (auto_id)) STRICT;

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