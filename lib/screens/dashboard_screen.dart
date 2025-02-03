import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/agent_provider.dart';
import '../providers/queue_provider.dart';
import '../providers/shift_provider.dart';
import '../models/agent.dart';
import '../models/shift.dart';
import '../models/ticket.dart';
import '../models/queue_settings.dart';
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
              _QueueOverview(),
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
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tickets = provider.tickets;
                final openTickets = tickets.where((t) => t.status == 'OPEN').length;
                final inProgressTickets = tickets.where((t) => t.status == 'IN_PROGRESS').length;
                final closedTickets = tickets.where((t) => t.status == 'CLOSED').length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Open Tickets: $openTickets'),
                    Text('In Progress Tickets: $inProgressTickets'),
                    Text('Closed Tickets: $closedTickets'),
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

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          label: 'Create Ticket',
          icon: Icons.add,
          onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        ),
        _ActionButton(
          label: 'Manage Tickets',
          icon: Icons.assignment,
          onPressed: () => Navigator.pushNamed(context, '/manage-tickets'),
        ),
        _ActionButton(
          label: 'Agents',
          icon: Icons.people,
          onPressed: () => Navigator.pushNamed(context, '/agents'),
        ),
      ],
    );
  }
}

class _StatusOverview extends StatelessWidget {
  const _StatusOverview();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<QueueProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final queueStats = provider.queueManager?.getQueueStats() ?? {};

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Tickets: ${queueStats['total'] ?? 0}'),
                    Text('High Priority: ${queueStats['high'] ?? 0}'),
                    Text('Medium Priority: ${queueStats['medium'] ?? 0}'),
                    Text('Low Priority: ${queueStats['low'] ?? 0}'),
                    Text('Urgent: ${queueStats['urgent'] ?? 0}'),
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
            Text(
              'Agent Status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<AgentProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final agents = provider.agents;
                final onlineAgents = agents.where((a) => a.isOnline).length;
                final availableAgents = agents.where((a) => a.isAvailable).length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Agents: ${agents.length}'),
                    Text('Online Agents: $onlineAgents'),
                    Text('Available Agents: $availableAgents'),
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

class _QueueOverview extends StatelessWidget {
  const _QueueOverview();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Queue Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Consumer<QueueProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final queuedTickets = provider.queueManager?.pendingTickets.length ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Queued Tickets: $queuedTickets'),
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
                      title: Text(shift.agentId),
                      subtitle: Text('${shift.startTime} - ${shift.endTime}'),
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
                final isEnabled = provider.autoAssign;
                return SwitchListTile(
                  title: const Text('Auto Assignment'),
                  subtitle: Text(isEnabled ? 'Enabled' : 'Disabled'),
                  value: isEnabled,
                  onChanged: (value) {
                    provider.updateAutoAssign(value);
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