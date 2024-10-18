import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/use_case/attendance_summary.dart';
import 'package:facial_recognition/utils/ui.dart';
import 'package:flutter/material.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  const AttendanceSummaryScreen({
    super.key,
    required this.useCase,
  });

  final AttendanceSummary useCase;

  @override
  Widget build(BuildContext context) {
    final classAttendance = useCase.classAttendance.entries;
    final nRegisteredLessons = useCase.nRegisteredLessons;
    final nPastLessons = useCase.nPastLessons;
    final lastLesson = useCase.lastLesson;
    final nAbsentsLastLesson = useCase.nAbsentsLastLesson;
    final pictureOfFaces = useCase.studentsFaceImage;
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
                      :  'Aula em ${dateTimeToString(lastLesson.utcDateTime.toLocal())}',
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
                      final leadingWidget = picture == null
                          ? const Icon(Icons.person)
                          : Image.memory(
                              picture.faceJpeg,
                              fit: BoxFit.cover,
                            );
                      final textTheme = Theme.of(context).textTheme;
                      const cardHeight = 100.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints.loose(
                            const Size.fromHeight(cardHeight),
                          ),
                          child: CustomTile(
                            leading: AspectRatio(
                              aspectRatio: 1,
                              child: leadingWidget,
                            ),
                            title: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  element.key.individual.displayFullName,
                                  style: textTheme.titleMedium,
                                ),
                              ),
                            ),
                            subtitle: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  element.key.registration,
                                ),
                              ),
                            ),
                            trailing: SizedBox(
                              width: 60.0,
                              height: cardHeight,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    element.value.length.toString(),
                                    style: textTheme.headlineSmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.clip,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class CustomTile extends StatelessWidget {
  const CustomTile({super.key, this.leading, this.title, this.subtitle, this.trailing});

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: const BeveledRectangleBorder(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (leading != null) leading!,
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null) title!,
                if (subtitle != null) subtitle!,
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}