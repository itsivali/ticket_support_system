import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/agent_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/create_ticket_screen.dart';
import 'screens/edit_ticket_screen.dart';
import 'screens/agent_list_screen.dart';  
import 'models/ticket.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => AgentProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ticket Support System',
      theme: ThemeData(
        useMaterial3: true, 
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/create-ticket': (context) => const CreateTicketScreen(),
        '/agents': (context) => const AgentListScreen(), // Add agents route
        '/edit-ticket': (context) {
          final ticket = ModalRoute.of(context)!.settings.arguments as Ticket;
          return EditTicketScreen(ticket: ticket);
        },
      },
    );
  }
}