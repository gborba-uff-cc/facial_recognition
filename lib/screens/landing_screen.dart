import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/select_information_return.dart';
import 'package:facial_recognition/screens/widgets/card_single_action.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _menuBtnPadding = EdgeInsets.all(16.0);
const _menuSpacer = SizedBox(height: 16.0);
const _menuBorderRadii = Radius.circular(8.0);

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
    const String attendanceDestinationTitle = 'Acompanhamento';
    final Widget attendanceDestination = Builder(
      builder: (context) {
        return ListView(
          children: [
            Text(
              attendanceDestinationTitle,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineLarge,
              overflow: TextOverflow.fade,
            ),
            _menuSpacer,
            SingleActionCard(
              actionName: 'Selecionar',
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
                          subject?.name ?? '',
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
                          subjectClass?.name ?? '',
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
                          lesson?.utcDateTime.toLocal().toIso8601String() ?? '',
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
            _menuSpacer,
            MenuItem(
              onTap: () => (lesson == null)
                  ? _showAlert(
                      context,
                      Text('Selecione uma aula antes de continuar',
                          style: Theme.of(context).textTheme.bodyLarge),
                    )
                  : GoRouter.of(context).go('/camera_view', extra: lesson),
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Apontamento por câmera'),
              ),
            ),
            _menuSpacer,
            MenuItem(
              onTap: () => (lesson == null)
                  ? _showAlert(
                      context,
                      Text('Selecione uma aula antes de continuar',
                          style: Theme.of(context).textTheme.bodyLarge),
                    )
                  : GoRouter.of(context).go('/mark_attendance', extra: lesson),
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Revisão do apontamento'),
              ),
            ),
            _menuSpacer,
            MenuItem(
              onTap: () => (subjectClass == null)
                  ? _showAlert(
                      context,
                      Text('Selecione uma turma antes de continuar',
                          style: Theme.of(context).textTheme.bodyLarge),
                    )
                  : GoRouter.of(context)
                      .go('/attendance_summary', extra: subjectClass),
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Resumo das presenças'),
              ),
            ),
            _menuSpacer,
          ],
        );
      },
    );

    const String createDestinationTitle = 'Adicionar informações';
    final Widget createDestination = Builder(
      builder: (context) {
        return ListView(
          children: [
            Text(
              createDestinationTitle,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineLarge,
              overflow: TextOverflow.fade,
            ),
            _menuSpacer,
            MenuItem(
              onTap: () => GoRouter.of(context).go('/models_from_xlsx'),
              child: Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Ler do arquivo'),
              ),
            ),
            _menuSpacer,
            MenuItem(
              onTap: () => GoRouter.of(context).go('/create_subject'),
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Disciplina'),
              ),
            ),
            _menuSpacer,
            MenuItem(
              onTap: () => GoRouter.of(context).go('/create_subject_class'),
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Turma'),
              ),
            ),
            _menuSpacer,
            MenuItem(
              onTap: () => GoRouter.of(context).go('/create_lesson'),
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Aula'),
              ),
            ),
            _menuSpacer,
            MenuItem(
              onTap: () => GoRouter.of(context).go('/create_student'),
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Aluno(a)'),
              ),
            ),
            _menuSpacer,
            MenuItem(
              onTap: () => GoRouter.of(context).go('/create_teacher'),
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Professor(a)'),
              ),
            ),
            _menuSpacer,
            MenuItem(
              onTap: () => GoRouter.of(context).go('/create_enrollment'),
              child: const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Inscrição'),
              ),
            ),
            _menuSpacer,
          ],
        );
      },
    );

    final views = <Widget>[
      attendanceDestination,
      createDestination,
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
    return Scaffold(
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
                  Flexible(fit: FlexFit.tight, child: views[_currentViewIndex]),
                ],
              ),
            ),
          ),
        ),
      ),
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
