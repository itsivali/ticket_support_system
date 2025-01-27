import 'package:logger/logger.dart';
import 'dart:io';

class AppLogger {
  static AppLogger? _instance;
  late Logger _logger;

  AppLogger._() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        FileOutput(file: File('logs/app.log')),
      ]),
    );
  }

  static AppLogger get instance {
    _instance ??= AppLogger._();
    return _instance!;
  }

  static void info(String message) {
    instance._logger.i(message);
  }

  static void debug(String message) {
    instance._logger.d(message);
  }

  static void warning(String message) {
    instance._logger.w(message);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    instance._logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void dispose() {
    instance._logger.close();
    _instance = null;
  }
}