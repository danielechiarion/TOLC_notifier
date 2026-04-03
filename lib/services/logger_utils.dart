import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:logger/logger.dart';

/// Use class for the export of logs to
/// a file in the device's storage.
class FileOutput extends LogOutput {
  @override
  void output(OutputEvent event) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/app_logs.log');
    
    for (var line in event.lines) {
      await file.writeAsString('$line\n', mode: FileMode.append);
    }
  }
}

/* define the instance of the logger */
final logger = Logger(
  printer: PrettyPrinter(
    colors: true,
    printEmojis: true,
  ),
  output: MultiOutput(
    [
      ConsoleOutput(),
      FileOutput()
    ]
  )
);