import "package:flutter/material.dart";

class CreateSubject extends StatelessWidget {
  const CreateSubject({
    super.key,
    required TextEditingController codeController,
    required TextEditingController nameController,
  })  : _codeController = codeController,
        _nameController = nameController;

  final TextEditingController _codeController;
  final TextEditingController _nameController;

  @override
  Widget build(BuildContext context) {
    final inputCode = TextFormField(
      controller: _codeController,
      decoration: const InputDecoration(
        labelText: 'Código',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );

    final inputName = TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: 'Nome',
        helperText: '',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
    );

    return Column(
      children: [
        inputCode,
        inputName,
      ],
    );
  }
}
