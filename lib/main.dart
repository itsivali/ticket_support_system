// Dart: lib/main.dart
import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/database_helper.dart';
import 'src/db_initializer.dart' as db_initializer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // This will invoke the appropriate initializer based on the platform.
  await db_initializer.init();

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
