import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/select_information_return.dart';
import 'package:facial_recognition/screens/common/selector.dart';
import 'package:facial_recognition/use_case/select_lesson.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelectInformationScreen extends StatefulWidget {
  const SelectInformationScreen({
    super.key,
    required this.useCase,
  });

  final SelectLesson useCase;

  @override
  State<SelectInformationScreen> createState() => _SelectInformationScreenState();
}

class _SelectInformationScreenState extends State<SelectInformationScreen> {
  List<Subject> subjects = [];
  List<SubjectClass> subjectClasses = [];
  List<Lesson> lessons = [];
  final _formKey = GlobalKey<FormState>();
  Subject? _selectedSubject;
  SubjectClass? _selectedSubjectClass;
  Lesson? _selectedLesson;

  @override
  void initState() {
    super.initState();
    subjects = widget.useCase.getSubjects();
  }

  @override
  void didUpdateWidget(SelectInformationScreen oldWidget) {
    projectLogger.fine('did update SelectLesson');
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgets = [
      // subject selector
      Text(
        'Disciplina',
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      Selector<Subject>(
        options: subjects,
        toWidget: (item) => item == null
            ? const Text('selecione uma disciplina')
            : Text('${item.code} ${item.name}'),
        selectedOption: _selectedSubject,
        onChanged: (item) {
          if (item == _selectedSubject) {
            return;
          }
          _selectedSubject = item;
          if (item == null) {
            return;
          }
          if (mounted) {
          setState(() {
            subjectClasses = widget.useCase.getSubjectClasses(item);
          });
          }
        },
      ),
      const Divider(),
      // subject class selector
      Text(
        'Turma',
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      Selector<SubjectClass>(
        options: subjectClasses,
        toWidget: (item) => item == null
            ? const Text('selecione uma turma')
            : Text('${item.year} ${item.semester} ${item.name}'),
        selectedOption: _selectedSubjectClass,
        onChanged: (item) {
          if (item == _selectedSubjectClass) {
            return;
          }
          _selectedSubjectClass = item;
          if (item == null) {
            return;
          }
          if (mounted) {
            setState(() {
              lessons = widget.useCase.getLessons(item);
            });
          }
        },
      ),
      const Divider(),
      // lesson selector
      Text(
        'Aula',
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      Selector<Lesson>(
        options: lessons,
        toWidget: (item) {
          if (item == null) {
            return const Text('selecione uma aula');
          } else {
            final localDateTime = item.utcDateTime;
            final showDateTime = MaterialLocalizations.of(context)
                .formatCompactDate(localDateTime);
            return Text(showDateTime);
          }
        },
        selectedOption: _selectedLesson,
        onChanged: (item) {
          if (item == _selectedLesson) {
            return;
          }
          _selectedLesson = item;
          if (item == null) {
            return;
          }
        },
      ),
      const Divider(),
    ];
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
                  children: widgets,
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
    if (fs != null) {
      final valid = fs.validate();
      if (valid) {
        fs.save();
      }
    }
    projectLogger.fine('Subject: $_selectedSubject; SubjectClass: $_selectedSubjectClass; Lesson: $_selectedLesson');

    final aux = SelectInformationReturn(
      subject: _selectedSubject,
      subjectClass: _selectedSubjectClass,
      lesson: _selectedLesson,
    );
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(aux);
    }
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
