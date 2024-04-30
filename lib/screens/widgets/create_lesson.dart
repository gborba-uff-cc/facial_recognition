import 'package:facial_recognition/screens/widgets/form_fields.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class CreateLesson extends StatelessWidget {
  const CreateLesson({
    super.key,
    required TextEditingController codeOfSubject,
    required TextEditingController yearOfSubjectClass,
    required TextEditingController semesterOfSubjectClass,
    required TextEditingController nameOfSubjectClass,
    required TextEditingController date,
    required TextEditingController time,
    required TextEditingController registrationOfTeacher,
  })  : _codeOfSubject = codeOfSubject,
        _yearOfSubjectClass = yearOfSubjectClass,
        _semesterOfSubjectClass = semesterOfSubjectClass,
        _nameOfSubjectClass = nameOfSubjectClass,
        _date = date,
        _time = time,
        _teacher = registrationOfTeacher;

  final TextEditingController _codeOfSubject;
  final TextEditingController _yearOfSubjectClass;
  final TextEditingController _semesterOfSubjectClass;
  final TextEditingController _nameOfSubjectClass;
  final TextEditingController _date;
  final TextEditingController _time;
  final TextEditingController _teacher;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fDate = DateTime(now.year, 01, 01);
    final lDate = DateTime(now.year, 12, 31);

    final date = TextFormField(
      controller: _date,
      enabled: false,
      decoration: const InputDecoration(
        labelText: 'Data',
        helperText: '',
      ),
      keyboardType: TextInputType.datetime,
      validator: (input) {
        final valueClear = input?.trim();
        if (valueClear == null || valueClear.characters.isEmpty) {
          return "Entre uma data";
        }
        final date = MaterialLocalizations.of(context).parseCompactDate(valueClear);
        if (date == null) {
          return 'Data não válida';
        } else if (date.isBefore(fDate) || date.isAfter(lDate)) {
          return 'Data não permitida';
        }
        return null;
      },
    );

    final time = TextFormField(
      controller: _time,
      enabled: false,
      decoration: const InputDecoration(
        labelText: 'Horário',
        helperText: ''
      ),
      keyboardType: TextInputType.datetime,
      validator: (input) {
        final valueClear = input?.trim();
        if (valueClear == null || valueClear.characters.isEmpty) {
          return "Entre um horário";
        }
        _time.text = valueClear;
        return null;
      },
    );

    final editDate = IconButton(
      onPressed: () async {
        await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: fDate,
          lastDate: lDate,
        ).then((value) {
          projectLogger.fine('selected date: $value');
          if (value != null) {
            _date.text = MaterialLocalizations.of(context).formatCompactDate(value);
          }
        });
      },
      icon: const Icon(Icons.edit),
    );

    final editTime = IconButton(
      onPressed: () async {
        await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(now),
        ).then((value) {
          if (value != null) {
            _time.text = MaterialLocalizations.of(context).formatTimeOfDay(value, alwaysUse24HourFormat: true);
          }
        });
      },
      icon: const Icon(Icons.edit),
    );

    return Column(
      children: [
        SubjectFieldCode(
          controller: _codeOfSubject,
          labelText: 'Disciplina',
          helperText: 'Código',
        ),
        TeacherFieldRegistration(
          controller: _teacher,
          labelText: 'Professor',
          helperText: 'Matrícula',
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SubjectClassFieldYear(
                controller: _yearOfSubjectClass,
                labelText: 'Ano',
                helperText: '',
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            Expanded(
              flex: 3,
              child: SubjectClassFieldSemester(
                controller: _semesterOfSubjectClass,
                labelText: 'Semestre',
                helperText: '',
              ),
            ),
          ],
        ),
        SubjectClassFieldName(
          controller: _nameOfSubjectClass,
          labelText: 'Nome',
          helperText: 'Ex. A1',
        ),
        Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: date,
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: editDate,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: time,
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: editTime,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
