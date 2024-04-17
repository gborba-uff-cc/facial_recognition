import "package:flutter/material.dart";

class CreateSubject extends StatelessWidget {
  const CreateSubject({
    super.key,
    required void Function(String? code) onCodeSaved,
    required void Function(String? name) onNameSaved,
  })  : _onCodeSaved = onCodeSaved,
        _onNameSaved = onNameSaved;

  final void Function(String? code) _onCodeSaved;
  final void Function(String? name) _onNameSaved;

  @override
  Widget build(BuildContext context) {
    final inputCode = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Código',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'não pode ser vazio';
        }
        return null;
      },
      onSaved: _onCodeSaved,
    );

    final inputName = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Nome',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'não pode ser vazio';
        }
        return null;
      },
      onSaved: _onNameSaved,
    );

    return Column(
      children: [
        inputCode,
        inputName,
      ],
    );
  }
}
