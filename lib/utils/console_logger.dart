import 'package:logger/logger.dart';

class ConsoleLogger {
  static final _logger = Logger();

  static void info(String message, [String? details]) {
    if (details != null) {
      _logger.i('$message\n$details');
    } else {
      _logger.i(message);
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (error != null) {
      _logger.e('$message\n$error', error: error, stackTrace: stackTrace);
    } else {
      _logger.e(message);
    }
  }

  static void debug(String message, [String? details]) {
    if (details != null) {
      _logger.d('$message\n$details');
    } else {
      _logger.d(message);
    }
  }

  static void warning(String message, [String? details]) {
    if (details != null) {
      _logger.w('$message\n$details');
    } else {
      _logger.w(message);
    }
  }
}