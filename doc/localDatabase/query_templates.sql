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

