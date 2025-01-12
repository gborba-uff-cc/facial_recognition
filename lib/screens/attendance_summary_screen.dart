import 'dart:typed_data';

import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/common/app_defaults.dart';
import 'package:facial_recognition/use_case/attendance_summary.dart';
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
    // no need to get all of these values on every build
    final classAttendance = useCase.classAttendance.entries.toList()
      ..sort(
        (a, b) => a.key.individual.displayFullName
            .compareTo(b.key.individual.displayFullName),
      );
    final nRegisteredLessons = useCase.nRegisteredLessons;
    final nPastLessons = useCase.nPastLessons;
    final pastLessons = useCase.pastLessons;
    final lastLesson = useCase.lastLesson;
    final nAbsentsLastLesson = useCase.nAbsentsLastLesson;
    final pictureOfFaces = useCase.studentsFaceImage;
    final nInsufficiency = useCase.nInsufficiencyAttendanceRatio;
    final minimumAttendaceRatio = useCase.minimumAttendaceRatio;
    final classNumberFacialData = useCase.studentsNumberFacialData;

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
            final studentAndAttendance = classAttendance.elementAt(indexGenerated);
            final picture = pictureOfFaces[studentAndAttendance.key];
            final presenceCount = studentAndAttendance.value.length;
            final studentNumberRegisteredFacialData = classNumberFacialData[studentAndAttendance.key];
            final absentOnLastLesson = lastLesson == null
                    ? false
                    : !studentAndAttendance.value
                        .map(
                          (e) => e.lesson,
                        )
                        .contains(lastLesson);
            return Padding(
              padding: const EdgeInsets.only(bottom: itemsSpace),
              child: _SummaryTile(
                key: ObjectKey(studentAndAttendance.key),
                faceJpeg: picture?.faceJpeg,
                studentName: studentAndAttendance.key.individual.displayFullName,
                studentRegistration: studentAndAttendance.key.registration,
                absentOnLastLesson: absentOnLastLesson,
                absentCount: nPastLessons - presenceCount,
                presenceCount: presenceCount,
                attendanceRatio: nPastLessons < 1 ? 1 : presenceCount / nPastLessons,
                attendanceMinimumRatio: minimumAttendaceRatio,
                numberFacialDataResgistered: studentNumberRegisteredFacialData,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    final attendance = studentAndAttendance.value;
                    final lessonsAttended =
                        attendance.map((e) => e.lesson).toList();
                    final lessonsNotAttended = (List.of(pastLessons)
                          ..removeWhere(
                            (element) => lessonsAttended.contains(element),
                          ))
                        .toList();
                    return _SummaryDetailedDialog(
                      faceJpeg: picture?.faceJpeg,
                      studentName: studentAndAttendance.key.individual.displayFullName,
                      studentRegistration: studentAndAttendance.key.registration,
                      numberFacialDataResgistered: studentNumberRegisteredFacialData,
                      absentOnLastLesson: absentOnLastLesson,
                      absentCount: nPastLessons - presenceCount,
                      presenceCount: presenceCount,
                      attendanceRatio: presenceCount / nPastLessons,
                      attendanceMinimumRatio: minimumAttendaceRatio,
                      lessonsAttended: attendance,
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
    final now = dateTimeToString2(DateTime.now());
    final outputPath = await pkg_picker.FilePicker.platform.saveFile(
      fileName: 'presencas_geradas_$now.xlsx',
      bytes: Uint8List.fromList(fileContent),
      type: pkg_picker.FileType.custom,
      allowedExtensions: ['xlsx'],
    );
    if (outputPath == null) {
      return;
    }
  }
}

enum _FrequencyStatus {
  insufficient,
  present,
  absent,
}

_FrequencyStatus _getFrequencyStatus({
  required final double actualRatio,
  required final double minimumAttendanceRatio,
  required final bool absentOnLastLesson,
}) {
  if (actualRatio < minimumAttendanceRatio) {
    return _FrequencyStatus.insufficient;
  }
  else if (absentOnLastLesson) {
    return _FrequencyStatus.absent;
  }
  else {
    return _FrequencyStatus.present;
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
    required this.numberFacialDataResgistered,
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
  final int numberFacialDataResgistered;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final jpeg = faceJpeg;
    final absentCount = this.absentCount;
    final titleMediumTheme = Theme.of(context).textTheme.titleMedium;

    final attendanceStatus = _getFrequencyStatus(
      actualRatio: attendanceRatio,
      minimumAttendanceRatio: attendanceMinimumRatio,
      absentOnLastLesson: absentOnLastLesson,
    );
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
    return AppDefaultSingleOptionCard(
      option: 'Detalhar',
      onOptionTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  fit: FlexFit.tight,
                  child: _StudentNameAndRegistrationView(
                    name: studentName,
                    registration: studentRegistration,
                  ),
                ),
                _FacialDataDisplayBadge(
                  numberRegistered: numberFacialDataResgistered,
                ),
              ],
            ),
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
              child: _AttendanceFrequecyStatusDisplay(status: attendanceStatus,),
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
    required this.numberFacialDataResgistered,
    required this.absentOnLastLesson,
    required this.absentCount,
    required this.presenceCount,
    required this.attendanceRatio,
    required this.attendanceMinimumRatio,
    required this.lessonsAttended,
    required this.lessonsNotAttended,
  });

  final JpegPictureBytes? faceJpeg;
  final String studentName;
  final String studentRegistration;
  final int numberFacialDataResgistered;
  final bool absentOnLastLesson;
  final int absentCount;
  final int presenceCount;
  final double attendanceRatio;
  final double attendanceMinimumRatio;
  final List<Attendance> lessonsAttended;
  final List<Lesson> lessonsNotAttended;

  @override
  Widget build(BuildContext context) {
    final jpeg = faceJpeg;
    final absentCount = this.absentCount;
    final titleMediumStyle = Theme.of(context).textTheme.titleMedium;
    final bodyLargeStyle = Theme.of(context).textTheme.bodyLarge;
    final attendanceStatus = _getFrequencyStatus(
      actualRatio: attendanceRatio,
      minimumAttendanceRatio: attendanceMinimumRatio,
      absentOnLastLesson: absentOnLastLesson,
    );

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: ListView(
          children: [
            _StudentNameAndRegistrationView(
              name: studentName,
              registration: studentRegistration,
            ),
            Row(
              children: [
                Text(
                  'Dados facias: ',
                  style: titleMediumStyle,
                ),
                Text('$numberFacialDataResgistered',style: bodyLargeStyle,),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
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
            Center(
              child: Text(
                'Frequência: ${(attendanceRatio * 100).toInt()}%',
                style: bodyLargeStyle,
              ),
            ),
            _AttendanceFrequecyStatusDisplay(status: attendanceStatus),
            ExpansionTile(
              initiallyExpanded: false,
              title: Text('Ausência: $absentCount', style: titleMediumStyle,),
              children: [
                if (lessonsNotAttended.isNotEmpty)
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: Center(
                          child: Text('Aula', style: bodyLargeStyle),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: SizedBox.shrink(),
                      ),
                    ],
                  ),
                ...lessonsNotAttended.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Center(
                            child: Text(
                              dateTimeToString(e.utcDateTime.toLocal()),
                            ),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: SizedBox.shrink(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              initiallyExpanded: false,
              title: Text('Presença: $presenceCount', style: titleMediumStyle,),
              children: [
                if (lessonsAttended.isNotEmpty)
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: Center(
                          child: Text('Aula', style: bodyLargeStyle),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Center(
                          child: Text('Presença', style: bodyLargeStyle),
                        ),
                      ),
                    ],
                  ),
                ...lessonsAttended.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0) +
                        const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                          fit: FlexFit.tight,
                          child: Center(
                            child: Text(
                              dateTimeToString(e.lesson.utcDateTime.toLocal()),
                            ),
                          ),
                        ),
                        Flexible(
                          fit: FlexFit.tight,
                          child: Center(
                            child: Text(
                              dateTimeToString(e.utcDateTime.toLocal()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _AttendanceFrequecyStatusDisplay extends StatelessWidget {
  final _FrequencyStatus status;

  const _AttendanceFrequecyStatusDisplay({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final headlineSmallTheme = Theme.of(context).textTheme.headlineSmall;
    final titleMediumTheme = Theme.of(context).textTheme.titleMedium;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: icon,
            ),
            Text(
              displayName,
              style: headlineSmallTheme,
            ),
          ],
        ),
        Text(
          status == _FrequencyStatus.insufficient ? '' : 'na última aula',
          style: titleMediumTheme,
        ),
      ],
    );
  }

  Icon get icon {
    return switch (status) {
      _FrequencyStatus.insufficient => Icon(Icons.cancel, color: Colors.red),
      _FrequencyStatus.absent => Icon(Icons.circle_outlined),
      _FrequencyStatus.present => Icon(Icons.check_circle, color: Colors.green),
    };
  }
  String get displayName {
    return switch (status) {
      _FrequencyStatus.insufficient => 'Frequencia insuficiente',
      _FrequencyStatus.absent => 'Ausente',
      _FrequencyStatus.present => 'Presente',
    };
  }
}

class _FacialDataDisplayBadge extends StatelessWidget {
  final int numberRegistered;

  const _FacialDataDisplayBadge({
    super.key,
    required this.numberRegistered,
  });

  @override
  Widget build(BuildContext context) {
    return Badge.count(
      count: numberRegistered,
      backgroundColor:
          numberRegistered < 1 ? Colors.red : Colors.green,
      child: Icon(Icons.tag_faces),
    );
  }
}

class _StudentNameAndRegistrationView extends StatelessWidget {
  final String name;
  final String registration;

  const _StudentNameAndRegistrationView({
    super.key,
    required this.name,
    required this.registration,
  });

  @override
  Widget build(BuildContext context) {
    final titleLargeStyle = Theme.of(context).textTheme.titleLarge;
    final titleMediumStyle = Theme.of(context).textTheme.titleMedium;
    final bodyLargeStyle = Theme.of(context).textTheme.bodyLarge;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: titleLargeStyle,
        ),
        Row(
          children: [
            Text(
              'Matrícula: ',
              style: titleMediumStyle,
            ),
            Text(registration, style: bodyLargeStyle,),
          ],
        ),
      ],
    );
  }
}
