// Dart: lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/database_helper.dart';

// Conditionally import the appropriate sqflite package.
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    if (dart.library.html) 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    as sqflite;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize correct database factory based on the platform.
  if (kIsWeb) {
    sqflite.sqfliteFfiInit();
    // sqflite.databaseFactoryFfi returns the web version when run on the web.
    // Ensure you're using the appropriate package version for Flutter web.
    // You might also need to adjust your pubspec for proper web support.
    // Here we assign the databaseFactory appropriately.
  } else {
    sqflite.sqfliteFfiInit();
    sqflite.databaseFactoryFfi;
  }

  await DatabaseHelper.instance.database;
  runApp(const TicketApp());
}

class TicketApp extends StatelessWidget {
  const TicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Support System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
    );
  }
}