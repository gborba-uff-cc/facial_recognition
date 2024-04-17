import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/widgets/create_lesson.dart';
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

  SubjectClass? _lessonSubjectClass;
  DateTime? _lessonDate;
  DateTime? _lessonTime;
  Teacher? _lessonTeacher;

  String? _subjectCode;
  String? _subjectName;

  String? _subjectClassYear;
  String? _subjectClassSemester;

  String? _teacherIndividualRegistration;
  String? _teacherRegistration;
  String? _teacherName;
  String? _teacherSurname;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar'),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text('Aula', maxLines: 1, style: Theme.of(context).textTheme.titleMedium,),
            Form(child: CreateLesson(
              onDateSaved: (date) {_lessonDate = date;},
              onTimeSaved: (time) {_lessonTime = time;},
            )),
            SubmitButton(
              formKey: _lessonForm,
              afterSave: () {
                final date = _lessonDate;
                final time = _lessonTime;
                if (date == null || time == null) {
                  projectLogger.fine('Date or time is null');
                  return;
                }
                final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute, time.second);
                projectLogger.fine('[lesson] subjectClass:, dateTime: $dateTime, teacher:');
                // FIXME - widget.useCase.createLesson(_lessonSubjectClass, dateTime, _lessonTeacher);
              },
            ),
            const Divider(),
            Text('Disciplina', maxLines: 1, style: Theme.of(context).textTheme.titleMedium,),
            Form(child: CreateSubject(
              onCodeSaved: (code) {_subjectCode = code;},
              onNameSaved: (name) {_subjectName = name;},
            )),
            SubmitButton(
              formKey: _subjectForm,
              afterSave: () {
                projectLogger.fine('[subject] code: $_subjectCode, name: $_subjectName');
            },),
            const Divider(),
            Text('Turma', maxLines: 1, style: Theme.of(context).textTheme.titleMedium,),
            Form(child: CreateSubjectClass(
              onYearSaved: (year) {_subjectClassYear = year;},
              onSemesterSaved: (semester) {_subjectClassSemester = semester;},
            )),
            SubmitButton(
              formKey: _subjectClassForm,
              afterSave: () {
                projectLogger.fine('[subjectClass] year: $_subjectClassYear, semester: $_subjectClassSemester');
              },),
            const Divider(),
            Text('Professor', maxLines: 1, style: Theme.of(context).textTheme.titleMedium,),
            Form(child: CreateTeacher(
              onIndividualRegistrationSaved: (individualRegistration) {_teacherIndividualRegistration = individualRegistration;},
              onRegistrationSaved: (registration) {_teacherRegistration = registration;},
              onNameSaved: (name) {_teacherName = name;},
              onSurnameSaved: (surname) {_teacherSurname = surname;},
            )),
            SubmitButton(
              formKey: _teacherForm,
              afterSave: () {
                projectLogger.fine('[teacher] individualRegistration: $_teacherIndividualRegistration, registration: $_teacherRegistration, name: $_teacherName, surname: $_teacherSurname');
              },),
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
    required void Function() afterSave,
  })  : _formKey = formKey,
        _afterSave = afterSave;

  final GlobalKey<FormState> _formKey;
  final void Function() _afterSave;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        final formState = _formKey.currentState;
        if (formState == null) {
          return;
        }
        else if (formState.validate()) {
          formState.save();
          _afterSave();
          return;
        }
      },
      child: const Text('Adicionar'),
    );
  }
}
