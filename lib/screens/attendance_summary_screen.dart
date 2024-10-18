import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/screens/common/card_single_action.dart';
import 'package:facial_recognition/use_case/attendance_summary.dart';
import 'package:facial_recognition/utils/ui.dart';
import 'package:flutter/material.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  const AttendanceSummaryScreen({
    super.key,
    required this.useCase,
  });

  final AttendanceSummary useCase;
  static const double attendanceMinimumRatio = 0.7;

  @override
  Widget build(BuildContext context) {
    final classAttendance = useCase.classAttendance.entries;
    final nRegisteredLessons = useCase.nRegisteredLessons;
    final nPastLessons = useCase.nPastLessons;
    final pastLessons = useCase.pastLessons;
    final lastLesson = useCase.lastLesson;
    final nAbsentsLastLesson = useCase.nAbsentsLastLesson;
    final pictureOfFaces = useCase.studentsFaceImage;
    final nInsufficiency = useCase.nInsufficiencyAttendanceRatio;
    return AppDefaultMenuScaffold(
      appBar: AppDefaultAppBar(title: 'Presenças'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Resumo',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Insuficiências',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  '$nInsufficiency aluno${nInsufficiency == 1 ? '' : 's'}(a${nInsufficiency == 1 ? '' : 's'}) com frequência insuficiente',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ausências',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  '$nAbsentsLastLesson aluno${nAbsentsLastLesson == 1 ? '' : 's'}(a${nAbsentsLastLesson == 1 ? '' : 's'}) não ${nAbsentsLastLesson == 1 ? 'compareceu' : 'compareceram'} na última aula',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Última aula',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  lastLesson == null
                      ? 'Nenhuma aula ministrada'
                      : 'Aula em ${dateTimeToString(lastLesson.utcDateTime.toLocal())}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aulas até agora',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  '$nPastLessons aula${nPastLessons == 1 ? '' : 's'} ${nPastLessons == 1 ? 'foi' : 'foram'} ministrada${nPastLessons == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Aulas cadastradas',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text(
                  '$nRegisteredLessons aula${nRegisteredLessons == 1 ? '' : 's'} ${nRegisteredLessons == 1 ? 'foi' : 'foram'} cadastrada${nRegisteredLessons == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Acompanhamento',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: classAttendance.isEmpty
                ? const Center(
                    child: Text('Não há alunos na turma'),
                  )
                : ListView.builder(
                    itemCount: classAttendance.length,
                    itemBuilder: (context, index) {
                      final element = classAttendance.elementAt(index);
                      final picture = pictureOfFaces[element.key];
                      final presenceCount = element.value.length;
                      return _SummaryTile(
                        key: ObjectKey(element.key),
                        faceJpeg: picture?.faceJpeg,
                        studentName: element.key.individual.displayFullName,
                        studentRegistration: element.key.registration,
                        absentOnLastLesson: lastLesson == null
                            ? false
                            : !element.value
                                .map(
                                  (e) => e.lesson,
                                )
                                .contains(lastLesson),
                        absentCount: nPastLessons - presenceCount,
                        presenceCount: presenceCount,
                        attendanceRatio: presenceCount / nPastLessons,
                        attendanceMinimumRatio: attendanceMinimumRatio,
                        onTap: () => showDialog(
                            context: context,
                            builder: (context) {
                              final lessonsAttended = element.value
                                  .map(
                                    (e) => e.lesson,
                                  )
                                  .toList();
                              final lessonsNotAttended = (List.of(pastLessons)
                                    ..removeWhere(
                                      (element) =>
                                          lessonsAttended.contains(element),
                                    ))
                                  .toList();
                              return _SummaryDetailedDialog(
                                faceJpeg: picture?.faceJpeg,
                                studentName:
                                    element.key.individual.displayFullName,
                                studentRegistration: element.key.registration,
                                absentCount: nPastLessons - presenceCount,
                                presenceCount: presenceCount,
                                attendanceRatio: presenceCount / nPastLessons,
                                lessonsAttended: lessonsAttended,
                                lessonsNotAttended: lessonsNotAttended,
                              );
                            }),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    super.key,
    required this.faceJpeg,
    required this.studentName,
    required this.studentRegistration,
    required this.absentOnLastLesson,
    required this.absentCount,
    required this.presenceCount,
    required this.attendanceRatio,
    required this.attendanceMinimumRatio,
    this.onTap,
  });

  final JpegPictureBytes? faceJpeg;
  final String studentName;
  final String studentRegistration;
  final bool absentOnLastLesson;
  final int absentCount;
  final int presenceCount;
  final double attendanceRatio;
  final double attendanceMinimumRatio;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final jpeg = faceJpeg;
    final absentCount = this.absentCount;
    final titleMediumTheme = Theme.of(context).textTheme.titleMedium;
    final titleLargeTheme = Theme.of(context).textTheme.titleLarge;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SingleActionCard(
        action: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              studentName,
              style: titleLargeTheme,
            ),
            Text(
              'Matrícula: $studentRegistration',
              style: titleMediumTheme,
            ),
            Divider(),
            Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: DividerTheme.of(context).color ??
                              Theme.of(context).dividerColor),
                    ),
                    position: DecorationPosition.foreground,
                    child: AspectRatio(
                      aspectRatio: 2 / 2,
                      child: jpeg == null
                          ? const Icon(Icons.person)
                          : Image.memory(
                              jpeg,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                Flexible(
                  fit: FlexFit.tight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ausência: $absentCount',
                          style: titleMediumTheme,
                        ),
                        Text(
                          'Presença: $presenceCount',
                          style: titleMediumTheme,
                        ),
                        Text(
                          'Frequência: ${(attendanceRatio * 100).toInt()}%',
                          style: titleMediumTheme,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            Align(
              alignment: Alignment.center,
              child: Text(
                attendanceRatio < attendanceMinimumRatio
                    ? 'Frequência insuficiente'
                    : absentOnLastLesson
                        ? 'Ausente'
                        : 'Presente',
                style: titleLargeTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryDetailedDialog extends StatelessWidget {
  const _SummaryDetailedDialog({
    super.key,
    required this.faceJpeg,
    required this.studentName,
    required this.studentRegistration,
    required this.absentCount,
    required this.presenceCount,
    required this.attendanceRatio,
    required this.lessonsAttended,
    required this.lessonsNotAttended,
  });

  final JpegPictureBytes? faceJpeg;
  final String studentName;
  final String studentRegistration;
  final int absentCount;
  final int presenceCount;
  final double attendanceRatio;
  final List<Lesson> lessonsAttended;
  final List<Lesson> lessonsNotAttended;

  @override
  Widget build(BuildContext context) {
    final jpeg = faceJpeg;
    final absentCount = this.absentCount;
    final titleMediumTheme = Theme.of(context).textTheme.titleMedium;
    final titleLargeTheme = Theme.of(context).textTheme.titleLarge;

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: ListView(
          children: [
            Text(
              studentName,
              style: titleLargeTheme,
            ),
            Text(
              'Matrícula: $studentRegistration',
              style: titleMediumTheme,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                    color: DividerTheme.of(context).color ??
                        Theme.of(context).dividerColor),
              ),
              position: DecorationPosition.foreground,
              child: AspectRatio(
                aspectRatio: 2 / 2,
                child: jpeg == null
                    ? const Icon(Icons.person)
                    : Image.memory(
                        jpeg,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            ListTile(title: Center(child: Text('Frequência: ${(attendanceRatio * 100).toInt()}%')),),
            ExpansionTile(
              initiallyExpanded: false,
              title: Text('Ausência: $absentCount'),
              children: lessonsNotAttended
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        dateTimeToString(
                          e.utcDateTime.toLocal(),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            ExpansionTile(
              initiallyExpanded: false,
              title: Text('Presença: $presenceCount'),
              children: lessonsAttended
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        dateTimeToString(
                          e.utcDateTime.toLocal(),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            )
          ],
        ),
      ),
    );
  }
}
