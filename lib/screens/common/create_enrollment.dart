import 'package:facial_recognition/screens/common/form_fields.dart';
import 'package:flutter/material.dart';

class CreateEnrollment extends StatelessWidget {
  const CreateEnrollment({
    super.key,
    required TextEditingController codeOfSubject,
    required TextEditingController year,
    required TextEditingController semester,
    required TextEditingController name,
    required TextEditingController registrationOfStudent,
  })  : _codeOfSubject = codeOfSubject,
        _registrationOfStudent = registrationOfStudent,
        _year = year,
        _semester = semester,
        _name = name;

  final TextEditingController _codeOfSubject;
  final TextEditingController _registrationOfStudent;
  final TextEditingController _year;
  final TextEditingController _semester;
  final TextEditingController _name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StudentFieldRegistration(
            controller: _registrationOfStudent,
            labelText: 'Matrícula',
            helperText: 'Aluno inscrito'),
        SubjectFieldCode(
          controller: _codeOfSubject,
          labelText: 'Código',
          helperText: 'Identificador da disciplina',
        ),
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
