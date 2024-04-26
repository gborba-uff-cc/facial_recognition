import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/widgets/create_lesson.dart';
import 'package:facial_recognition/screens/widgets/create_student.dart';
import 'package:facial_recognition/screens/widgets/create_subject.dart';
import 'package:facial_recognition/screens/widgets/create_subject_class.dart';
import 'package:facial_recognition/screens/widgets/create_teacher.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class CreateModelsScreen extends StatefulWidget {
  const CreateModelsScreen({
    super.key,
    required this.useCase,
  });

  final CreateModels useCase;

  @override
  State<CreateModelsScreen> createState() => _CreateModelsScreenState();
}

class _CreateModelsScreenState extends State<CreateModelsScreen> {
  final GlobalKey<FormState> _lessonForm = GlobalKey();
  final GlobalKey<FormState> _subjectForm = GlobalKey();
  final GlobalKey<FormState> _subjectClassForm = GlobalKey();
  final GlobalKey<FormState> _teacherForm = GlobalKey();
  final GlobalKey<FormState> _studentForm = GlobalKey();

  final TextEditingController _lessonCodeOfSubjectClass =
    TextEditingController.fromValue(null);
  final TextEditingController _lessonYearOfSubjectClass =
    TextEditingController.fromValue(null);
  final TextEditingController _lessonSemesterOfSubjectClass =
    TextEditingController.fromValue(null);
  final TextEditingController _lessonNameOfSubjectClass =
    TextEditingController.fromValue(null);
  final TextEditingController _lessonDate =
    TextEditingController.fromValue(null);
  final TextEditingController _lessonTime =
    TextEditingController.fromValue(null);
  final TextEditingController _lessonTeacher =
    TextEditingController.fromValue(null);

  final TextEditingController _subjectCode =
      TextEditingController.fromValue(null);
  final TextEditingController _subjectName =
      TextEditingController.fromValue(null);

  final TextEditingController _subjectClassSubjectCode =
      TextEditingController.fromValue(null);
  final TextEditingController _subjectClassTeacherRegistration =
      TextEditingController.fromValue(null);
  final TextEditingController _subjectClassYear =
      TextEditingController.fromValue(null);
  final TextEditingController _subjectClassSemester =
      TextEditingController.fromValue(null);
  final TextEditingController _subjectClassName =
      TextEditingController.fromValue(null);

  final TextEditingController _teacherIndividualRegistration =
      TextEditingController.fromValue(null);
  final TextEditingController _teacherRegistration =
      TextEditingController.fromValue(null);
  final TextEditingController _teacherName =
      TextEditingController.fromValue(null);
  final TextEditingController _teacherSurname =
      TextEditingController.fromValue(null);

  final TextEditingController _studentIndividualRegistration =
      TextEditingController.fromValue(null);
  final TextEditingController _studentRegistration =
      TextEditingController.fromValue(null);
  final TextEditingController _studentName =
      TextEditingController.fromValue(null);
  final TextEditingController _studentSurname =
      TextEditingController.fromValue(null);

  @override
  void dispose() {
    _lessonCodeOfSubjectClass.dispose();
    _lessonYearOfSubjectClass.dispose();
    _lessonSemesterOfSubjectClass.dispose();
    _lessonNameOfSubjectClass.dispose();
    _lessonDate.dispose();
    _lessonTime.dispose();
    _lessonTeacher.dispose();

    _subjectCode.dispose();
    _subjectName.dispose();

    _subjectClassSubjectCode.dispose();
    _subjectClassTeacherRegistration.dispose();
    _subjectClassYear.dispose();
    _subjectClassSemester.dispose();
    _subjectClassName.dispose();

    _teacherIndividualRegistration.dispose();
    _teacherRegistration.dispose();
    _teacherName.dispose();
    _teacherSurname.dispose();

    _studentIndividualRegistration.dispose();
    _studentRegistration.dispose();
    _studentName.dispose();
    _studentSurname.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text(
              'Aula',
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Form(
              key: _lessonForm,
              child: CreateLesson(
                codeOfSubject: _lessonCodeOfSubjectClass,
                yearOfSubjectClass: _lessonYearOfSubjectClass,
                semesterOfSubjectClass: _lessonSemesterOfSubjectClass,
                nameOfSubjectClass: _lessonNameOfSubjectClass,
                teacher: _lessonTeacher,
                date: _lessonDate,
                time: _lessonTime,
              ),
            ),
            SubmitButton(
              formKey: _lessonForm,
              action: () {
                final date = MaterialLocalizations.of(context)
                    .parseCompactDate(_lessonDate.text);
                final time = MaterialLocalizations.of(context)
                    .parseCompactDate(_lessonTime.text);
                if (date == null || time == null) {
                  projectLogger.fine('date or time is null');
                  return;
                }
                final dateTime = DateTime(date.year, date.month, date.day,
                    time.hour, time.minute, time.second);
                projectLogger.fine(
                    '[lesson] subjectClass:, dateTime: $dateTime, teacher: -, subjectClass: -');
              },
            ),
            const Divider(),
            // -----------------------------------------------------------------
            Text(
              'Disciplina',
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Form(
              key: _subjectForm,
              child: CreateSubject(
                codeController: _subjectCode,
                nameController: _subjectName,
              ),
            ),
            SubmitButton(
              formKey: _subjectForm,
              action: () {
                final code = _subjectCode.text;
                final name = _subjectName.text;
                projectLogger.fine('[subject] code: $code, name: $name');
              },
            ),
            const Divider(),
            // -----------------------------------------------------------------
            Text(
              'Turma',
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Form(
              key: _subjectClassForm,
              child: CreateSubjectClass(
                codeOfSubject: _subjectClassSubjectCode,
                registrationOfTeacher: _subjectClassTeacherRegistration,
                year: _subjectClassYear,
                semester: _subjectClassSemester,
                name: _subjectClassName,
              ),
            ),
            SubmitButton(
              formKey: _subjectClassForm,
              action: () {
                final year = _subjectClassYear;
                final semester = _subjectClassSemester;
                projectLogger
                    .fine('[subjectClass] year: $year, semester: $semester');
              },
            ),
            const Divider(),
            // -----------------------------------------------------------------
            Text(
              'Professor',
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Form(
                key: _teacherForm,
                child: CreateTeacher(
                  individualRegistrationController:
                      _teacherIndividualRegistration,
                  registrationController: _teacherRegistration,
                  nameController: _teacherName,
                  surnameController: _teacherSurname,
                )),
            SubmitButton(
              formKey: _teacherForm,
              action: () {
                final individualRegistration =
                    _teacherIndividualRegistration.text;
                final registration = _teacherRegistration.text;
                final name = _teacherName.text;
                final surname = _teacherSurname.text;
                projectLogger.fine(
                    '[teacher] individualRegistration: $individualRegistration, registration: $registration, name: $name, surname: $surname');
              },
            ),
            const Divider(),
            // -----------------------------------------------------------------
            Text(
              'Aluno',
              maxLines: 1,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Form(
                key: _studentForm,
                child: CreateStudent(
                  individualRegistrationController:
                      _studentIndividualRegistration,
                  registrationController: _studentRegistration,
                  nameController: _studentName,
                  surnameController: _studentSurname,
                )),
            SubmitButton(
              formKey: _studentForm,
              action: () {
                projectLogger.fine(
                    '[student] individualRegistration: $_studentIndividualRegistration, registration: $_studentRegistration, name: $_studentName, surname: $_studentSurname');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Button for validate, save (form fields) and run an after save function.
class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    required GlobalKey<FormState> formKey,
    required void Function() action,
  })  : _formKey = formKey,
        _action = action;

  final GlobalKey<FormState> _formKey;
  final void Function() _action;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        final formState = _formKey.currentState;
        if (formState!.validate()) {
          _action();
          return;
        }
      },
      child: const Text('Adicionar'),
    );
  }
}
