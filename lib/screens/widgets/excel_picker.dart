import 'package:flutter/material.dart';
import 'package:facial_recognition/screens/widgets/default_app_button.dart';
import 'package:file_picker/file_picker.dart' as pkg_picker;

class ExcelPicker extends StatelessWidget {
  const ExcelPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DefaultAppButton(
          child: Text('Pick a file'),
          // TODO - 
          onTap: () => pkg_picker.FilePicker.platform.pickFiles(),
        ),
      ],
    );
  }
}
