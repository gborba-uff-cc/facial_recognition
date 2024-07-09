import 'package:flutter/material.dart';

/// Button for validate, save (form fields) and run an after save function.
class SubmitFormButton extends StatelessWidget {
  const SubmitFormButton({
    super.key,
    required GlobalKey<FormState> formKey,
    required void Function() action,
  })  : _formKey = formKey,
        _action = action;

  final GlobalKey<FormState> _formKey;
  final void Function() _action;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {
        final formState = _formKey.currentState;
        if (formState!.validate()) {
          _action();
          return;
        }
      },
      child: const Text('Adicionar'),
    );
  }
}