import 'package:flutter/material.dart';

class MarkAttendance extends StatelessWidget {
  const MarkAttendance({super.key, List<String> list = const ['a','b','c'] }): _list = list;

  final List<String> _list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemBuilder: (buildContext, i) => const LimitedBox(
          maxHeight: 150,
          child: MarkAttendanceFacialCard(),
        ),
        itemCount: _list.length,
      ),
    );
  }
}

class MarkAttendanceFacialCard extends StatelessWidget {
  const MarkAttendanceFacialCard({super.key, this.item = ''});

  final String item;

  @override
  Widget build(BuildContext context) {
    final columnDetected = Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Flexible(
          child: Text(
            'detectado',
            maxLines: 1,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Icon(Icons.person),
        ),
      ],
    );
    final columnRegistered = Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Flexible(
          child: Text(
            'cadastrado',
            maxLines: 1,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Icon(Icons.person),
        ),
      ],
    );
    final columnActions = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            '$item Está correto?',
            maxLines: 1,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Flexible(
                child: TextButton(
                  onPressed: null,
                  child: Text('Sim'),
                ),
              ),
              Flexible(
                child: TextButton(
                  onPressed: null,
                  child: Text('Não'),
                ),
              ),
            ],
          ),
        )
      ],
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(fit: FlexFit.tight, child: columnDetected),
        Flexible(fit: FlexFit.tight, child: columnRegistered),
        Flexible(flex: 2, fit: FlexFit.tight, child: columnActions),
      ],
    );
  }
}
