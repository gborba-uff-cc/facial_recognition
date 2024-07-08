import 'package:facial_recognition/use_case/attendance_summary.dart';
import 'package:flutter/material.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  const AttendanceSummaryScreen({
    super.key,
    required this.useCase,
  });

  final AttendanceSummary useCase;

  @override
  Widget build(BuildContext context) {
    final attendance = useCase.getSubjectClassAttendance()?.entries;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Resumo',
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineLarge,
          overflow: TextOverflow.fade,
        ),
      ),
      body: attendance == null || attendance.isEmpty
          ? const Center(
              child: Text('Não há alunos na turma'),
            )
          : ListView.builder(
              itemCount: attendance.length,
              itemBuilder: (context, index) {
                final element = attendance.elementAt(index);
                return ListTile(
                  title: Text(element.key.individual.displayFullName),
                  subtitle: Text(element.key.registration),
                  trailing: Text('${element.value.length}'),
                  dense: true,
                );
              },
            ),
    );
  }
}
