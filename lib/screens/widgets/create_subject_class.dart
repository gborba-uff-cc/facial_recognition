import 'package:facial_recognition/screens/widgets/selector.dart';
import 'package:flutter/material.dart';

// TODO - deixar de usar Selector
class CreateSubjectClass extends StatelessWidget {
  const CreateSubjectClass({
    super.key,
    required void Function(String? year) onYearSaved,
    required void Function(String? semester) onSemesterSaved,
  })  : _onYearSaved = onYearSaved,
        _onSemesterSaved = onSemesterSaved;

  final void Function(String? year) _onYearSaved;
  final void Function(String? semester) _onSemesterSaved;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const fYear = 2020;
    const lYear = 2040;

    final inputYear = TextFormField(
      initialValue: '${now.year}',
      keyboardType: TextInputType.number,
      maxLength: 4,
      validator: (input) {
        final valueClear = input?.trim();
        if (valueClear == null) {
          return 'Entre um ano';
        } else if (valueClear.characters.length < 4 ||
            valueClear.characters.length > 4) {
          return 'O ano deve ter 4 digitos';
        } else {
          final valueNum = int.tryParse(valueClear);
          if (valueNum == null) {
            return 'Entre apenas dígitos';
          } else if (valueNum < fYear || valueNum > lYear) {
            return '$fYear <= ano <= $lYear';
          }
        }
        return null;
      },
      onSaved: _onYearSaved,
    );
    final inputSemester = Selector(options: const [1, 2], selectedOption: null,);

    return Row(
      children: [
        Expanded(flex: 3, child: inputYear),
        const Spacer(flex: 1,),
        Expanded(flex: 3, child: inputSemester),
      ],
    );
  }
}
