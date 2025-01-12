import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart' as pkg_picker;
import 'package:cross_file/cross_file.dart' as pkg_xfile;

class ExcelPickerButton extends StatelessWidget {
  const ExcelPickerButton({
    super.key,
    void Function(pkg_xfile.XFile? pickedFile)? onPick,
  }) : _onPick = onPick;

  final void Function(pkg_xfile.XFile? pickedFile)? _onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          pkg_picker.FilePickerResult? pickedFile =
              await pkg_picker.FilePicker.platform.pickFiles(
            allowMultiple: false,
            type: pkg_picker.FileType.custom,
            allowedExtensions: ['xlsx'],
          );
          final filePath = pickedFile?.files.single.path;
          final xFile = filePath == null ? null : XFile(filePath);
          if (_onPick != null) {
            _onPick(xFile);
          }
        },
        child: Align(
          alignment: Alignment.center,
          child: Text('Selecionar'),
        ),
      ),
    );
/*
    return AppDefaultButton(
      child: Align(
        alignment: Alignment.center,
        child: Text('Selecionar arquivo'),
      ),
      onTap: () async {
        pkg_picker.FilePickerResult? pickedFile =
            await pkg_picker.FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: pkg_picker.FileType.custom,
          allowedExtensions: ['xlsx'],
        );
        final filePath = pickedFile?.files.single.path;
        final xFile = filePath == null ? null : XFile(filePath);
        if (_onPick != null) {
          _onPick(xFile);
        }
      },
    );
*/
  }
}
