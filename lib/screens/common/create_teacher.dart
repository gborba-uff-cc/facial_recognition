import "package:flutter/material.dart";

class CreateTeacher extends StatefulWidget {
  const CreateTeacher({
    super.key,
    required TextEditingController individualRegistrationController,
    void Function(String?)? individualRegistrationOnSaved,
    required TextEditingController registrationController,
    void Function(String?)? registrationOnSaved,
    required TextEditingController nameController,
    void Function(String?)? nameOnSaved,
    required TextEditingController surnameController,
    void Function(String?)? surnameOnSaved,
  })  : _individualRegistrationController = individualRegistrationController,
        _individualRegistrationOnSaved = individualRegistrationOnSaved,
        _registrationController = registrationController,
        _registrationOnSaved = registrationOnSaved,
        _nameController = nameController,
        _nameOnSaved = nameOnSaved,
        _surnameController = surnameController,
        _surnameOnSaved = surnameOnSaved;

  final TextEditingController _individualRegistrationController;
  final void Function(String?)? _individualRegistrationOnSaved;
  final TextEditingController _registrationController;
  final void Function(String?)? _registrationOnSaved;
  final TextEditingController _nameController;
  final void Function(String?)? _nameOnSaved;
  final TextEditingController _surnameController;
  final void Function(String?)? _surnameOnSaved;

  @override
  State<CreateTeacher> createState() => _CreateTeacherState();
}

class _CreateTeacherState extends State<CreateTeacher> {
  @override
  Widget build(BuildContext context) {

    final inputRegistration = TextFormField(
      controller: widget._registrationController,
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
      onSaved: widget._registrationOnSaved,
    );

    final inputIndividualRegistration = TextFormField(
      controller: widget._individualRegistrationController,
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
      onSaved: widget._individualRegistrationOnSaved,
    );

    final inputName = TextFormField(
      controller: widget._nameController,
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
      onSaved: widget._nameOnSaved,
    );

    final inputSurname = TextFormField(
      controller: widget._surnameController,
      decoration: const InputDecoration(
        labelText: 'Sobrenome',
        helperText: 'opcional'
      ),
      onSaved: widget._surnameOnSaved,
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
