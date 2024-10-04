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

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) INSERT INTO attendance (studentRegistration, lessonId) SELECT :studentRegistration, auto_id FROM _lesson;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT :picture, :pictureMd5, :embedding, :nearestStudentRegistration, auto_id FROM _lesson;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) INSERT INTO recognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT :picture, :pictureMd5, :embedding, :nearestStudentRegistration, auto_id FROM _lesson;

WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = :subjectCode AND year = :year AND semester = :semester AND name = :name), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = :utcDateTime) INSERT INTO deferredRecognitionPool (picture, pictureMd5, embedding, lessonId) SELECT :picture, :pictureMd5, :embedding, auto_id FROM _lesson;