import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';

class AttendanceSummary {
  factory AttendanceSummary(
    IDomainRepository domainRepository,
    SubjectClass subjectClass,
  ) {
    final theAttendances = domainRepository
        .getSubjectClassAttendance([subjectClass])[subjectClass]!;
    final attendances = Map<Student, List<Attendance>>.unmodifiable(
      theAttendances.map<Student, List<Attendance>>(
        (key, value) => MapEntry<Student, List<Attendance>>(
          key,
          List<Attendance>.unmodifiable(
            value.toList()..sort(_sortAttendancesByDateTime),
          ),
        ),
      ),
    );
    final theLessons = domainRepository
          .getLessonFromSubjectClass([subjectClass])[subjectClass]!;
    final lessons = List<Lesson>.unmodifiable(
      theLessons.toList()..sort(_sortLessonsByDateTime),
    );
    final now = DateTime.now().toUtc();
    final pastLessons = List<Lesson>.unmodifiable(
      lessons.where(
        (element) => element.utcDateTime.compareTo(now) < 0,
      ),
    );
    final lastLesson = pastLessons.lastOrNull;
    final absentsLastLesson = List<Student>.unmodifiable(
      attendances.entries.where(
        (entry) {
          final entryValue = entry.value;
          if (lastLesson == null) {
            return false;
          }
          if (entryValue.isEmpty ||
              entryValue.last.lesson.utcDateTime
                      .compareTo(lastLesson.utcDateTime) <
                  0) {
            return true;
          }
          return false;
        },
      ).map(
        (entry) => entry.key,
      ),
    );
    final classStudents = domainRepository
        .getStudentFromSubjectClass([subjectClass])[subjectClass]!;
    final studentsFaceImage = Map<Student, FacePicture?>.unmodifiable(domainRepository.getFacePictureFromStudent(classStudents));

    return AttendanceSummary._private(
      domainRepository: domainRepository,
      subjectClass: subjectClass,
      attendances: attendances,
      lessons: lessons,
      now: now,
      pastLessons: pastLessons,
      lastLesson: lastLesson,
      absentsLastLesson: absentsLastLesson,
      studentsFaceImage: studentsFaceImage,
    );
  }

  AttendanceSummary._private({
    required IDomainRepository domainRepository,
    required SubjectClass subjectClass,
    required Map<Student, List<Attendance>> attendances,
    required List<Lesson> lessons,
    required DateTime now,
    required List<Lesson> pastLessons,
    required Lesson? lastLesson,
    required List<Student> absentsLastLesson,
    required Map<Student, FacePicture?> studentsFaceImage,
  })  :
        _domainRepository = domainRepository,
        _subjectClass = subjectClass,
        _attendances = attendances,
        _lessons = lessons,
        _now = now,
        _pastLessons = pastLessons,
        _lastLesson = lastLesson,
        _absentsLastLesson = absentsLastLesson,
        _studentsFaceImage = studentsFaceImage;

  final IDomainRepository _domainRepository;
  final SubjectClass _subjectClass;
  final Map<Student, List<Attendance>> _attendances;
  final List<Lesson> _lessons;
  final DateTime _now;
  final List<Lesson> _pastLessons;
  final Lesson? _lastLesson;
  final List<Student> _absentsLastLesson;
  final Map<Student, FacePicture?> _studentsFaceImage;

  int get nRegisteredLessons => _lessons.length;
  int get nPastLessons => _pastLessons.length;
  Lesson? get lastLesson => _lastLesson;
  int get nAbsentsLastLesson => _absentsLastLesson.length;
  Map<Student, List<Attendance>> get classAttendance => _attendances;
  Map<Student, FacePicture?> get studentsFaceImage => _studentsFaceImage;
  List<Lesson> get pastLessons => _pastLessons;
  int get nInsufficiencyAttendanceRatio => 0;

  static int _sortLessonsByDateTime(Lesson a, Lesson b) {
    return a.utcDateTime.compareTo(b.utcDateTime);
  }

  static int _sortAttendancesByDateTime(Attendance a, Attendance b) {
    return a.lesson.utcDateTime.compareTo(b.lesson.utcDateTime);
  }

  Map<Student, FacePicture?> getStudentFaceImage() {
    final students = _domainRepository
        .getStudentFromSubjectClass([_subjectClass])[_subjectClass]!;
    return _domainRepository.getFacePictureFromStudent(students);
  }

  Map<Student, List<Attendance>> getSubjectClassAttendance() {
    return _domainRepository
        .getSubjectClassAttendance([_subjectClass])[_subjectClass] ?? {};
  }

}
