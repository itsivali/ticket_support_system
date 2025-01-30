import 'package:flutter/material.dart';
import '../screens/dashboard_screen.dart';
import '../screens/agent_list_screen.dart';
import '../screens/create_agent_screen.dart';
import '../screens/create_ticket_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: colorScheme.onPrimary.withAlpha((0.2 * 255).round()),
                  child: Icon(Icons.support_agent, 
                    size: 32, 
                    color: colorScheme.onPrimary
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ticket System',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Dashboard
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          const Divider(),
          // Ticket Management Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('TICKET MANAGEMENT', 
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_task),
            title: const Text('Create Ticket'),
            subtitle: const Text('Create new support ticket'),
            onTap: () => Navigator.pushNamed(context, '/create-ticket'),
          ),
          ListTile(
            leading: const Icon(Icons.queue),
            title: const Text('Ticket Queue'),
            subtitle: const Text('View unassigned tickets'),
            onTap: () => Navigator.pushNamed(context, '/ticket-queue'),
          ),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Manage Tickets'),
            subtitle: const Text('View and manage all tickets'),
            onTap: () => Navigator.pushNamed(context, '/manage-tickets'),
          ),
          const Divider(),
          // Agent Management Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('AGENT MANAGEMENT', 
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Create Agent'),
            subtitle: const Text('Add new support agent'),
            onTap: () => Navigator.pushNamed(context, '/create-agent'),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Manage Agents'),
            subtitle: const Text('View and manage agents'),
            onTap: () => Navigator.pushNamed(context, '/agents'),
          ),
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Shift Management'),
            subtitle: const Text('Manage agent schedules'),
            onTap: () => Navigator.pushNamed(context, '/shift-management'),
          ),
          const Divider(),
          // Queue Management Section
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('QUEUE MANAGEMENT', 
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text('Auto Assignment'),
            subtitle: const Text('Manage ticket auto-assignment'),
            onTap: () => Navigator.pushNamed(context, '/auto-assignment'),
          ),
          ListTile(
            leading: const Icon(Icons.person_search),
            title: const Text('Claim Tickets'),
            subtitle: const Text('Manually claim tickets'),
            onTap: () => Navigator.pushNamed(context, '/claim-tickets'),
          ),
        ],
      ),
    );
  }
}