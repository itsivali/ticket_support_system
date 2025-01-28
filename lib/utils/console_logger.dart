import 'package:flutter/foundation.dart';

class ConsoleLogger {
  static void info(String message) {
    if (kDebugMode) print('📘 INFO: $message');
  }

  static void error(String message, [Object? error, StackTrace? stack]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) print('Error details: $error');
      if (stack != null) print('Stack trace: $stack');
    }
  }

  static void warning(String message) {
    if (kDebugMode) print('⚠️ WARNING: $message');
  }
}