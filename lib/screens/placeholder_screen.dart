import 'package:facial_recognition/interfaces.dart';
import 'package:facial_recognition/models/domain.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaceholderScreen extends StatefulWidget {
  factory PlaceholderScreen({
    Key? key,
    required IDomainRepository domainRepository,
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

  final IDomainRepository domainRepository;
  final List<String> nextScreens;

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  Lesson? lesson;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(actions: const [], title: const Text('AppBar')),
      body: Column(
        children: [
          Text('Aula', style: Theme.of(context).textTheme.titleMedium,),
          if (lesson == null) const Text('Selecione uma aula'),
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
                onPressed: () async {
                  final nextScreen = widget.nextScreens[i];
                  // next screen is in the set
                  if ({
                    '/camera_view',
                    '/mark_attendance',
                    '/attendance_summary',
                  }.contains(nextScreen)) {
                    // and a lesson is selected
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
                  else if('/select_lesson' == nextScreen) {
                    lesson = await GoRouter.of(context).push<Lesson?>(nextScreen);
                  }
                  else {
                    GoRouter.of(context).go(nextScreen);
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
