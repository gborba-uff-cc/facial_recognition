import 'package:flutter/material.dart';

class AppDefaultMenuTitle extends StatelessWidget {
  const AppDefaultMenuTitle({
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
