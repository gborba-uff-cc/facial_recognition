import "package:flutter/material.dart";

class Selector<T> extends StatelessWidget {
  factory Selector({
    Key? key,
    String? label,
    required List<T> options,
    required T? selectedOption,
    String? hint,
    String? disabledHint,
    String? Function(T? item)? validator,
    void Function(T? item)? onChanged,
    void Function(T? item)? onSaved,
  }) =>
      Selector._private(
        key: key,
        label: label,
        options: [null, ...options],
        selectedOption: selectedOption,
        hint: hint,
        disabledHint: disabledHint,
        validator: validator,
        onChanged: onChanged,
        onSaved: onSaved,
      );

  const Selector._private({
    key,
    String? label,
    required List<T?> options,
    required T? selectedOption,
    String? hint,
    String? disabledHint,
    String? Function(T?)? validator,
    void Function(T?)? onChanged,
    void Function(T?)? onSaved,
  })  : _key = key,
        _label = label,
        _selectedOption = selectedOption,
        _options = options,
        _hint = hint,
        _disabledHint = disabledHint,
        _validator = validator,
        _onChanged = onChanged,
        _onSaved = onSaved;

  final Key? _key;
  final String? _label;
  final List<T?> _options;
  final T? _selectedOption;
  final String? _hint;
  final String? _disabledHint;
  final String? Function(T? item)? _validator;
  final void Function(T? item)? _onChanged;
  final void Function(T? item)? _onSaved;

  @override
  Widget build(BuildContext context) {
    final items = _options
        .map((item) => DropdownMenuItem(
              key: ValueKey(item),
              value: item,
              child: Text(
                item?.toString() ?? '',
                maxLines: 1,
              ),
            ))
        .toList();

    return DropdownButtonFormField(
      key: _key,
      hint: _hint == null ? null : Text(_hint!),
      disabledHint: _disabledHint == null ? null : Text(_disabledHint!),
      value: _selectedOption,
      items: items,
      validator: _validator,
      onChanged: _onChanged,
      onSaved: _onSaved,
      decoration: InputDecoration(
        label: _label == null ? null : Text(_label!),
        helperText: '',
        helperMaxLines: 1,
      ),
    );
  }
}
