import 'package:facial_recognition/models/domain.dart';
import 'package:facial_recognition/screens/grid_selector_screen.dart';
import 'package:flutter/material.dart';

class GridStudentSelectorScreenArguments<T> {
  const GridStudentSelectorScreenArguments({
    required this.items,
    required this.initialySelected,
  });

  final List<T> items;
  final T? initialySelected;
}

/// Configure a fullscreen grid selector to change students to the mark
/// attendance screen
GridSelectorScreen<MapEntry<Student, FacePicture?>> gridStudentSelector(
  GridStudentSelectorScreenArguments<MapEntry<Student, FacePicture?>> args,
) => GridSelectorScreen<MapEntry<Student, FacePicture?>>(
    initialySelected: args.initialySelected,
    items: args.items,
    gridItemBuilder: (context, item) => AspectRatio(
      aspectRatio: 1.0,
      child: item.value != null
            ? Image.memory(item.value!.faceJpeg, fit: BoxFit.contain)
            : Text(
              item.key.individual.displayFullName,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
    ),
  );
