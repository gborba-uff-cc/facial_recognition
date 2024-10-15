import 'dart:io';

import 'package:facial_recognition/screens/widgets/card_single_action.dart';
import 'package:facial_recognition/screens/widgets/default_app_button.dart';
import 'package:facial_recognition/screens/widgets/selector.dart';
import 'package:facial_recognition/screens/widgets/submit_form_button.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:file_picker/file_picker.dart' as pkg_picker;
import 'package:excel/excel.dart' as pkg_excel;
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:flutter/material.dart';

const _menuSpacer = SizedBox(height: 16.0);

class ModelsFromXlsxScreen extends StatefulWidget {
  const ModelsFromXlsxScreen({
    super.key,
    required this.useCase,
  });

  final CreateModels useCase;

  @override
  State<ModelsFromXlsxScreen> createState() => _ModelsFromXlsxScreenState();
}

class _ModelsFromXlsxScreenState extends State<ModelsFromXlsxScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  pkg_picker.FilePickerResult? _pickedFile;
  pkg_excel.Excel? _spreadsheet;
  final List<String> _allSheets = [];

  final List<String> _optionsForLessons = [];
  final List<String> _optionsForEnrollments = [];
  String? _sheetLessonsName;
  String? _sheetEnrollmentsName;

  @override
  Widget build(BuildContext context) {
    final pickedFile = _pickedFile;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ler do arquivo',
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineLarge,
          overflow: TextOverflow.fade,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            DefaultAppButton(
              onTap: _handleXlsxFilePicking,
              child: Text('Selecionar arquivo'),
            ),
            Text(
              'Arquivo selecionado',
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineLarge,
              overflow: TextOverflow.fade,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0) +
                  EdgeInsets.only(top: 8.0),
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
                          pickedFile.names.single ?? '',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
            ),
            _menuSpacer,
            Text(
              'Alunos',
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Selector<String>(
              options: _optionsForEnrollments,
              selectedOption: _sheetEnrollmentsName,
              toWidget: (item) => Text(item == null ? 'selecione a planilha' : 'Planilha: $item'),
              onChanged: (item) {
                if (mounted) {
                  setState(() {
                    _sheetEnrollmentsName = item;
                    _optionsForLessons.clear();
                    _optionsForLessons.addAll(_allSheets);
                    _optionsForLessons.remove(item);
                  });
                }
              },
            ),
            _menuSpacer,
            Text(
              'Aulas',
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Selector<String>(
              options: _optionsForLessons,
              selectedOption: _sheetLessonsName,
              toWidget: (item) => Text(item == null ? 'selecione a planilha' : 'Planilha: $item'),
              onChanged: (item) {
                if (mounted) {
                  setState(() {
                    _sheetLessonsName = item;
                    _optionsForEnrollments.clear();
                    _optionsForEnrollments.addAll(_allSheets);
                    _optionsForEnrollments.remove(item);
                  });
                }
              },
            ),
            DefaultAppButton(
              onTap: _spreadsheet == null
                  ? null
                  : () {
                    projectLogger.fine('adicionar foi tocado');
                      final spreadSheet = _spreadsheet;
                      if (spreadSheet == null) {
                        return;
                      }
                      final sheets = spreadSheet.sheets;
                      final sheetEnrollments = sheets[_sheetEnrollmentsName];
                      final sheetLessons = sheets[_sheetLessonsName];
                      if (sheetLessons != null) {
                        projectLogger.fine(
                          'Enrollment rows: ${sheetLessons.maxRows} columns: ${sheetLessons.maxColumns}',
                        );
                        for (final row in sheetLessons.rows) {
                          projectLogger.fine(row);
                          for (final data in row) {
                            if (data != null) {
                              projectLogger.fine('[${data.cellIndex}] ${data.value}');
                            }
                          }
                        }
                      }
/*
                widget.useCase.createStudent(
                  individualRegistration: individualRegistration,
                  registration: registration,
                  name: name,
                  surname: surname,
                );
                widget.useCase.createEnrollment(
                  registrationOfStudent: registrationOfStudent,
                  year: year,
                  semester: semester,
                  codeOfSubject: codeOfSubject,
                  name: name,
                );
 */
                    },
              child: Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleXlsxFilePicking() async {
    pkg_picker.FilePickerResult? pickedFile =
        await pkg_picker.FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: pkg_picker.FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    pkg_excel.Excel? spreadsheet;
    final List<String> sheets = [];

    if (pickedFile != null) {
      final bytes = await pickedFile.xFiles.single.readAsBytes();
      spreadsheet = pkg_excel.Excel.decodeBytes(bytes);
      sheets.addAll(spreadsheet.sheets.keys);
    }
    if (mounted) {
      setState(() {
        if (pickedFile == null || pickedFile.names.single != _pickedFile?.names.single) {
          _sheetEnrollmentsName = null;
          _sheetLessonsName = null;
        }
        _pickedFile = pickedFile;
        _spreadsheet = spreadsheet;
        _allSheets.clear();
        _allSheets.addAll(sheets);
        _optionsForEnrollments.clear();
        _optionsForEnrollments.addAll(_allSheets);
        _optionsForLessons.clear();
        _optionsForLessons.addAll(_allSheets);
      });
    }
  }
}
