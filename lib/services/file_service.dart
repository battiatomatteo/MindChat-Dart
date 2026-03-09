import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class FileService {
  static Future<String> _getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/data.txt';
  }

  static Future<void> write(String text) async {
    try {
      final path = await _getFilePath();
      final file = File(path);

      await file.writeAsString(text, mode: FileMode.append);

      // Log pulito
      debugPrint("FileService: scritto -> $text");
    } catch (e) {
      debugPrint("FileService: errore in write(): $e");
    }
  }

  static Future<String> read() async {
    try {
      final path = await _getFilePath();
      final file = File(path);

      if (!await file.exists()) {
        debugPrint("FileService: file non trovato, ritorno stringa vuota.");
        return '';
      }

      final content = await file.readAsString();

      // Log pulito
      debugPrint("FileService: contenuto letto -> $content");

      return content;
    } catch (e) {
      debugPrint("FileService: errore in read(): $e");
      return '';
    }
  }
}
