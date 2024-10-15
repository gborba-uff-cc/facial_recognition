import 'package:flutter/material.dart';

class GridSelector<T> extends StatelessWidget {
  factory GridSelector({
    Key? key,
    T? selected,
    required List<T>items,
    required Widget Function(BuildContext context, T item) toWidget,
    Function(T? item)? onChanged,
  }) => GridSelector._private(
    selected: selected,
    selectedIndex: selected == null ? -1 : items.indexOf(selected),
    items: items,
    toWidget: toWidget,
    onChanged: onChanged,
  );

  const GridSelector._private({
    super.key,
    this.selected,
    selectedIndex,
    required this.items,
    required this.toWidget,
    this.onChanged,
  }): _selectedIndex = selectedIndex;

  final T? selected;
  final int _selectedIndex;
  final List<T> items;
  final Function(T? item)? onChanged;
  final Widget Function(BuildContext context, T item) toWidget;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      itemBuilder: (context, index) => GridItem(
        isSelected: _selectedIndex == index ? true : false,
        child: toWidget(context, items[index]),
        onTap: () => _changeSelected(index),
      ),
    );
  }

  _changeSelected(int index) {
    final f = onChanged;
    if (f != null) {
      if (index < 0 || index == _selectedIndex) {
        f(null);
      }
      else {
        f(items[index]);
      }
    }
  }
}

class GridItem extends StatelessWidget {
  const GridItem({
    super.key,
    required this.isSelected,
    required this.child,
    this.onTap,
  });

  final bool isSelected;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: isSelected
          ? DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 4,
                  color: Theme.of(context).primaryColor,
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
              position: DecorationPosition.foreground,
              child: child)
          : child,
    );
  }
}