import 'package:facial_recognition/models/domain.dart';
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

class StudentGridSelector extends StatefulWidget {
  const StudentGridSelector({
    super.key,
    this.initialySelected,
    required this.items,
    this.onSelection,
  });

  final List<({Student student, JpegPictureBytes? jpg})> items;
  final ({Student student, JpegPictureBytes? jpg})? initialySelected;
  final void Function(({Student student, JpegPictureBytes? jpg})?)? onSelection;

  @override
  State<StudentGridSelector> createState() => _StudentGridSelectorState();
}

class _StudentGridSelectorState extends State<StudentGridSelector> {
  ({Student student, JpegPictureBytes? jpg})? selected;

  @override
  void initState() {
    selected = widget.initialySelected;
    super.initState();
  }

  Widget gridItemBuilder(({Student student, JpegPictureBytes? jpg}) item) {
    final student = item.student;
    final jpg = item.jpg;
    return AspectRatio(
      aspectRatio: 1.0,
      child: jpg != null
          ? Image.memory(jpg, fit: BoxFit.contain)
          : Text(
              student.individual.displayFullName,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSelection = widget.onSelection;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Flexible(
            fit: FlexFit.tight,
            child: GridSelector(
              selected: selected,
              items: widget.items,
              toWidget: (context, item) =>  gridItemBuilder(item),
              onChanged: (item) {
                setState(() {
                  selected = item;
                });
              },
            ),
          ),
          Wrap(
            direction: Axis.horizontal,
            spacing: 8.0,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            runSpacing: 0.0,
            children: [
              FilledButton(
                onPressed: onSelection == null
                    ? null
                    : () => onSelection(null),
                child: const Text(
                  'Cancelar',
                  maxLines: 1,
                ),
              ),
              FilledButton(
                onPressed: onSelection == null
                    ? null
                    : () => onSelection(selected),
                child: const Text(
                  'Aceitar',
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
