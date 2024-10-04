-- notRecognizedFromCameraByLesson
SELECT n.picture, n.embedding, s.registration, i.individualRegistration, i.name, i.surname from notRecognizedFromCamera as n LEFT JOIN lesson as l ON n.lessonId == l.auto_id LEFT JOIN class as c ON l.classId == c.auto_id left JOIN student as s ON n.nearestStudentRegistration == s.registration LEFT JOIN individual as i ON s.individualId = i.auto_id WHERE c.subjectCode == :subjectCode AND c.year == :year AND c.semester == :semester AND c.name == :name AND l.utcDateTime == :utcDateTime;

-- recognizedFromCameraByLesson
SELECT r.picture, r.embedding, s.registration, i.individualRegistration, i.name, i.surname from recognizedFromCamera as r LEFT JOIN lesson as l ON r.lessonId == l.auto_id LEFT JOIN class as c ON l.classId == c.auto_id left JOIN student as s ON r.nearestStudentRegistration == s.registration LEFT JOIN individual as i ON s.individualId = i.auto_id WHERE c.subjectCode == :subjectCode AND c.year == :year AND c.semester == :semester AND c.name == :name AND l.utcDateTime == :utcDateTime;

-- deferredRecognitionPool
SELECT d.picture, d.embedding from deferredRecognitionPool as d LEFT JOIN lesson as l ON d.lessonId == l.auto_id LEFT JOIN class as c ON l.classId == c.auto_id WHERE c.subjectCode == :subjectCode AND c.year == :year AND c.semester == :semester AND c.name == :name AND l.utcDateTime == :utcDateTime;

-- facePictureByStudentRegistration
SELECT f.picture, s.registration, i.individualRegistration, i.name, i.surname FROM facePicture as f LEFT JOIN individual as i on f.individualId = i.auto_id LEFT JOIN student as s ON i.auto_id == s.individualId WHERE s.registration = :regsitration;

-- facePictureByTeacherRegistration
SELECT f.picture, t.registration, i.individualRegistration, i.name, i.surname FROM facePicture as f LEFT JOIN individual as i on f.individualId = i.auto_id LEFT JOIN teacher as t ON i.auto_id == t.individualId WHERE t.registration = :regsitration;

-- facialDataByStudentRegistration
SELECT f.data, s.registration, i.individualRegistration, i.name, i.surname FROM facialData as f LEFT JOIN individual as i on f.individualId = i.auto_id LEFT JOIN student as s ON i.auto_id == s.individualId WHERE s.registration = :regsitration;

-- facialDataByTeacherRegistration
SELECT f.data, t.registration, i.individualRegistration, i.name, i.surname FROM facialData as f LEFT JOIN individual as i on f.individualId = i.auto_id LEFT JOIN teacher as t ON i.auto_id == t.individualId WHERE t.registration = :regsitration;

-- facePictureByStudentRegistration
SELECT f.picture, s.registration, i.individualRegistration, i.name, i.surname FROM facePicture as f LEFT JOIN individual as i on f.individualId = i.auto_id LEFT JOIN student as s ON i.auto_id == s.individualId WHERE s.registration = :regsitration;

-- facePictureByTeacherRegistration
SELECT f.picture, t.registration, i.individualRegistration, i.name, i.surname FROM facePicture as f LEFT JOIN individual as i on f.individualId = i.auto_id LEFT JOIN teacher as t ON i.auto_id == t.individualId WHERE t.registration = :regsitration;

-- individualByRegistration
SELECT i.individualRegistration, i.name, i.surname FROM individual AS i WHERE i.individualRegistration = :individualRegistration;

-- lessonBySubjectClass
WITH _teacher AS (SELECT t.registration, i.individualRegistration, i.name, i.surname FROM teacher as t INNER JOIN individual AS i ON t.individualId = i.auto_id) SELECT c.subjectCode, c.year, c.semester, c.name, c.teacherRegistration AS cTeacherRegistration, ct.individualRegistration AS cTeacherIndividualRegistration, ct.name AS cTeacherName, ct.surname AS cTeacherSurname , l.utcDateTime, l.teacherRegistration AS lTeacherRegistration, lt.individualRegistration AS lTeacherIndividualRegistration, lt.name AS lTeacherName, lt.surname AS lTeacherSurname FROM lesson as l INNER JOIN class AS c ON l.classId = c.auto_id INNER JOIN _teacher AS ct ON c.teacherRegistration = ct.registration INNER JOIN _teacher AS lt ON l.teacherRegistration = lt.registration WHERE c.subjectCode = :subjectCode AND c.year = :year AND c.semester = :semester AND c.name = :name;

-- studentByRegistration
SELECT s.registration, i.individualRegistration, i.name, i.surname FROM student as s Inner JOIN individual as i ON s.individualId = i.auto_id WHERE registration = :registration;

-- studentFromSubjectClass
WITH _teacher AS (SELECT t.registration, i.individualRegistration, i.name, i.surname FROM teacher as t INNER JOIN individual AS i ON t.individualId = i.auto_id), _student AS (SELECT s.registration, i.individualRegistration, i.name, i.surname FROM student as s INNER JOIN individual AS i ON s.individualId = i.auto_id) SELECT c.subjectCode, c.year, c.semester, c.name, c.teacherRegistration as cTeacherRegistration, t.individualRegistration as cTeacherIndividualRegistration, t.name as cTeacherName, t.surname as cTeacherSurname, e.studentRegistration as sRegistration, s.individualRegistration as sIndividualRegistration, s.name as sName, s.surname as sSurname FROM enrollment as e Inner JOIN class as c ON e.classId = c.auto_id INNER JOIN _teacher as t on c.teacherRegistration = t.registration inner JOIN _student as s oN e.studentRegistration = s.registration WHERE c.subjectCode = :subjectCode AND c.year = :year AND c.semester = :semester AND c.name = :name;

-- class
SELECT c.subjectCode, c.year, c.semester, c.name, c.teacherRegistration as cTeacherRegistration, i.individualRegistration as cTeacherIndividualRegistration, i.name as cTeacherName, i.surname as cTeacherSurname FROM class as c INNER JOIN teacher as t on c.teacherRegistration = t.registration inner JOIN individual as i oN t.individualId = i.auto_id WHERE c.subjectCode = :subjectCode AND c.year = :year AND c.semester = :semester AND c.name = :name;

-- attendance
WITH _teacher AS (SELECT t.registration, i.individualRegistration, i.name, i.surname FROM teacher as t INNER JOIN individual AS i ON t.individualId = i.auto_id), _student AS (SELECT s.registration, i.individualRegistration, i.name, i.surname FROM student as s INNER JOIN individual AS i ON s.individualId = i.auto_id) SELECT c.subjectCode, c.year, c.semester, c.name, c.teacherRegistration as cTeacherRegistration, t.individualRegistration as cTeacherIndividualRegistration, t.name as cTeacherName, t.surname as cTeacherSurname, a.studentRegistration as sRegistration, s.individualRegistration as sIndividualRegistration, s.name as sName, s.surname as sSurname, l.utcDateTime, l.teacherRegistration as lTeacherRegistration, lt.individualRegistration as lTeacherIndividualRegistration, lt.name as lTeacherName, lt.surname as lTeacherSurname FROM attendance as a INNER JOIN lesson as l ON a.lessonId = l.auto_id inner JOIN class as c ON l.classId = c.auto_id INNER JOIN _student as s ON a.studentRegistration = s.registration inner join _teacher as t on c.teacherRegistration = t.registration inner join _teacher as lt on l.teacherRegistration = lt.registration WHERE c.subjectcode = :subjectcode AND c.year = :year AND c.semester = :semester AND c.name = :name;

-- classBySubject
SELECT c.subjectCode, c.year, c.semester, c.name, c.teacherRegistration as cTeacherRegistration, i.individualRegistration as cTeacherIndividualRegistration, i.name as cTeacherName, i.surname as cTeacherSurname FROM class as c INNER JOIN teacher as t on c.teacherRegistration = t.registration inner JOIN individual as i oN t.individualId = i.auto_id WHERE c.subjectCode = :subjectCode;

-- subjectByCode
SELECT s.code, s.name FROM subject as s WHERE s.code = :code;

-- teacherByRegistration
SELECT t.registration, i.individualRegistration, i.name, i.surname FROM teacher as t Inner JOIN individual as i ON t.individualId = i.auto_id WHERE registration = :registration;

-- delete notRecognized
WITH _lesson AS (SELECT * FROM lesson as l INner JOIN class as c ON l.classId = c.auto_id WHERE c.subjectCode = :subjectCode ANd c.year = :year AND c.semester = :semester AND c.name = :name AND l.utcDateTime = :utcDateTime) DELETE FROM notRecognizedFromCamera AS n WHERE n.pictureMd5 = :pictureMd5 AND n.lessonId = (SELECT lessonId FROM _lesson);

-- delete recognizedFromCamera
WITH _lesson AS (SELECT * FROM lesson as l INner JOIN class as c ON l.classId = c.auto_id WHERE c.subjectCode = :subjectCode ANd c.year = :year AND c.semester = :semester AND c.name = :name AND l.utcDateTime = :utcDateTime) DELETE FROM recognizedFromCamera AS r WHERE r.pictureMd5 = :pictureMd5 AND r.lessonId = (SELECT lessonId FROM _lesson);

-- delete deferredRecognitionPool
WITH _lesson AS (SELECT * FROM lesson as l INner JOIN class as c ON l.classId = c.auto_id WHERE c.subjectCode = :subjectCode ANd c.year = :year AND c.semester = :semester AND c.name = :name AND l.utcDateTime = :utcDateTime) DELETE FROM deferredRecognitionPool AS d WHERE d.pictureMd5 = :pictureMd5 AND d.lessonId = (SELECT lessonId FROM _lesson);
