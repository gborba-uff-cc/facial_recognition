-- notRecognizedFromCameraByLesson
SELECT n.picture, n.embedding, s.registration, i.individualRegistration, i.name, i.surname
from notRecognizedFromCamera as n
LEFT JOIN lesson as l ON n.lessonId == l.auto_id
LEFT JOIN class as c ON l.classId == c.auto_id
left JOIN student as s ON n.nearestStudentRegistration == s.registration
LEFT JOIN individual as i ON s.individualId = i.auto_id
WHERE c.subjectCode == 's1' AND c.year == 2024 AND c.semester == 1 AND c.name == 'c1' AND l.utcDateTime == '202401010700';

-- recognizedFromCameraByLesson
SELECT r.picture, r.embedding, s.registration, i.individualRegistration, i.name, i.surname
from recognizedFromCamera as r
LEFT JOIN lesson as l ON r.lessonId == l.auto_id
LEFT JOIN class as c ON l.classId == c.auto_id
left JOIN student as s ON r.nearestStudentRegistration == s.registration
LEFT JOIN individual as i ON s.individualId = i.auto_id
WHERE c.subjectCode == 's1' AND c.year == 2024 AND c.semester == 1 AND c.name == 'c1' AND l.utcDateTime == '202401010700';

-- deferredRecognitionPool
SELECT d.picture, d.embedding 
from deferredRecognitionPool as d
LEFT JOIN lesson as l ON d.lessonId == l.auto_id
LEFT JOIN class as c ON l.classId == c.auto_id
WHERE c.subjectCode == 's1' AND c.year == 2024 AND c.semester == 1 AND c.name == 'c1' AND l.utcDateTime == '202401010700';

