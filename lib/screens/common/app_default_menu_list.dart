import 'package:flutter/material.dart';

class AppDefaultMenuList extends StatelessWidget {
  factory AppDefaultMenuList({
    Key? key,
    required List<Widget> children,
  }) {
    final List<Widget> aux = [];
    if (children.length < 2) {
      aux.addAll(children);
    }
    else {
      for (int i=0; i<children.length; i++) {
        aux.add(children[i]);
        if (i < children.length-1) {
          aux.add(SizedBox(height: 16.0));
        }
      }
    }
    return AppDefaultMenuList._private(key: key, items: List.unmodifiable(aux),);
}

  const AppDefaultMenuList._private({super.key, required List<Widget> items})
      : _items = items;

  final List<Widget> _items;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _items,

    );
  }
}