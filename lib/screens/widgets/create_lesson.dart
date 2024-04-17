import 'package:flutter/material.dart';

class CreateLesson extends StatelessWidget {
  const CreateLesson({
    super.key,
    required void Function(DateTime date) onDateSaved,
    required void Function(DateTime time) onTimeSaved,
  })  : _onDateSaved = onDateSaved,
        _onTimeSaved = onTimeSaved;

  final void Function(DateTime date) _onDateSaved;
  final void Function(DateTime time) _onTimeSaved;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fDate = DateTime(2024, 01, 01);
    final lDate = DateTime(2024, 12, 31, 23, 59, 59);

    final pickDate = Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: InputDatePickerFormField(
            fieldLabelText: 'Data',
            fieldHintText: 'Data da aula',
            keyboardType: TextInputType.datetime,
            firstDate: fDate,
            lastDate: lDate,
            errorFormatText: 'não reconhecida',
            errorInvalidText: 'não válida',
            onDateSaved: _onDateSaved,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: fDate,
                  lastDate: lDate,
                );
              },
              icon: const Icon(Icons.calendar_today_sharp),
            ),
          ),
        ),
      ],
    );

    final pickTime = Row(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: InputDatePickerFormField(
            fieldLabelText: 'Horário',
            fieldHintText: 'horário da aula',
            keyboardType: TextInputType.datetime,
            firstDate: fDate,
            lastDate: lDate,
            errorFormatText: 'não reconhecido',
            errorInvalidText: 'não válido',
            onDateSaved: _onTimeSaved,
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () async {
                final selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(now),
                );
              },
              icon: const Icon(Icons.watch_later_outlined),
            ),
          ),
        ),
      ],
    );

    return Column(
      children: [
        pickDate,
        pickTime,
      ],
    );
  }
}
