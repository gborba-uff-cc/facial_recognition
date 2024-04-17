import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/widgets/create_lesson.dart';
import 'package:facial_recognition/screens/widgets/create_subject.dart';
import 'package:facial_recognition/screens/widgets/create_subject_class.dart';
import 'package:facial_recognition/screens/widgets/create_teacher.dart';
import 'package:facial_recognition/screens/widgets/selector.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class SelectLessonScreen extends StatefulWidget {
  const SelectLessonScreen({
    super.key,
  });

  @override
  State<SelectLessonScreen> createState() => _SelectLessonScreenState();
}

class _SelectLessonScreenState extends State<SelectLessonScreen> {
  final List<String> lessons = ['l1', 'l2', 'l3'];
  final List<String> teachers = ['t1', 't2', 't3'];
  final List<String> subjectClasses = ['sc1', 'sc2', 'sc3'];
  final _formKey = GlobalKey<FormState>();
  final _lessonFormFieldKey = GlobalKey<FormFieldState>();
  final _teacherFormFieldKey = GlobalKey<FormFieldState>();
  final _subjectClassFormFieldKey = GlobalKey<FormFieldState>();
  String? _selectedLesson;
  String? _selectedTeacher;
  String? _selectedSubjectClass;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(SelectLessonScreen oldWidget) {
    projectLogger.fine('did update SelectLesson');
    // DomainRepository.of(context).getSubjectClass();
    // DomainRepository.of(context).getLessonFromSubjectClass(subjectClass);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    const selectTitle = 'Selecionar existente';
    const createTitle = 'Adicionar';

    final lesson = SelectOrCreate(
      title: 'Aula',
      selectTitle: selectTitle,
      createTitle: createTitle,
      selector: Selector(
        options: lessons,
        selectedOption: _selectedLesson,
        onChanged: (item) {
          if (mounted) {
            setState(() {
              _selectedLesson = item;
            });
          }
          projectLogger.fine(_selectedLesson);
        },
      ),
      creator: CreateLesson(
        onDateSaved: (DateTime date) {},
        onTimeSaved: (DateTime time) {},
      ),
    );
    final lessonTeacher = SelectOrCreate(
      title: 'Professor da aula',
      selectTitle: selectTitle,
      createTitle: createTitle,
      selector: Selector(
        options: teachers,
        selectedOption: _selectedTeacher,
        onChanged: (item) {
          _selectedTeacher = item;
        },
      ),
      creator: CreateTeacher(
        onIndividualRegistrationSaved: (String? individualRegistration) {},
        onRegistrationSaved: (String? registration) {},
        onNameSaved: (String? name) {},
        onSurnameSaved: (String? surname) {},
      ),
    );
    final sujectClass = SelectOrCreate(
      title: 'Turma',
      selectTitle: selectTitle,
      createTitle: createTitle,
      selector: Selector(
        options: subjectClasses,
        selectedOption: _selectedSubjectClass,
        onChanged: (item) {
          _selectedSubjectClass = item;
        },
      ),
      creator: CreateSubjectClass(
        onYearSaved: (String? year) {},
        onSemesterSaved: (String? semester) {},
      ),
    );
    final subjectClassTeacher = SelectOrCreate(
      title: 'Professor da turma',
      selectTitle: selectTitle,
      createTitle: createTitle,
      selector: Selector(
        options: teachers,
        selectedOption: null,
        onChanged: (item) {},
      ),
      creator: CreateTeacher(
        onIndividualRegistrationSaved: (String? individualRegistration) {},
        onRegistrationSaved: (String? registration) {},
        onNameSaved: (String? name) {},
        onSurnameSaved: (String? surname) {},
      ),
    );
    final subject = SelectOrCreate(
      title: 'Disciplina',
      selectTitle: selectTitle,
      createTitle: createTitle,
      selector: Selector(
        options: const ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
        selectedOption: null,
        onChanged: (item) {},
      ),
      creator: CreateSubject(
        onCodeSaved: (String? code) {},
        onNameSaved: (String? name) {},
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Selecione a aula'),),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    lesson,
                    const Divider(),
                    lessonTeacher,
                    const Divider(),
                    sujectClass,
                    const Divider(),
                    subjectClassTeacher,
                    const Divider(),
                    subject,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _confirmButtonAction,
                  child: const Text('Confirmar', maxLines: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmButtonAction() {
    final fs = _formKey.currentState;
    String msg = '';
    if (fs != null && fs.validate()) {
      msg = 'Válido';
      fs.save();
    } else {
      msg = 'Não válido';
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg, maxLines: 2)));
  }
}

class SelectOrCreate extends StatelessWidget {
  const SelectOrCreate({
    super.key,
    this.title,
    this.selectTitle,
    this.createTitle,
    required this.selector,
    required this.creator,
  });

  final String? title;
  final String? selectTitle;
  final String? createTitle;
  final Widget selector;
  final Widget creator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (title != null) Text(title!, maxLines: 1, style: Theme.of(context).textTheme.titleLarge,),
        if (selectTitle != null) Text(selectTitle!, maxLines: 1, style: Theme.of(context).textTheme.titleMedium,),
        selector,
        if (createTitle != null) Text(createTitle!, maxLines: 1, style: Theme.of(context).textTheme.titleMedium,),
        creator,
      ],
    );
  }
}
