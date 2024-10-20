import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/screens/common/card_single_action.dart';
import 'package:facial_recognition/screens/common/excel_picker_button.dart';
import 'package:facial_recognition/screens/common/select_information_return.dart';
import 'package:facial_recognition/screens/common/selector.dart';
import 'package:facial_recognition/screens/common/spreadsheet_selected_subject_class.dart';
import 'package:facial_recognition/use_case/spreadsheet_read.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:excel/excel.dart' as pkg_excel;
import 'package:cross_file/cross_file.dart' as pkg_xfile;
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateAttendanceFromSpreadsheetScreen extends StatefulWidget {
  const CreateAttendanceFromSpreadsheetScreen({
    super.key,
    required this.spreadsheetReadUseCase,
    required this.createModelsUseCase,
  });

  final SpreadsheetRead spreadsheetReadUseCase;
  final CreateModels createModelsUseCase;

  @override
  State<CreateAttendanceFromSpreadsheetScreen> createState() => _CreateAttendanceFromSpreadsheetScreenState();
}

class _CreateAttendanceFromSpreadsheetScreenState extends State<CreateAttendanceFromSpreadsheetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  pkg_xfile.XFile? _pickedFile;
  pkg_excel.Excel? _spreadsheet;
  final List<String> _spreadsheetSheetsName = [];
  final List<String> _selectableSheetsName = [];
  String? _selectedSheetName;

  Subject? _selectedSubject;
  SubjectClass? _selectedSubjectClass;

  @override
  Widget build(BuildContext context) {
    final pickedFile = _pickedFile;
    final List<Widget> items = [
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SpreadsheetSelectedSubjectClass(
            subject: _selectedSubject?.name ?? '',
            subjectClass: _selectedSubjectClass?.name ?? '',
            action: () async {
              final aux = await GoRouter.of(context)
                  .push<SelectInformationReturn>(
                      '/select_information?hideLesson=true');
              setState(() {
                if (aux == null) {
                  projectLogger.severe(
                      "a value weren't returned from /select_information");
                }
                _selectedSubject = aux?.subject;
                _selectedSubjectClass = aux?.subjectClass;
              });
            },
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Arquivo selecionado',
            maxLines: 1,
            style: Theme.of(context).textTheme.titleLarge,
            overflow: TextOverflow.fade,
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: pickedFile == null
                ? Text(
                    'Nenhum arquivo selecionado',
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                : Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(
                          Icons.table_chart,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        pickedFile.name,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.only(),
            child: ExcelPickerButton(
              onPick: _handleXlsxFilePicked,
            ),
          ),
        ],
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planilha',
            maxLines: 1,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Selector<String>(
            options: _selectableSheetsName,
            selectedOption: _selectedSheetName,
            toWidget: (item) =>
                Text(item == null ? 'selecione a planilha' : 'Planilha: $item'),
            onChanged: (item) {
              if (mounted) {
                setState(() {
                  _selectedSheetName = item;
                });
              }
            },
          ),
        ],
      ),
    ];
    return AppDefaultMenuScaffold(
      appBar: AppDefaultAppBar(title: 'Planilha com presenças'),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: AppDefaultMenuList(children: items),
          ),
          Padding(
            padding: EdgeInsets.only(top: 8.0, bottom: 24.0,),
            child: AppDefaultButton(
              onTap: _spreadsheet == null || _selectedSheetName == null || _selectedSubjectClass == null
                  ? null
                  : () {
                    final s = _spreadsheet;
                    final n = _selectedSheetName;
                    final c = _selectedSubjectClass;
                      if (s == null || n == null || c == null) {
                        return;
                      }
                      _processSheet(
                        sheet: s[n],
                        subjectClass: c,
                      );
                      ScaffoldMessenger.of(context)
                          .showSnackBar(SnackBar(content: Text('Feito')));
                    },
              child: Align(
                alignment: Alignment.center,
                child: const Text('Confirmar', maxLines: 1),),
            ),
          ),
        ],
      ),
    );
  }

  void _handleXlsxFilePicked(pkg_xfile.XFile? xFile) async {
    pkg_excel.Excel? spreadsheet;
    final List<String> sheets = [];

    if (xFile != null) {
      final bytes = await xFile.readAsBytes();
      spreadsheet = pkg_excel.Excel.decodeBytes(bytes);
      sheets.addAll(spreadsheet.sheets.keys);
    }
    if (mounted) {
      setState(() {
        if (xFile == null || xFile.path != _pickedFile?.path) {
          _selectedSheetName = null;
        }
        _pickedFile = xFile;
        _spreadsheet = spreadsheet;
        _spreadsheetSheetsName.clear();
        _spreadsheetSheetsName.addAll(sheets);
        _selectableSheetsName.clear();
        _selectableSheetsName.addAll(_spreadsheetSheetsName);
      });
    }
  }
  void _processSheet({
    required pkg_excel.Sheet sheet,
    SubjectClass? subjectClass,
  }) {
    final students = widget.spreadsheetReadUseCase.readStudents(sheet: sheet);
    widget.createModelsUseCase.createStudents(students);
    if (subjectClass != null) {
      widget.createModelsUseCase.createEnrollments(
        registrationOfStudent: students.map((e) => e.registration,).toList(),
        year: '${subjectClass.year}',
        semester: '${subjectClass.semester}',
        codeOfSubject: subjectClass.subject.code,
        name: subjectClass.name,
      );
    }
  }
}
