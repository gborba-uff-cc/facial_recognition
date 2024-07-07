import 'package:facial_recognition/models/domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _menuBtnPadding = EdgeInsets.all(16.0);
const _menuSpacer = SizedBox(height: 16.0);
const _menuBorderRadii = Radius.circular(8.0);
const _menuDivider = Divider(height: 48.0);

class LandingScreen extends StatefulWidget {
  const LandingScreen({
    super.key,
    required this.domainRepository,
  });

  final DomainRepository domainRepository;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  SubjectClass? subjectClass;
  Lesson? lesson;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 300,
              maxWidth: 600,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
              ),
              child: Column(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    child: ListView(
                      children: [
                        Text(
                          'Acompanhamento',
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineLarge,
                          overflow: TextOverflow.fade,
                        ),
                        _menuSpacer,
                        InkWell(
                          onTap: () async {
                            final aux = await GoRouter.of(context)
                                .push<Lesson?>('/select_lesson');
                            setState(() {
                              lesson = aux;
                            });
                          },
                          child: SelectedInfos(
                            subject: (lesson == null)
                                ? '--'
                                : lesson!.subjectClass.subject.name,
                            subjectClass: (lesson == null)
                                ? '--'
                                : lesson!.subjectClass.name,
                            lesson: (lesson == null)
                                ? '--'
                                : lesson!.utcDateTime.toLocal().toString(),
                          ),
                        ),
                        _menuSpacer,
                        MenuItem(
                          onTap: () => (lesson == null)
                              ? _showLessonRequired(context)
                              : GoRouter.of(context)
                                  .go('/camera_view', extra: lesson),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text('Apontamento por câmera'),
                          ),
                        ),
                        _menuSpacer,
                        MenuItem(
                          onTap: () => (lesson == null)
                              ? _showLessonRequired(context)
                              : GoRouter.of(context)
                                  .go('/mark_attendance', extra: lesson),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text('Revisão do apontamento'),
                          ),
                        ),
                        _menuSpacer,
                        MenuItem(
                          onTap: () => (lesson == null)
                              ? _showLessonRequired(context)
                              : GoRouter.of(context)
                                  .go('/attendance_summary', extra: lesson),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text('Resumo das presenças'),
                          ),
                        ),
                        _menuDivider,
                        Text(
                          'Adicionar',
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineLarge,
                          overflow: TextOverflow.fade,
                        ),
                        _menuSpacer,
                        MenuItem(
                          onTap: () =>
                              GoRouter.of(context).go('/create_models'),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text('Disciplina'),
                          ),
                        ),
                        _menuSpacer,
                        MenuItem(
                          onTap: () =>
                              GoRouter.of(context).go('/create_models'),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text('Turma'),
                          ),
                        ),
                        _menuSpacer,
                        MenuItem(
                          onTap: () =>
                              GoRouter.of(context).go('/create_models'),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text('Aula'),
                          ),
                        ),
                        _menuSpacer,
                        MenuItem(
                          onTap: () =>
                              GoRouter.of(context).go('/create_models'),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text('Aluno'),
                          ),
                        ),
                        _menuSpacer,
                        MenuItem(
                          onTap: () =>
                              GoRouter.of(context).go('/create_models'),
                          child: const Padding(
                            padding: EdgeInsets.only(left: 24.0),
                            child: Text('Professor'),
                          ),
                        ),
                        _menuSpacer,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLessonRequired(BuildContext context) =>
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Selecione uma aula e turma para continuar',
            ),
          ),
        );
}

class SelectedInfos extends StatelessWidget {
  const SelectedInfos({
    super.key,
    required this.subject,
    required this.subjectClass,
    required this.lesson,
  });

  final String subject;
  final String subjectClass;
  final String lesson;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(0.0),
      elevation: 2.0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                Text(
                  'Aula selecionada',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Text(
                      'Disciplina:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          subject,
                          style: Theme.of(context).textTheme.labelMedium,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Turma:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          subjectClass,
                          style: Theme.of(context).textTheme.labelMedium,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      'Aula:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          lesson,
                          style: Theme.of(context).textTheme.labelMedium,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: _menuBtnPadding,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.only(
                bottomLeft: _menuBorderRadii,
                bottomRight: _menuBorderRadii,
              ),
            ),
            child: Center(
              child: Text(
                'Selecionar aula e turma',
                style: Theme.of(context).textTheme.copyWith().apply(
                  fontSizeFactor: 1.2,
                  bodyColor: Theme.of(context).colorScheme.onSecondary).labelLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    this.onTap,
    required this.child,
  });

  final void Function()? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme:
            Theme.of(context).textTheme.copyWith().apply(fontSizeFactor: 1.2),
      ),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(_menuBorderRadii),
          ),
        ),
        child: Padding(
          padding: _menuBtnPadding,
          child: Align(
            alignment: Alignment.centerLeft,
            child: child,
          ),
        ),
      ),
    );
  }
}
