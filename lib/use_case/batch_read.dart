import 'package:excel/excel.dart' as pkg_excel;

class BatchRead {
  BatchRead();
  String? _getCellValue(final pkg_excel.Data? cell) {
    if (cell == null) {
      return null;
    }
    final pkg_excel.CellValue? aValue = cell.value;
    return switch (aValue) {
      null => null,
      pkg_excel.TextCellValue() => aValue.value.text,
      pkg_excel.FormulaCellValue() => null,
      pkg_excel.IntCellValue() => '${aValue.value}',
      pkg_excel.BoolCellValue() => '${aValue.value}',
      pkg_excel.DoubleCellValue() => '${aValue.value}',
      pkg_excel.DateCellValue() => '${aValue.asDateTimeUtc()}',
      pkg_excel.TimeCellValue() => '${aValue.asDuration()}',
      pkg_excel.DateTimeCellValue() => '${aValue.asDateTimeUtc()}'
    };
  }

  DateTime? _getLocalDateTimeValue(final pkg_excel.Data? cell) {
    if (cell == null) {
      return null;
    }
    final pkg_excel.CellValue? aValue = cell.value;
    return switch (aValue) {
      null => null,
      pkg_excel.TextCellValue() => DateTime.tryParse(aValue.value.text ?? ''),
      pkg_excel.FormulaCellValue() => null,
      pkg_excel.IntCellValue() => null,
      pkg_excel.BoolCellValue() => null,
      pkg_excel.DoubleCellValue() => null,
      pkg_excel.DateCellValue() => null,
      pkg_excel.TimeCellValue() => null,
      pkg_excel.DateTimeCellValue() => aValue.asDateTimeLocal()
    };
  }

  List<({String registration, String individualRegistration, String name, String? surname})> readStudents({
    required final pkg_excel.Sheet sheet,
    final int skipRowsCount = 0,
  }) {
    if (sheet.maxColumns<2) {
      return const [];
    }
    final List<
        ({
          String registration,
          String individualRegistration,
          String name,
          String? surname
        })> result = [];
    for (int rowIndex=skipRowsCount; rowIndex<sheet.maxRows; rowIndex++) {
      final row = sheet.row(rowIndex);
      final registrationOnSheet = _getCellValue(row[0]);
      final nameOnSheet = _getCellValue(row[1]);
      if (registrationOnSheet == null ||
          nameOnSheet == null ||
          nameOnSheet.isEmpty) {
        continue;
      }
      result.add(
        (
          registration: registrationOnSheet,
          individualRegistration: registrationOnSheet,
          name: nameOnSheet,
          surname: null
        ),
      );
    }
    return result;
  }

  List<DateTime> readLessons({
    required final pkg_excel.Sheet sheet,
    final int skipRowsCount = 0,
  }) {
    if (sheet.maxColumns<2) {
      return const [];
    }
    final List<DateTime> result = [];
    for (int rowIndex=skipRowsCount; rowIndex<sheet.maxRows; rowIndex++) {
      final row = sheet.row(rowIndex);
      final localDateTime = _getLocalDateTimeValue(row[0]);
      final utcDateTime = localDateTime?.toUtc();
      if (utcDateTime == null) {
        continue;
      }
      result.add(utcDateTime);
    }
    return result;
  }
}
