import 'package:flutter/material.dart';

class DefaultMenuList extends StatelessWidget {
  const DefaultMenuList({
    super.key,
    List<({void Function() action, String text})> menuItemsData = const [],
  }) : _menuItemsData = menuItemsData;

  final List<({void Function() action, String text})> _menuItemsData;

  @override
  Widget build(BuildContext context) {
    // TODO - continue
    return ListView.builder(
      itemBuilder: (context, index) {
        if (index.isEven) {
          final itemIndex = index ~/ 2;
          if (0 <= itemIndex && itemIndex < _menuItemsData.length) {}
        }
        return SizedBox(height: 16.0);
      },
    );
  }
}