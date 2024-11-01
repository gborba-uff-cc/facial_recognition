import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:excel/excel.dart' as pkg_excel;

class AttendanceSummary {
  /// [referenceDatetime] usually the current day being used as reference for
  /// the most recent lesson given, the number of lessons till
  /// [referenceDatetime], if null DateTime.now() is used
  factory AttendanceSummary({
    required IDomainRepository domainRepository,
    required SubjectClass subjectClass,
    required double minimumAttendanceRatio,
    DateTime? referenceDatetime,
  }) {
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
    final theStudents = domainRepository
        .getStudentFromSubjectClass([subjectClass])[subjectClass]!;
    final students = List<Student>.unmodifiable(
      theStudents.toList()..sort(
          (a, b) => a.individual.displayFullName
              .compareTo(b.individual.displayFullName),
      ),
    );
    final now = referenceDatetime ?? DateTime.now().toUtc();
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
    final studentsFaceImage = Map<Student, FacePicture?>.unmodifiable(
        domainRepository.getFacePictureFromStudent(theStudents));
    final Map<Student, int> studentsNumberFacialData = Map.unmodifiable(
      domainRepository
          .getFacialDataFromStudent(theStudents)
          .map<Student, int>((key, value) => MapEntry(key, value.length)),
    );

    return AttendanceSummary._private(
      domainRepository: domainRepository,
      subjectClass: subjectClass,
      attendances: attendances,
      lessons: lessons,
      students: students,
      pastLessons: pastLessons,
      lastLesson: lastLesson,
      absentsLastLesson: absentsLastLesson,
      studentsFaceImage: studentsFaceImage,
      minimumAttendanceRatio: minimumAttendanceRatio,
      studentsNumberFacialData: studentsNumberFacialData,
    );
  }

  AttendanceSummary._private({
    required IDomainRepository domainRepository,
    required SubjectClass subjectClass,
    required Map<Student, List<Attendance>> attendances,
    required List<Lesson> lessons,
    required List<Student> students,
    required List<Lesson> pastLessons,
    required Lesson? lastLesson,
    required List<Student> absentsLastLesson,
    required Map<Student, FacePicture?> studentsFaceImage,
    required double minimumAttendanceRatio,
    required studentsNumberFacialData,
  })  : _domainRepository = domainRepository,
        _subjectClass = subjectClass,
        _attendances = attendances,
        _lessons = lessons,
        _students = students,
        _pastLessons = pastLessons,
        _lastLesson = lastLesson,
        _absentsLastLesson = absentsLastLesson,
        _studentsFaceImage = studentsFaceImage,
        _minimumAttendaceRatio = minimumAttendanceRatio,
        _studentsNumberFacialData = studentsNumberFacialData;

  final IDomainRepository _domainRepository;
  final SubjectClass _subjectClass;
  final Map<Student, List<Attendance>> _attendances;
  final List<Lesson> _lessons;
  final List<Student> _students;
  final List<Lesson> _pastLessons;
  final Lesson? _lastLesson;
  final List<Student> _absentsLastLesson;
  final Map<Student, FacePicture?> _studentsFaceImage;
  final double _minimumAttendaceRatio;
  final Map<Student, int> _studentsNumberFacialData;

  int get nRegisteredLessons => _lessons.length;
  int get nPastLessons => _pastLessons.length;
  Lesson? get lastLesson => _lastLesson;
  int get nAbsentsLastLesson => _absentsLastLesson.length;
  Map<Student, List<Attendance>> get classAttendance => _attendances;
  Map<Student, FacePicture?> get studentsFaceImage => _studentsFaceImage;
  List<Lesson> get pastLessons => _pastLessons;
  double get minimumAttendaceRatio => _minimumAttendaceRatio;
  int get nInsufficiencyAttendanceRatio {
    return classAttendance.entries
        .where(
          (element) => element.value.length / nPastLessons < _minimumAttendaceRatio,
        )
        .length;
  }
  Map get studentsNumberFacialData => _studentsNumberFacialData;

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

  List<int> attendanceAsSpreadsheet() {
    final students = _students;
    final lessons = _lessons;
    final attendances = _attendances;
    if (students.isEmpty || lessons.isEmpty) {
      return const [];
    }
    final spreadsheet = pkg_excel.Excel.createExcel();
    final now = DateTime.now().toLocal();
    final oldSheetName = spreadsheet.getDefaultSheet();
    final newSheetName = '${now.day}${now.month}${now.year}${now.hour}${now.minute}';
    if (oldSheetName != null) {
      spreadsheet.rename(oldSheetName, newSheetName);
    }
    final sheet = spreadsheet[newSheetName];
    spreadsheet.setDefaultSheet(newSheetName);
    _populateAttendanceSheet(
      sheet: sheet,
      students: students,
      lessons: lessons,
      attendances: attendances,
    );
    return spreadsheet.save() ?? const [];
  }

  void _populateAttendanceSheet({
    required final pkg_excel.Sheet sheet,
    required final List<Student> students,
    required final List<Lesson> lessons,
    required final Map<Student, List<Attendance>> attendances,
  }) {
    pkg_excel.CellIndex cellIndex;
    pkg_excel.CellValue cellValue;
    final centerStyle = pkg_excel.CellStyle(
      horizontalAlign: pkg_excel.HorizontalAlign.Center,
    );
    final boldStyle = pkg_excel.CellStyle(
      bold: true,
    );

    // sheet content
    Map<DateTime,int> dateTimeColumn = {};
    int rowIndex;
    int columnIndex;
    // row A
    rowIndex = 0;
    columnIndex = 0;
    cellIndex = pkg_excel.CellIndex.indexByColumnRow(
      rowIndex: rowIndex,
      columnIndex: columnIndex,
    );
    cellValue = pkg_excel.TextCellValue('Nome');
    sheet.updateCell(cellIndex, cellValue, cellStyle: boldStyle);
    columnIndex = 1;
    cellIndex = pkg_excel.CellIndex.indexByColumnRow(
      rowIndex: rowIndex,
      columnIndex: columnIndex,
    );
    cellValue = pkg_excel.TextCellValue('Matrícula');
    sheet.updateCell(cellIndex, cellValue, cellStyle: boldStyle);
    columnIndex = 2;
    for (final l in lessons) {
      cellIndex = pkg_excel.CellIndex.indexByColumnRow(
        rowIndex: 0,
        columnIndex: columnIndex,
      );
      cellValue = pkg_excel.DateTimeCellValue.fromDateTime(l.utcDateTime.toLocal());
      sheet.updateCell(cellIndex, cellValue, cellStyle: boldStyle);
      dateTimeColumn[l.utcDateTime] = columnIndex;
      columnIndex += 1;
    }
    // row B onward
    rowIndex = 1;
    for (final s in students) {
      columnIndex = 0;
      cellIndex = pkg_excel.CellIndex.indexByColumnRow(
        rowIndex: rowIndex,
        columnIndex: columnIndex,
      );
      cellValue = pkg_excel.TextCellValue(s.individual.displayFullName);
      sheet.updateCell(cellIndex, cellValue);
      // ----------
      columnIndex = 1;
      cellIndex = pkg_excel.CellIndex.indexByColumnRow(
        rowIndex: rowIndex,
        columnIndex: columnIndex,
      );
      cellValue = pkg_excel.TextCellValue(s.registration);
      sheet.updateCell(cellIndex, cellValue);
      // ----------
      for (columnIndex=2; columnIndex<2+_lessons.length; columnIndex+=1) {
        cellIndex = pkg_excel.CellIndex.indexByColumnRow(
          rowIndex: rowIndex,
          columnIndex: columnIndex,
        );
        cellValue = pkg_excel.TextCellValue('n');
        sheet.updateCell(cellIndex, cellValue, cellStyle: centerStyle);
      }
      final studentAttendance = attendances[s];
      if (studentAttendance != null ) {
        for (final a in studentAttendance) {
          final aux = dateTimeColumn[a.lesson.utcDateTime];
          if (aux == null) {
            continue;
          }
          columnIndex = aux;
          cellIndex = pkg_excel.CellIndex.indexByColumnRow(
            rowIndex: rowIndex,
            columnIndex: columnIndex,
          );
          cellValue = pkg_excel.TextCellValue('P');
          sheet.updateCell(cellIndex, cellValue, cellStyle: centerStyle);
        }
      }
      // ----------
      rowIndex += 1;
    }
  }
}
