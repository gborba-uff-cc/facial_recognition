import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/use_case/attendance_summary.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:facial_recognition/utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as pkg_picker;

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
    final pastLessons = useCase.pastLessons;
    final lastLesson = useCase.lastLesson;
    final nAbsentsLastLesson = useCase.nAbsentsLastLesson;
    final pictureOfFaces = useCase.studentsFaceImage;
    final nInsufficiency = useCase.nInsufficiencyAttendanceRatio;
    final minimumAttendaceRatio = useCase.minimumAttendaceRatio;

    const itemsSpace = 8.0;

    final List<Widget> prebuilt = [
      Padding(
        padding: const EdgeInsets.only(bottom: itemsSpace),
        child: Text(
          'Resumo',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: itemsSpace),
        child: Column(
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
                '$nInsufficiency aluno${nInsufficiency == 1 ? '' : 's'}(a${nInsufficiency == 1 ? '' : 's'}) com frequência menor que ${(minimumAttendaceRatio*100).toInt()}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: itemsSpace),
        child: Column(
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
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: itemsSpace),
        child: Column(
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
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: itemsSpace),
        child: Column(
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
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: itemsSpace),
        child: Column(
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
      ),
      Padding(
        padding: const EdgeInsets.only(top: itemsSpace, bottom: itemsSpace),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Acompanhamento',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    ];

    return AppDefaultMenuScaffold(
      appBar: AppDefaultAppBar(
        title: 'Presenças',
        actions: [
          IconButton(
            onPressed: () async => await _askToExport(),
            icon: Icon(Icons.share),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: prebuilt.length + classAttendance.length,
        itemBuilder: (context, index) {
          if (index < prebuilt.length) {
            return prebuilt[index];
          }
          else {
            final indexGenerated = index - prebuilt.length;
            final element = classAttendance.elementAt(indexGenerated);
            final picture = pictureOfFaces[element.key];
            final presenceCount = element.value.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: itemsSpace),
              child: _SummaryTile(
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
                attendanceMinimumRatio: useCase.minimumAttendaceRatio,
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
                            (element) => lessonsAttended.contains(element),
                          ))
                        .toList();
                    return _SummaryDetailedDialog(
                      faceJpeg: picture?.faceJpeg,
                      studentName: element.key.individual.displayFullName,
                      studentRegistration: element.key.registration,
                      absentCount: nPastLessons - presenceCount,
                      presenceCount: presenceCount,
                      attendanceRatio: presenceCount / nPastLessons,
                      lessonsAttended: lessonsAttended,
                      lessonsNotAttended: lessonsNotAttended,
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<void> _askToExport() async {
    // return null if user cancel the exportation
    final fileContent = useCase.attendanceAsSpreadsheet();
    final outputPath = await pkg_picker.FilePicker.platform.saveFile(
      fileName: 'presencas_geradas.xlsx',
      bytes: Uint8List.fromList(fileContent),
      type: pkg_picker.FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (outputPath == null) {
      return;
    }
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
    final headlineSmallTheme = Theme.of(context).textTheme.headlineSmall;
/*
  null  --> 'Frequência insuficiente';
  false --> 'Ausente'
  true  --> 'Presente'
 */
    final bool? attendanceStatus = attendanceRatio < attendanceMinimumRatio
        ? null
        : absentOnLastLesson
            ? false
            : true;
    final Icon attenadanceStatusIcon = switch (attendanceStatus) {
      null => Icon(Icons.cancel, color: Colors.red),
      false => Icon(Icons.circle_outlined),
      true => Icon(Icons.check_circle, color: Colors.green),
    };
    final String attendanceStatusName = switch (attendanceStatus) {
      null => 'Frequência insuficiente',
      false => 'Ausente',
      true => 'Presente',
    };
    final imageView = DecoratedBox(
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
    );
    final nameAndRegistrationView = Column(
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
      ],
    );
    final attendanceView = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ausências: $absentCount',
          style: titleMediumTheme,
        ),
        Text(
          'Presenças: $presenceCount',
          style: titleMediumTheme,
        ),
        Text(
          'Frequência: ${(attendanceRatio * 100).toInt()}%',
          style: titleMediumTheme,
        ),
      ],
    );
    final statusView = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: attenadanceStatusIcon,
            ),
            Text(
              attendanceStatusName,
              style: headlineSmallTheme,
            ),
          ],
        ),
        Text(
          attendanceStatus == null ? '' : 'na última aula',
          style: titleMediumTheme,
        ),
      ],
    );
    return AppDefaultSingleOptionCard(
      actionName: 'Detalhar',
      action: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          nameAndRegistrationView,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Flexible(fit: FlexFit.tight, flex: 1, child: imageView),
                Flexible(
                  fit: FlexFit.tight,
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: attendanceView,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0) +
                EdgeInsets.only(bottom: 8.0),
            child: statusView,
          ),
        ],
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
