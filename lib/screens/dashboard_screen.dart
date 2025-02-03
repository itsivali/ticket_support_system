import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/agent_provider.dart';
import '../providers/queue_provider.dart';
import '../providers/shift_provider.dart';
import '../models/agent.dart';
import '../models/shift.dart';
import '../models/ticket.dart';
import '../widgets/app_drawer.dart';
import '../utils/console_logger.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        context.read<TicketProvider>().fetchTickets(),
        context.read<AgentProvider>().fetchAgents(),
        context.read<QueueProvider>().fetchQueueStatus(),
        context.read<ShiftProvider>().fetchCurrentShifts(),
      ]);
    } catch (e) {
      ConsoleLogger.error('Failed to refresh dashboard', e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to refresh data')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Dashboard'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Refresh Data',
            ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatusOverview(),
              SizedBox(height: 24),
              _QuickActions(),
              SizedBox(height: 24),
              _TicketMetrics(),
              SizedBox(height: 24),
              _AgentStatus(),
              SizedBox(height: 24),
              _ShiftOverview(),
              SizedBox(height: 24),
              _AutoAssignmentStatus(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusOverview extends StatelessWidget {
  const _StatusOverview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatusCard(
          title: 'Open Tickets',
          value: context.select((TicketProvider p) => 
            p.tickets.where((t) => t.status == 'OPEN').length.toString()),
          icon: Icons.confirmation_number,
          color: theme.colorScheme.primary,
        ),
        _StatusCard(
          title: 'Available Agents',
          value: context.select((AgentProvider p) => 
            p.agents.where((a) => a.isAvailable && a.isOnline).length.toString()),
          icon: Icons.people,
          color: theme.colorScheme.secondary,
        ),
        _StatusCard(
          title: 'Queue Size',
          value: context.select((QueueProvider p) => 
            p.queueManager?.size.toString() ?? '0'),
          icon: Icons.queue,
          color: theme.colorScheme.tertiary,
        ),
        _StatusCard(
          title: 'Active Shifts',
          value: context.select((ShiftProvider p) => 
            p.currentShifts.length.toString()),
          icon: Icons.schedule,
          color: theme.colorScheme.error,
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionButton(
                  label: 'Create Ticket',
                  icon: Icons.add,
                  onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
                ),
                _ActionButton(
                  label: 'Assign Tickets',
                  icon: Icons.assignment_ind,
                  onPressed: () => Navigator.pushNamed(context, '/ticket-queue'),
                ),
                _ActionButton(
                  label: 'Manage Agents',
                  icon: Icons.people,
                  onPressed: () => Navigator.pushNamed(context, '/agents'),
                ),
                _ActionButton(
                  label: 'View Queue',
                  icon: Icons.queue,
                  onPressed: () => Navigator.pushNamed(context, '/manage-tickets'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class _TicketMetrics extends StatelessWidget {
  const _TicketMetrics();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ticket Metrics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<TicketProvider>(
              builder: (context, provider, child) {
                final tickets = provider.tickets;
                return Column(
                  children: [
                    _MetricRow(
                      label: 'Open',
                      value: tickets.where((t) => t.status == 'OPEN').length,
                      color: Colors.blue,
                    ),
                    _MetricRow(
                      label: 'In Progress',
                      value: tickets.where((t) => t.status == 'IN_PROGRESS').length,
                      color: Colors.orange,
                    ),
                    _MetricRow(
                      label: 'Closed',
                      value: tickets.where((t) => t.status == 'CLOSED').length,
                      color: Colors.green,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _AgentStatus extends StatelessWidget {
  const _AgentStatus();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agent Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/agents'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<AgentProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.agents.take(5).length,
                  itemBuilder: (context, index) {
                    final agent = provider.agents[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: agent.isOnline 
                            ? Colors.green 
                            : Colors.grey,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(agent.name),
                      subtitle: Text('${agent.currentTickets.length} active tickets'),
                      trailing: Icon(
                        Icons.circle,
                        size: 12,
                        color: agent.isAvailable ? Colors.green : Colors.grey,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftOverview extends StatelessWidget {
  const _ShiftOverview();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Shifts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/shift-management'),
                  child: const Text('Manage Shifts'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ShiftProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.currentShifts.take(3).length,
                  itemBuilder: (context, index) {
                    final shift = provider.currentShifts[index];
                    return ListTile(
                      leading: const Icon(Icons.schedule),
                      title: Text(shift.agentName),
                      subtitle: Text('${shift.startTime.format(context)} - ${shift.endTime.format(context)}'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AutoAssignmentStatus extends StatelessWidget {
  const _AutoAssignmentStatus();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Auto Assignment',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/auto-assignment'),
                  child: const Text('Configure'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<QueueProvider>(
              builder: (context, provider, child) {
                final isEnabled = provider.queueManager?.settings.autoAssignEnabled ?? false;
                return SwitchListTile(
                  title: const Text('Auto Assignment'),
                  subtitle: Text(isEnabled ? 'Enabled' : 'Disabled'),
                  value: isEnabled,
                  onChanged: (value) {
                    // Update auto-assignment setting
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}