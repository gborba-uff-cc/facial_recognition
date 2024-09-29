-- individual
INSERT INTO individual (individualRegistration, name, surname) VALUES ('i1', 'i1', 'i1');
INSERT INTO individual (individualRegistration, name, surname) VALUES ('i2', 'i2', 'i2');
INSERT INTO individual (individualRegistration, name, surname) VALUES ('i3', 'i3', 'i3');
INSERT INTO individual (individualRegistration, name, surname) VALUES ('i4', 'i4', 'i4');
INSERT INTO individual (individualRegistration, name, surname) VALUES ('i5', 'i5', 'i5');
INSERT INTO individual (individualRegistration, name, surname) VALUES ('i6', 'i6', 'i6');
INSERT INTO individual (individualRegistration, name, surname) VALUES ('i7', 'i7', 'i7');

-- facialData
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i1') INSERT INTO facialData (data, individualId) SELECT x'1111', auto_id FROM _individual;
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i2') INSERT INTO facialData (data, individualId) SELECT x'1112', auto_id FROM _individual;
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i3') INSERT INTO facialData (data, individualId) SELECT x'1113', auto_id FROM _individual;

-- facePicture
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i4') INSERT INTO facePicture (picture, individualId) SELECT x'1111', auto_id FROM _individual;
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i5') INSERT INTO facePicture (picture, individualId) SELECT x'1112', auto_id FROM _individual;
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i6') INSERT INTO facePicture (picture, individualId) SELECT x'1113', auto_id FROM _individual;

-- student
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i1') INSERT INTO student (registration, individualId) SELECT 's1', auto_id FROM _individual;
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i2') INSERT INTO student (registration, individualId) SELECT 's2', auto_id FROM _individual;
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i3') INSERT INTO student (registration, individualId) SELECT 's3', auto_id FROM _individual;
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i4') INSERT INTO student (registration, individualId) SELECT 's4', auto_id FROM _individual;

-- teacher
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i5') INSERT INTO teacher (registration, individualId) SELECT 't1', auto_id FROM _individual;
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i6') INSERT INTO teacher (registration, individualId) SELECT 't2', auto_id FROM _individual;
WITH _individual AS (SELECT auto_id FROM individual WHERE individualRegistration = 'i7') INSERT INTO teacher (registration, individualId) SELECT 't3', auto_id FROM _individual;

-- subject
INSERT INTO subject (code, name) VALUES ('s1', 'sub1');
INSERT INTO subject (code, name) VALUES ('s2', 'sub2');
INSERT INTO subject (code, name) VALUES ('s3', 'sub3');

-- class
INSERT INTO class (subjectCode, year, semester, name, teacherRegistration) VALUES ('s1', 2024, 1, 'c1', 't1');
INSERT INTO class (subjectCode, year, semester, name, teacherRegistration) VALUES ('s1', 2024, 1, 'c2', 't2');
INSERT INTO class (subjectCode, year, semester, name, teacherRegistration) VALUES ('s2', 2024, 1, 'c1', 't3');
INSERT INTO class (subjectCode, year, semester, name, teacherRegistration) VALUES ('s3', 2024, 1, 'c1', 't3');

-- enrollment
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO enrollment (studentRegistration, classId) SELECT 's1', auto_id FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO enrollment (studentRegistration, classId) SELECT 's2', auto_id FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO enrollment (studentRegistration, classId) SELECT 's3', auto_id FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO enrollment (studentRegistration, classId) SELECT 's4', auto_id FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's2' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO enrollment (studentRegistration, classId) SELECT 's2', auto_id FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's2' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO enrollment (studentRegistration, classId) SELECT 's3', auto_id FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's3' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO enrollment (studentRegistration, classId) SELECT 's1', auto_id FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's3' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO enrollment (studentRegistration, classId) SELECT 's4', auto_id FROM _class;

-- lesson
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO lesson (classId, utcDateTime, teacherRegistration) SELECT auto_id, '202401010700', 't1' FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c2') INSERT INTO lesson (classId, utcDateTime, teacherRegistration) SELECT auto_id, '202401010900', 't2' FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO lesson (classId, utcDateTime, teacherRegistration) SELECT auto_id, '202401020700', 't1' FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's2' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO lesson (classId, utcDateTime, teacherRegistration) SELECT auto_id, '202401030700', 't2' FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's2' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO lesson (classId, utcDateTime, teacherRegistration) SELECT auto_id, '202401040700', 't3' FROM _class;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's3' AND year = 2024 AND semester = 1 AND name = 'c1') INSERT INTO lesson (classId, utcDateTime, teacherRegistration) SELECT auto_id, '202401030700', 't3' FROM _class;

-- notRecognized
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401010700') INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT X'face1aaa', 'face1_md5', X'face1bab', NULL, auto_id FROM _lesson;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401010700') INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT X'face2aab', 'face2_md5', X'face2bac', NULL, auto_id FROM _lesson;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401010700') INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT X'face3aac', 'face3_md5', X'face3bad', NULL, auto_id FROM _lesson;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401010700') INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT X'face4aad', 'face4_md5', X'face4bad', NULL, auto_id FROM _lesson;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's2' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401030700') INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT X'face5aae', 'face5_md5', X'face5bae', NULL, auto_id FROM _lesson;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's2' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401030700') INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT X'face6aaf', 'face6_md5', X'face6baf', NULL, auto_id FROM _lesson;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's3' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401030700') INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT X'face7aba', 'face7_md5', X'face7bba', NULL, auto_id FROM _lesson;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's3' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401030700') INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT X'face8abb', 'face8_md5', X'face8bbb', NULL, auto_id FROM _lesson;
WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401010700') INSERT INTO notRecognizedFromCamera (picture, pictureMd5, embedding, nearestStudentRegistration, lessonId) SELECT X'face9abc', 'face9_md5', X'face9bbc', 's1', auto_id FROM _lesson;

-- attendance
-- WITH _WITH _class AS (SELECT auto_id FROM class WHERE subjectCode = 's1' AND year = 2024 AND semester = 1 AND name = 'c1'), _lesson AS (SELECT auto_id FROM lesson WHERE classId = (SELECT auto_id FROM _class) AND utcDateTime = '202401010700') INSERT INTO attendance (studentRegistration, lessonId) SELECT '', auto_id FROM _lesson;
