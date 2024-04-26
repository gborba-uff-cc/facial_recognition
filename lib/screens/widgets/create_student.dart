import "package:flutter/material.dart";

class CreateStudent extends StatelessWidget {
  const CreateStudent({
    super.key,
    required TextEditingController individualRegistrationController,
    required TextEditingController registrationController,
    required TextEditingController nameController,
    required TextEditingController surnameController,
  })  : _individualRegistrationController = individualRegistrationController,
        _registrationController = registrationController,
        _nameController = nameController,
        _surnameController = surnameController;

  final TextEditingController _individualRegistrationController;
  final TextEditingController _registrationController;
  final TextEditingController _nameController;
  final TextEditingController _surnameController;

  @override
  Widget build(BuildContext context) {
    final inputRegistration = TextFormField(
      controller: _registrationController,
      decoration: const InputDecoration(
        labelText: 'Matrícula',
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

    final inputIndividualRegistration = TextFormField(
      controller: _individualRegistrationController,
      decoration: const InputDecoration(
        labelText: 'CPF',
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

    final inputSurname = TextFormField(
      controller: _surnameController,
      decoration: const InputDecoration(
        labelText: 'Sobrenome',
        helperText: 'opcional'
      ),
    );

    return Column(
      children: [
        inputRegistration,
        inputName,
        inputSurname,
        inputIndividualRegistration,
      ],
    );
  }
}
