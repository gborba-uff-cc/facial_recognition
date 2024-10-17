import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/screens/common/select_information_return.dart';
import 'package:facial_recognition/screens/common/card_single_action.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({
    super.key,
    required this.domainRepository,
  });

  final IDomainRepository domainRepository;

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  int _currentViewIndex = 0;
  Subject? subject;
  SubjectClass? subjectClass;
  Lesson? lesson;

  @override
  Widget build(BuildContext context) {
    // Acompanhamento ----------------------------------------------------------
    const String attendanceDestinationTitle = 'Acompanhamento';
    final List<({void Function() action, String text})> attendanceTriggers = [
      (
        action: () => (lesson == null)
            ? _showAlert(
                context,
                Text('Selecione uma aula antes de continuar',
                    style: Theme.of(context).textTheme.bodyLarge),
              )
            : GoRouter.of(context).go('/camera_view', extra: lesson),
        text: 'Apontamento por câmera',
      ),
      (
        action: () => (lesson == null)
            ? _showAlert(
                context,
                Text('Selecione uma aula antes de continuar',
                    style: Theme.of(context).textTheme.bodyLarge),
              )
            : GoRouter.of(context).go('/mark_attendance', extra: lesson),
        text: 'Revisão do apontamento',
      ),
      (
        action: () => (subjectClass == null)
            ? _showAlert(
                context,
                Text('Selecione uma turma antes de continuar',
                    style: Theme.of(context).textTheme.bodyLarge),
              )
            : GoRouter.of(context)
                .go('/attendance_summary', extra: subjectClass),
        text: 'Resumo das presenças',
      ),
    ];
    final attendanceMenuItems = [
      _AttendaceMonitorInfos(
        subject: subject?.name ?? '',
        subjectClass: subjectClass?.name ?? '',
        lesson: lesson?.utcDateTime.toLocal().toIso8601String() ?? '',
        action: () async {
          final aux = await GoRouter.of(context)
              .push<SelectInformationReturn>('/select_information');
          setState(() {
            if (aux == null) {
              projectLogger
                  .severe("a value weren't returned from /select_information");
            }
            subject = aux?.subject;
            subjectClass = aux?.subjectClass;
            lesson = aux?.lesson;
          });
        },
      ),
      ...attendanceTriggers.map(
        (destinationTrigger) => AppDefaultButton(
          onTap: destinationTrigger.action,
          child: Padding(
            padding: EdgeInsets.only(left: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(destinationTrigger.text),
            ),
          ),
        ),
      ),
    ];
    final Widget attendanceDestination = Builder(
      builder: (context) {
        return AppDefaultMenuList(children: attendanceMenuItems);
      },
    );

    // Adicionar informacoes ---------------------------------------------------
    const String createDestinationTitle = 'Adicionar informações';
    final List<({void Function() action, String text})> createTriggers = [
      (
        action: () => GoRouter.of(context).go('/create_subject'),
        text: 'Disciplina',
      ),
      (
        action: () => GoRouter.of(context).go('/create_subject_class'),
        text: 'Turma'
      ),
      (
        action: () => GoRouter.of(context).go('/create_lesson'),
        text: 'Aula'
      ),
      (
        action: () => GoRouter.of(context).go('/create_student'),
        text: 'Aluno(a)'
      ),
      (
        action: () => GoRouter.of(context).go('/create_teacher'),
        text: 'Professor(a)'
      ),
      (
        action: () => GoRouter.of(context).go('/create_enrollment'),
        text: 'Inscrição'
      ),
    ];
    final List<Widget> createMenuItems = createTriggers
        .map(
          (destinationTrigger) => AppDefaultButton(
            onTap: destinationTrigger.action,
            child: Padding(
              padding: EdgeInsets.only(left: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(destinationTrigger.text),
              ),
            ),
          ),
        )
        .toList();
    final Widget createDestination = Builder(
      builder: (context) {
        return AppDefaultMenuList(children: createMenuItems);
      },
    );

    final List<({String appBarTitle, Widget widget})> views = [
      (appBarTitle: attendanceDestinationTitle, widget: attendanceDestination),
      (appBarTitle: createDestinationTitle, widget: createDestination),
    ];
    final viewTriggers = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.schedule),
        label: attendanceDestinationTitle,
      ),
      const NavigationDestination(
        icon: Icon(Icons.add),
        label: createDestinationTitle,
      )
    ];
    return AppDefaultMenuScaffold(
      appBar: AppDefaultAppBar(title: views[_currentViewIndex].appBarTitle),
      body: views[_currentViewIndex].widget,
      bottomNavigationBar: NavigationBar(
        destinations: viewTriggers,
        selectedIndex: _currentViewIndex,
        onDestinationSelected: (index) => setState(
          () => _currentViewIndex = index,
        ),
      ),
    );
  }

  void _showAlert(BuildContext context, Widget child) => showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          title: const Text('Ops...'),
          content: child,
          actions: [
            TextButton(
              onPressed: () {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  router.pop();
                }
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
}

class _AttendaceMonitorInfos extends StatelessWidget {
  const _AttendaceMonitorInfos({
    super.key,
    required String subject,
    required String subjectClass,
    required String lesson,
    void Function()? action,
  })  : _subject = subject,
        _subjectClass = subjectClass,
        _lesson = lesson,
        _action = action;

  final String _subject;
  final String _subjectClass;
  final String _lesson;
  final void Function()? _action;

  @override
  Widget build(BuildContext context) {
    return SingleActionCard(
      action: _action,
      actionName: 'Selecionar',
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
                  _subject,
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
                  _subjectClass,
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
                  _lesson,
                  style: Theme.of(context).textTheme.labelMedium,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
