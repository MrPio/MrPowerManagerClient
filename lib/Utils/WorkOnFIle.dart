import 'dart:io';

import 'package:path_provider/path_provider.dart';

class WorkOnFile {
  static Future<File> localPath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/$filename");
  }

  static void writeCounter(String filename, String contents) async {
    final file = await localPath(filename);
    file.writeAsString(contents);
  }

  static Future<String> readCounter(String filename) async {
    try {
      final file = await localPath(filename);
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return '';
    }
  }
}
