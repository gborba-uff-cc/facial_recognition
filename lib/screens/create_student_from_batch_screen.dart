import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/screens/common/excel_picker_button.dart';
import 'package:facial_recognition/screens/common/selector.dart';
import 'package:facial_recognition/use_case/batch_read.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:excel/excel.dart' as pkg_excel;
import 'package:cross_file/cross_file.dart' as pkg_xfile;
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:flutter/material.dart';

class CreateStudentFromBatchScreen extends StatefulWidget {
  const CreateStudentFromBatchScreen({
    super.key,
    required this.batchReadUseCase,
    required this.createModelsUseCase,
  });

  final BatchRead batchReadUseCase;
  final CreateModels createModelsUseCase;

  @override
  State<CreateStudentFromBatchScreen> createState() => _CreateStudentFromBatchScreenState();
}

class _CreateStudentFromBatchScreenState extends State<CreateStudentFromBatchScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  pkg_xfile.XFile? _pickedFile;
  pkg_excel.Excel? _spreadsheet;
  final List<String> _spreadsheetSheetsName = [];
  final List<String> _selectableSheetsName = [];
  String? _selectedSheetName;

  bool _shouldEnroll = false;

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
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(value: _shouldEnroll, onChanged: (newValue) {
                setState(() {
                  _shouldEnroll = newValue ?? false;
                });
              }),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  'Matricular em turma',
                  maxLines: 1,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
          Selector<Subject>(
            options: [],
            selectedOption: _selectedSubject,
            toWidget: (item) {
              if (item == null) {
                return Text('selecione a disciplina');
              }
              else {
                // TODO
                return Placeholder();
              }
            },
            onChanged: _shouldEnroll
                ? (item) {
                    if (mounted) {
                      setState(() {
                        _selectedSubject = item;
                      });
                    }
                  }
                : null,
          ),
        ],
      ),
    ];
    return AppDefaultMenuScaffold(
      appBar: AppDefaultAppBar(title: 'Aluno(a) de planilha'),
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
              onTap: _spreadsheet == null || _selectedSheetName == null
                  ? null
                  : () {
                    final s = _spreadsheet;
                    final n = _selectedSheetName;
                    final c = _selectedSubjectClass;
                      if (s == null || n == null) {
                        return;
                      }
                      _processStudentSheet(
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
  void _processStudentSheet({
    required pkg_excel.Sheet sheet,
    SubjectClass? subjectClass,
  }) {
    final students = widget.batchReadUseCase.readStudents(sheet: sheet);
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
