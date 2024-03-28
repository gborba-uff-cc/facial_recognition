import 'package:facial_recognition/models/domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceholderScreen extends StatefulWidget {
  factory PlaceholderScreen({
    Key? key,
    required DomainRepository domainRepository,
    List<String> nextScreens = const [],
  }) {
    return PlaceholderScreen._private(
      key: key,
      domainRepository: domainRepository,
      nextScreens: nextScreens,
    );
  }

  const PlaceholderScreen._private({
    super.key,
    required this.domainRepository,
    this.nextScreens = const [],
  });

  final DomainRepository domainRepository;
  final List<String> nextScreens;

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  Lesson? lesson;

  @override
  Widget build(BuildContext context) {
    // SECTION - STUB
    final subject = widget.domainRepository
        .getSubjectFromCode(['sCode0'])
        .entries
        .first
        .value;
    final teacher = widget.domainRepository
        .getTeacherFromRegistration(['tReg0'])
        .entries
        .first
        .value;
    final subjectClass = SubjectClass(
        subject: subject!,
        year: 2024,
        semester: 01,
        name: 'Turma A da materia para teste',
        teacher: teacher!);
    lesson = widget.domainRepository
        .getLessonFromSubjectClass([subjectClass])
        .entries
        .first
        .value
        .last;
    // !SECTION

    return Scaffold(
      appBar: AppBar(actions: const [], title: const Text('AppBar')),
      body: Column(
        children: [
          Text('Aula', style: Theme.of(context).textTheme.titleMedium,),
          if (lesson == null) Text('Selecione uma aula'),
          if (lesson != null)
            Text.rich(
              TextSpan(
                text: 'Disciplina:',
                children: [TextSpan(text: lesson!.subjectClass.subject.name)],
              ),
            ),
          if (lesson != null)
            Text.rich(
              TextSpan(
                text: 'Turma:',
                children: [TextSpan(text: lesson!.subjectClass.name)],
              ),
            ),
          if (lesson != null)
            Text.rich(
              TextSpan(
                text: 'Hora da aula:',
                children: [TextSpan(text: lesson!.utcDateTime.toIso8601String())],
              ),
            ),
          const Divider(),
          Flexible(
            fit: FlexFit.tight,
            child: ListView.builder(
              itemCount: widget.nextScreens.length,
              itemBuilder: (buildContext, i) => OutlinedButton(
                child: Text(
                  'go ${widget.nextScreens[i]}',
                  maxLines: 1,
                ),
                onPressed: () {
                  final nextScreen = widget.nextScreens[i];
                  if (!{
                    '/camera_view',
                    '/mark_attendance',
                  }.contains(nextScreen)) {
                    GoRouter.of(context).go(nextScreen);
                  } else {
                    if (lesson != null) {
                      GoRouter.of(context).go(nextScreen, extra: lesson);
                    } else {
                      ScaffoldMessenger.of(context)
                        ..removeCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              'Selecione uma aula para acessar ${widget.nextScreens[i]}',
                            ),
                          ),
                        );
                    }
                  }
                },
              ),
            ),
          ),
        ],
      ),
      endDrawer: const Drawer(child: Text('EndDrawer')),
      floatingActionButton: const FloatingActionButton.extended(
          onPressed: null,
          label: Text('FAB'),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.thumb_down), label: 'BNBI1'),
          BottomNavigationBarItem(icon: Icon(Icons.thumb_up), label: 'BNBI2'),
        ],
      ),
    );
  }
}
