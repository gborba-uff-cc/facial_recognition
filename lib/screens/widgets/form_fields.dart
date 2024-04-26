import 'package:flutter/material.dart';

abstract class _TextField extends StatelessWidget {
  const _TextField({
    super.key,
    required this.controller,
    required String labelText,
    required String helperText,
  }) : _labelText = labelText,
       _helperText = helperText;

  final TextEditingController controller;
  final String _labelText;
  final String _helperText;
}

class Student_ extends _TextField {
  Student_({
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class TeacherFieldRegistration extends _TextField {
  const TeacherFieldRegistration({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );
  }
}

class SubjectFieldCode extends _TextField {
  const SubjectFieldCode({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );
  }
}

class SubjectClassFieldYear extends _TextField {
  const SubjectClassFieldYear({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    const fYear = 2020;
    const lYear = 2040;

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      keyboardType: TextInputType.number,
      maxLength: 4,
      validator: (input) {
        final valueClear = input?.trim();
        if (valueClear == null) {
          return 'Entre um ano';
        } else if (valueClear.characters.length < 4 ||
            valueClear.characters.length > 4) {
          return 'Deve ter 4 digitos';
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
    );
  }
}

class SubjectClassFieldSemester extends _TextField {
  const SubjectClassFieldSemester({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      keyboardType: TextInputType.number,
      maxLength: 1,
      validator: (input) {
        final valueClear = input?.trim();
        if (valueClear == null || valueClear.characters.isEmpty) {
          return 'Entre um período';
        } else {
          final valueNum = int.tryParse(valueClear);
          if (valueNum == null) {
            return 'Entre apenas dígitos';
          } else if (valueNum < 1) {
            return 'Não válido';
          }
        }
        return null;
      },
    );
  }
}

class SubjectClassFieldName extends _TextField {
  const SubjectClassFieldName({
    super.key,
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: _labelText,
        helperText: _helperText,
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );
  }
}

class Lesson_ extends _TextField {
  Lesson_({
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class Enrollment_ extends _TextField {
  Enrollment_({
    required super.controller,
    required super.labelText,
    required super.helperText,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}