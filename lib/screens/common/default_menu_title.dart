import 'package:flutter/material.dart';

class DefaultMenuTitle extends StatelessWidget {
  const DefaultMenuTitle({
    super.key,
    required String title,
  }) : _title = title;

  final String _title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        _title,
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineLarge,
        overflow: TextOverflow.fade,
      ),
    );
  }
}
