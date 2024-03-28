import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';

class SelectLessonScreen extends StatefulWidget {
  const SelectLessonScreen({super.key});

  @override
  State<SelectLessonScreen> createState() => _SelectLessonScreenState();
}

class _SelectLessonScreenState extends State<SelectLessonScreen> {
  final List<String?> lessons = ['l1', 'l2', 'l3'];
  final List<String?> teachers = ['t1', 't2', 't3'];
  final List<String?> subjectClasses = ['sc1', 'sc2', 'sc3'];
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
    lessons.insert(0, null);
    teachers.insert(0, null);
    subjectClasses.insert(0, null);
    _selectedLesson = lessons.first;
    _selectedTeacher = teachers.first;
    _selectedSubjectClass = subjectClasses.first;
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
    final confirmButton = FilledButton(
      onPressed: () {
        final s = _formKey.currentState;
        String msg = '';
        if (s != null && s.validate()) {
          msg = 'Válido';
          s.save();
        }
        else {
          msg = 'Não válido';
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg, maxLines: 2)));
      },
      child: const Text('Confirmar', maxLines: 1),
    );

    const selectTitle = 'Selecionar existente';
    const createTitle = 'Adicionar';

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
                    SelectOrCreate(
                      title: 'Aula',
                      selectTitle: selectTitle,
                      createTitle: createTitle,
                      selector: Selector(
                        options: const ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
                      ),
                      creator: const CreateLesson(),
                    ),
                    const Divider(),
                    SelectOrCreate(
                      title: 'Professor da aula',
                      selectTitle: selectTitle,
                      createTitle: createTitle,
                      selector: Selector(
                        options: const ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
                      ),
                      creator: const CreateTeacher(),
                    ),
                    const Divider(),
                    SelectOrCreate(
                      title: 'Turma',
                      selectTitle: selectTitle,
                      createTitle: createTitle,
                      selector: Selector(
                        options: const ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
                      ),
                      creator: const CreateSubjectClass(),
                    ),
                    const Divider(),
                    SelectOrCreate(
                      title: 'Professor da turma',
                      selectTitle: selectTitle,
                      createTitle: createTitle,
                      selector: Selector(
                        options: const ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
                      ),
                      creator: const CreateTeacher(),
                    ),
                    const Divider(),
                    SelectOrCreate(
                      title: 'Disciplina',
                      selectTitle: selectTitle,
                      createTitle: createTitle,
                      selector: Selector(
                        options: const ['a', 'b', 'c', 'd', 'e', 'f', 'g'],
                      ),
                      creator: const CreateSubject(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(width: double.infinity, child: confirmButton),
            ),
          ],
        ),
      ),
    );
  }
}

class Selector extends StatelessWidget {
  factory Selector({
    Key? key,
    String? label,
    required List options,
  }) =>
      Selector._private(key: key, label: label, options: [null, ...options]);

  const Selector._private({
    super.key,
    this.label,
    required this.options,
  });

  final String? label;
  final List options;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      // key: super.key,
      hint: const Text('hint when enabled'),
      disabledHint: const Text('hint when disabled'),
      value: options.first,
      items: options
          .map((e) => DropdownMenuItem(
                key: ValueKey(e),
                value: e,
                child: Text(
                  e?.toString() ?? '',
                  maxLines: 1,
                ),
              ))
          .toList(),
      validator: (value) => 'null',
      onChanged: (value) {},
      decoration: InputDecoration(
        label: label == null ? null : Text(label!),
        helperText: '',
        helperMaxLines: 1,
      ),
    );
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

class CreateLesson extends StatelessWidget {
  const CreateLesson({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fDate = DateTime(2024, 01, 01);
    final lDate = DateTime(2024, 12, 31, 23, 59, 59);

    final pickDate = Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: InputDatePickerFormField(
            fieldLabelText: 'Data',
            fieldHintText: 'Data da aula',
            keyboardType: TextInputType.datetime,
            firstDate: fDate,
            lastDate: lDate,
            errorFormatText: 'não reconhecida',
            errorInvalidText: 'não válida',
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: fDate,
                  lastDate: lDate,
                );
              },
              icon: const Icon(Icons.calendar_today_sharp),
            ),
          ),
        ),
      ],
    );

    final pickTime = Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: InputDatePickerFormField(
            fieldLabelText: 'Horário',
            fieldHintText: 'horário da aula',
            keyboardType: TextInputType.datetime,
            firstDate: fDate,
            lastDate: lDate,
            errorFormatText: 'não reconhecido',
            errorInvalidText: 'não válido',
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () async {
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(now),
                );
              },
              icon: const Icon(Icons.watch_later_outlined),
            ),
          ),
        ),
      ],
    );

    return Column(
      children: [
        pickDate,
        pickTime,
      ],
    );
  }
}

class CreateSubjectClass extends StatelessWidget {
  const CreateSubjectClass({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const fYear = 2020;
    const lYear = 2040;

    final inputYear = TextFormField(
      initialValue: '${now.year}',
      keyboardType: TextInputType.number,
      maxLength: 4,
      validator: (input) {
        final valueClear = input?.trim();
        if (valueClear == null) {
          return 'Entre um ano';
        } else if (valueClear.characters.length < 4 ||
            valueClear.characters.length > 4) {
          return 'O ano deve ter 4 digitos';
        } else {
          final valueNum = int.tryParse(valueClear);
          if (valueNum == null) {
            return 'Entre apenas dígitos';
          } else if (valueNum < fYear || valueNum > lYear) {
            return '$fYear <= ano <= $lYear';
          }
        }
        return null;
      },
    );
    final inputSemester = Selector(options: const [1, 2]);

    return Row(
      children: [
        Expanded(flex: 3, child: inputYear),
        const Spacer(flex: 1,),
        Expanded(flex: 3, child: inputSemester),
      ],
    );
  }
}

class CreateTeacher extends StatelessWidget {
  const CreateTeacher({super.key});

  @override
  Widget build(BuildContext context) {
    final inputRegistration = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Código',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );
    final inputIndividualRegistration = TextFormField(
      decoration: const InputDecoration(
        labelText: 'CPF',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );
    final inputName = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Nome',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'não pode ser vazio';
        }
        return null;
      },
    );
    final inputSurname = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Sobrenome',
        helperText: 'opcional'
      ),
    );

    return Column(
      children: [
        inputRegistration,
        inputName,
        inputSurname,
        inputIndividualRegistration,
      ],
    );
  }
}

class CreateSubject extends StatelessWidget {
  const CreateSubject({super.key});

  @override
  Widget build(BuildContext context) {
    final inputCode = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Código',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'não pode ser vazio';
        }
        return null;
      },
    );

    final inputName = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Nome',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'não pode ser vazio';
        }
        return null;
      },
    );

    return Column(
      children: [
        inputCode,
        inputName,
      ],
    );
  }
}
