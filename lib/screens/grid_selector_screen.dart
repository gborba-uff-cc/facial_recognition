import 'package:facial_recognition/screens/widgets/grid_selector.dart';
import 'package:facial_recognition/utils/project_logger.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GridSelectorScreen<T> extends StatefulWidget {
  const GridSelectorScreen({
    super.key,
    T? initialySelected,
    required this.items,
    required this.gridItemBuilder,
  }): _initialySelected = initialySelected;

  final List<T> items;
  final T? _initialySelected;
  final Widget Function(BuildContext context, T item) gridItemBuilder;

  @override
  State<GridSelectorScreen<T>> createState() => _GridSelectorScreenState<T>();
}

class _GridSelectorScreenState<T> extends State<GridSelectorScreen<T>> {
  @override
  void initState() {
    selected = widget._initialySelected;
    super.initState();
  }

  T? selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: GridSelector(
                  selected: selected,
                  items: widget.items,
                  toWidget: widget.gridItemBuilder,
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
                    onPressed: () {
                      projectLogger.fine('selected ${widget._initialySelected}');
                      final router = GoRouter.of(context);
                      if (router.canPop()) {
                        router.pop(widget._initialySelected);
                      }
                    },
                    child: const Text(
                      'Cancelar',
                      maxLines: 1,
                    ),
                  ),
                  FilledButton(
                    onPressed: () {
                      final router = GoRouter.of(context);
                      if (router.canPop()) {
                        router.pop(selected);
                      }
                    },
                    child: const Text(
                      'Aceitar',
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}