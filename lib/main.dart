import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ticket_provider.dart';
import 'providers/agent_provider.dart';
import 'providers/queue_provider.dart';
import 'providers/shift_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tickets/ticket_screens.dart';
import 'screens/agents/agent_screens.dart';
import 'screens/queue/queue_screens.dart';
import 'screens/shift_screens.dart';
import 'models/ticket.dart';
import 'models/agent.dart';
import 'theme/app_theme.dart';
import 'screens/shifts/edit_shift_screen.dart';
import 'models/shift_schedule.dart'; 
import 'screens/tickets/manage_tickets_screen.dart'; 

void main() {
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
      title: 'Support System',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const DashboardScreen(),
      routes: {
        '/tickets': (context) => const TicketListScreen(),
        '/create-ticket': (context) => const CreateTicketScreen(),
        '/agents': (context) => const AgentListScreen(),
        '/create-agent': (context) => const CreateAgentScreen(),
        '/queue': (context) => const QueueScreen(),
        '/shifts': (context) => const ShiftManagementScreen(),
        '/auto-assignment': (context) => const AutoAssignmentScreen(),
         '/manage-tickets': (context) => const ManageTicketsScreen(),
          '/shift-management': (context) => const ShiftManagementScreen(), 
 
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/edit-ticket':
            return MaterialPageRoute(
              builder: (context) => EditTicketScreen(
                ticket: settings.arguments as Ticket,
              ),
            );
          case '/edit-agent':
            return MaterialPageRoute(
              builder: (context) => EditAgentScreen(
                agent: settings.arguments as Agent,
              ),
            );
          case '/agent-details':
            return MaterialPageRoute(
              builder: (context) => AgentDetailsScreen(
                agent: settings.arguments as Agent,
              ),
            );
          case '/edit-shift':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => EditShiftScreen(
                agent: args['agent'] as Agent,
                shift: args['shift'] as ShiftSchedule,
              ),
            );
          default:
            return null;
        }
      },
    );
  }
}