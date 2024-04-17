import "package:flutter/material.dart";

class CreateTeacher extends StatelessWidget {
  const CreateTeacher({
    super.key,
    required void Function(String? individualRegistration) onIndividualRegistrationSaved,
    required void Function(String? registration) onRegistrationSaved,
    required void Function(String? name) onNameSaved,
    required void Function(String? surname) onSurnameSaved,
  })  : _onIndividualRegistrationSaved = onIndividualRegistrationSaved,
        _onNameSaved = onNameSaved,
        _onSurnameSaved = onSurnameSaved,
        _onRegistrationSaved = onRegistrationSaved;

  final void Function(String? individualRegistration) _onIndividualRegistrationSaved;
  final void Function(String? registration) _onRegistrationSaved;
  final void Function(String? name) _onNameSaved;
  final void Function(String? surname) _onSurnameSaved;

  @override
  Widget build(BuildContext context) {
    final inputRegistration = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Código',
        helperText: 'Identificação do professor',
      ),
      validator: (input) {
        final value = input?.trim();
        if (value == null || value.characters.isEmpty) {
          return 'Não pode ser vazio';
        }
        return null;
      },
      onSaved: _onRegistrationSaved,
    );
    final inputIndividualRegistration = TextFormField(
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
      onSaved: _onIndividualRegistrationSaved,
    );
    final inputName = TextFormField(
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
      onSaved: _onNameSaved,
    );
    final inputSurname = TextFormField(
      decoration: const InputDecoration(
        labelText: 'Sobrenome',
        helperText: 'opcional'
      ),
      onSaved: _onSurnameSaved,
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
