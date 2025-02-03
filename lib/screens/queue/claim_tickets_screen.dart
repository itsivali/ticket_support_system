import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/queue_manager.dart';
import '../../providers/queue_provider.dart';
import '../../providers/agent_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../utils/ui_helpers.dart';

class ClaimTicketsScreen extends StatefulWidget {
  const ClaimTicketsScreen({super.key});

  @override
  State<ClaimTicketsScreen> createState() => _ClaimTicketsScreenState();
}

class _ClaimTicketsScreenState extends State<ClaimTicketsScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshQueue();
  }

  Future<void> _refreshQueue() async {
    setState(() => _isLoading = true);
    try {
      await context.read<QueueProvider>().fetchQueueStatus();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _claimTicket(QueuedTicket queuedTicket) async {
    setState(() => _isLoading = true);

    try {
      final agent = context.read<AgentProvider>().currentAgent;
      if (agent == null) {
        UIHelpers.showErrorSnackBar(
          context: context,
          message: 'No agent logged in',
        );
        return;
      }

      final success = await context.read<QueueProvider>().claimTicket(
        queuedTicket.ticket.id,
        agent.id,
      );

      if (!mounted) return;

      if (success) {
        UIHelpers.showSuccessSnackBar(
          context: context,
          message: 'Ticket claimed successfully',
        );
        _refreshQueue(); // Refresh queue after claiming
      }
    } catch (e) {
      if (!mounted) return;
      UIHelpers.showErrorSnackBar(
        context: context,
        message: 'Failed to claim ticket: $e',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red[700] ?? Colors.red;
      case 'MEDIUM':
        return Colors.orange[700] ?? Colors.orange;
      case 'LOW':
        return Colors.green[700] ?? Colors.green;
      default:
        return Colors.grey[700] ?? Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Claim Tickets'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _refreshQueue,
            tooltip: 'Refresh Queue',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<QueueProvider>(
        builder: (context, provider, child) {
          final queuedTickets = provider.queueManager?.pendingTickets ?? [];

          if (queuedTickets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_turned_in,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tickets available to claim',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: queuedTickets.length,
            itemBuilder: (context, index) {
              final queuedTicket = queuedTickets[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getPriorityColor(queuedTicket.ticket.priority),
                    child: Text(
                      queuedTicket.priority.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(queuedTicket.ticket.title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Due: ${_formatDate(queuedTicket.ticket.dueDate)}'),
                      Text(
                        'Priority Score: ${queuedTicket.priority.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.pan_tool),
                    label: const Text('CLAIM'),
                    onPressed: _isLoading ? null : () => _claimTicket(queuedTicket),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}