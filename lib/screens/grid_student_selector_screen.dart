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
) =>
    GridSelectorScreen<MapEntry<Student, FacePicture?>>(
      initialySelected: args.initialySelected,
      items: args.items,
      gridItemBuilder: (context, item) {
        final student = item.key;
        final jpg = item.value?.faceJpeg;
        return AspectRatio(
          aspectRatio: 1.0,
          child: jpg != null
              ? Image.memory(jpg, fit: BoxFit.contain)
              : DecoratedBox(
                  decoration: BoxDecoration(border: Border.all(width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          student.registration,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                        Text(
                          student.individual.displayFullName,
                          maxLines: 3,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
