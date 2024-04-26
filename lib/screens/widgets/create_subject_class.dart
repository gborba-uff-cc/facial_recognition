import 'package:facial_recognition/screens/widgets/form_fields.dart';
import 'package:flutter/material.dart';

class CreateSubjectClass extends StatelessWidget {
  const CreateSubjectClass({
    super.key,
    required TextEditingController codeOfSubject,
    required TextEditingController year,
    required TextEditingController semester,
    required TextEditingController name,
    required TextEditingController registrationOfTeacher,
  })  : _codeOfSubject = codeOfSubject,
        _registrationOfTeacher = registrationOfTeacher,
        _year = year,
        _semester = semester,
        _name = name;

  final TextEditingController _codeOfSubject;
  final TextEditingController _registrationOfTeacher;
  final TextEditingController _year;
  final TextEditingController _semester;
  final TextEditingController _name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SubjectFieldCode(
          controller: _codeOfSubject,
          labelText: '',
          helperText: '',
        ),
        TeacherFieldRegistration(
            controller: _registrationOfTeacher,
            labelText: 'Matrícula',
            helperText: 'Professor da turma'),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SubjectClassFieldYear(
                controller: _year,
                labelText: 'Ano',
                helperText: '',
              ),
            ),
            const Spacer(flex: 1,),
            Expanded(
              flex: 3,
              child: SubjectClassFieldSemester(
                controller: _semester,
                labelText: 'Semestre',
                helperText: '',
              ),
            ),
          ],
        ),
        SubjectClassFieldName(
          controller: _name,
          labelText: 'Nome',
          helperText: 'Ex. A1',
        ),
      ],
    );
  }
}
