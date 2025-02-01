import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          _buildDashboardSection(context),
          const Divider(),
          _buildTicketSection(context),
          const Divider(),
          _buildAgentSection(context),
          const Divider(),
          _buildQueueSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.onPrimary.withAlpha((0.2 * 255).toInt()),
            child: Icon(Icons.support_agent, 
              size: 32,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Support System',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.dashboard_outlined),
      title: const Text('Dashboard'),
      onTap: () => Navigator.pushReplacementNamed(context, '/'),
    );
  }

  Widget _buildTicketSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'TICKET MANAGEMENT'),
        ListTile(
          leading: const Icon(Icons.add_task),
          title: const Text('Create Ticket'),
          onTap: () => Navigator.pushNamed(context, '/create-ticket'),
        ),
        ListTile(
          leading: const Icon(Icons.queue),
          title: const Text('Ticket Queue'),
          onTap: () => Navigator.pushNamed(context, '/ticket-queue'),
        ),
        ListTile(
          leading: const Icon(Icons.assignment),
          title: const Text('Manage Tickets'),
          onTap: () => Navigator.pushNamed(context, '/manage-tickets'),
        ),
      ],
    );
  }

  Widget _buildAgentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'AGENT MANAGEMENT'),
        ListTile(
          leading: const Icon(Icons.person_add),
          title: const Text('Create Agent'),
          onTap: () => Navigator.pushNamed(context, '/create-agent'),
        ),
        ListTile(
          leading: const Icon(Icons.people),
          title: const Text('Manage Agents'),
          onTap: () => Navigator.pushNamed(context, '/agents'),
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: const Text('Shift Management'),
          onTap: () => Navigator.pushNamed(context, '/shift-management'),
        ),
      ],
    );
  }

  Widget _buildQueueSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'QUEUE MANAGEMENT'),
        ListTile(
          leading: const Icon(Icons.sync),
          title: const Text('Auto Assignment'),
          onTap: () => Navigator.pushNamed(context, '/auto-assignment'),
        ),
        ListTile(
          leading: const Icon(Icons.person_search),
          title: const Text('Claim Tickets'),
          onTap: () => Navigator.pushNamed(context, '/claim-tickets'),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}