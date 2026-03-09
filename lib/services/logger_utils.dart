import 'package:logger/logger.dart';

/* define the instance of the logger */
final logger = Logger(
  printer: PrettyPrinter(
    colors: true,
    printEmojis: true,
  ),
);