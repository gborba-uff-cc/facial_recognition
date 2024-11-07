import 'dart:io';

import 'package:facial_recognition/utils/ui.dart';
import 'package:cross_file/cross_file.dart' as pkg_xfile;
import 'package:path/path.dart' as pkg_path;

Future<void> exportFile(pkg_xfile.XFile file, Directory? outputDirectory, String outputFileName) async {
  try {
    final now = DateTime.now();
    final filename = '${dateTimeToString2(now)}copyOf${file.name}';
    if (outputDirectory == null) {
      return;
    }
    await file.saveTo(pkg_path.canonicalize(pkg_path.join(outputDirectory.path, outputFileName)));
  }
  on Exception {/**/}
}
