import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/use_case/attendance_summary.dart';
import 'package:flutter/material.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  factory AttendanceSummaryScreen({
    Key? key,
    required AttendanceSummary useCase,
  }) =>
      AttendanceSummaryScreen._private(
        key: key,
        useCase: useCase,
        summary: useCase.getSubjectClassAttendance(),
        facePicture: useCase.getStudentFaceImage(),
      );

  const AttendanceSummaryScreen._private({
    super.key,
    required this.useCase,
    required Map<Student, List<Attendance>> summary,
    required Map<Student, FacePicture?> facePicture,
  })  : _summary = summary,
        _facePicture = facePicture;

  final AttendanceSummary useCase;
  final Map<Student, List<Attendance>> _summary;
  final Map<Student, FacePicture?> _facePicture;

  @override
  Widget build(BuildContext context) {
    final summary = _summary.entries;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Presenças',
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineLarge,
          overflow: TextOverflow.fade,
        ),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 300,
          maxWidth: 600,
        ),
        child: summary.isEmpty
            ? const Center(
                child: Text('Não há alunos na turma'),
              )
            : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  itemCount: summary.length,
                  itemBuilder: (context, index) {
                    final element = summary.elementAt(index);
                    final picture = _facePicture[element.key];
                    final leadingWidget = picture == null ? const Icon(Icons.person) : Image.memory(picture.faceJpeg, fit: BoxFit.cover,);
                    final textTheme = Theme.of(context).textTheme;
                    const cardHeight = 100.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
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
                            padding: const EdgeInsets.fromLTRB(8.0,4.0,8.0,0.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                element.key.individual.displayFullName,
                                style: textTheme.titleMedium,
                              ),
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.fromLTRB(8.0,0.0,8.0,4.0),
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
                            child: Flexible(
                              fit: FlexFit.tight,
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
                      ),
                    );
                  },
                ),
            ),
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