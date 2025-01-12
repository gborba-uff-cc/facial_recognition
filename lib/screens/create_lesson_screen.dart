import 'package:facial_recognition/screens/common/create_lesson.dart';
import 'package:facial_recognition/screens/common/submit_form_button.dart';
import 'package:facial_recognition/use_case/create_models.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class CreateLessonScreen extends StatefulWidget {
  const CreateLessonScreen({
    super.key,
    required this.useCase,
  });

  final CreateModels useCase;

  @override
  State<CreateLessonScreen> createState() => _CreateLessonScreenState();
}

class _CreateLessonScreenState extends State<CreateLessonScreen> {
  final GlobalKey<FormState> _lessonForm = GlobalKey();

  final TextEditingController _codeOfSubjectClass =
    TextEditingController.fromValue(null);
  final TextEditingController _yearOfSubjectClass =
    TextEditingController.fromValue(null);
  final TextEditingController _semesterOfSubjectClass =
    TextEditingController.fromValue(null);
  final TextEditingController _nameOfSubjectClass =
    TextEditingController.fromValue(null);
  final TextEditingController _date =
    TextEditingController.fromValue(null);
  final TextEditingController _time =
    TextEditingController.fromValue(null);
  final TextEditingController _registrationOfTeacher =
    TextEditingController.fromValue(null);

  @override
  void dispose() {
    _codeOfSubjectClass.dispose();
    _yearOfSubjectClass.dispose();
    _semesterOfSubjectClass.dispose();
    _nameOfSubjectClass.dispose();
    _date.dispose();
    _time.dispose();
    _registrationOfTeacher.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nova aula',
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineLarge,
          overflow: TextOverflow.fade,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Form(
              key: _lessonForm,
              child: CreateLesson(
                codeOfSubject: _codeOfSubjectClass,
                yearOfSubjectClass: _yearOfSubjectClass,
                semesterOfSubjectClass: _semesterOfSubjectClass,
                nameOfSubjectClass: _nameOfSubjectClass,
                registrationOfTeacher: _registrationOfTeacher,
                date: _date,
                time: _time,
              ),
            ),
            SubmitFormButton(
              formKey: _lessonForm,
              action: () {
                final date = MaterialLocalizations.of(context)
                    .parseCompactDate(_date.text);
                final time = TimeOfDay.fromDateTime(
                  DateTime.parse('0000-00-00T${_time.text}'),
                );
                if (date == null) {
                  projectLogger.fine('date or time is null');
                  return;
                }
                final dateTime = DateTime(date.year, date.month, date.day,
                    time.hour, time.minute).toUtc().toIso8601String();

                widget.useCase.createLesson(
                  codeOfSubject: _codeOfSubjectClass.text,
                  yearOfSubjectClass: _yearOfSubjectClass.text,
                  semesterOfSubjectClass: _semesterOfSubjectClass.text,
                  nameOfSubjectClass: _nameOfSubjectClass.text,
                  registrationOfTeacher: _registrationOfTeacher.text,
                  utcDateTime: dateTime,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
