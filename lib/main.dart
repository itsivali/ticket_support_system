import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/agent_provider.dart';
import 'providers/queue_provider.dart';
import 'providers/shift_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/create_ticket_screen.dart';
import 'screens/edit_ticket_screen.dart';
import 'screens/agent_list_screen.dart';
import 'screens/create_agent_screen.dart';
import 'screens/agent_details_screen.dart';
import 'screens/ticket_queue_screen.dart';
import 'screens/manage_tickets_screen.dart';
import 'screens/shift_management_screen.dart';
import 'screens/auto_assignment_screen.dart';
import 'screens/claim_tickets_screen.dart';
import 'models/ticket.dart';
import 'models/agent.dart';
import 'theme/app_theme.dart';
import 'utils/console_logger.dart';

void main() {
  ConsoleLogger.info('Application starting', 'Initializing providers and services');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TicketProvider()),
        ChangeNotifierProvider(create: (_) => AgentProvider()),
        ChangeNotifierProvider(create: (_) => QueueProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/create-ticket': (context) => const CreateTicketScreen(),
        '/agents': (context) => const AgentListScreen(),
        '/create-agent': (context) => const CreateAgentScreen(),
        '/ticket-queue': (context) => const TicketQueueScreen(),
        '/manage-tickets': (context) => const ManageTicketsScreen(),
        '/shift-management': (context) => const ShiftManagementScreen(),
        '/auto-assignment': (context) => const AutoAssignmentScreen(),
        '/claim-tickets': (context) => const ClaimTicketsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit-ticket') {
          final ticket = settings.arguments as Ticket;
          return MaterialPageRoute(
            builder: (context) => EditTicketScreen(ticket: ticket),
          );
        }
        if (settings.name == '/agent-details') {
          final agent = settings.arguments as Agent;
          return MaterialPageRoute(
            builder: (context) => AgentDetailsScreen(agent: agent),
          );
        }
        return null;
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}