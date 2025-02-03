import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket.dart';
import '../../providers/agent_provider.dart';
import '../../utils/ui_helpers.dart';
import '../../models/agent.dart';

class TicketDetailsScreen extends StatefulWidget {
  final Ticket ticket;

  const TicketDetailsScreen({super.key, required this.ticket});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late Ticket _ticket;

  @override
  void initState() {
    super.initState();
    _ticket = widget.ticket;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPriorityChip() {
    Color color = _getPriorityColor(_ticket.priority);
    IconData icon;

    switch (_ticket.priority.toUpperCase()) {
      case 'HIGH':
        icon = Icons.priority_high;
        break;
      case 'MEDIUM':
        icon = Icons.priority_high;
        break;
      case 'LOW':
        icon = Icons.low_priority;
        break;
      default:
        icon = Icons.help;
    }

    return Chip(
      avatar: Icon(icon, color: color, size: 18),
      label: Text(_ticket.priority),
      backgroundColor: color.withAlpha((0.1 * 255).toInt()),
      side: BorderSide(color: color),
    );
  }

  Future<void> _showAssignDialog(BuildContext context) async {
    final agents = context.read<AgentProvider>().agents
        .where((a) => a.isAvailable && a.currentTickets.length < 3)
        .toList();

    if (agents.isEmpty) {
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'No available agents found',
        icon: Icons.warning_amber_rounded,
        backgroundColor: Colors.orange,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Ticket'),
        content: SizedBox(
          height: 200,
          child: ListView.builder(
            itemCount: agents.length,
            itemBuilder: (context, index) {
              final agent = agents[index];
              return ListTile(
                title: Text(agent.name),
                onTap: () {
                  Navigator.of(context).pop(agent);
                },
              );
            },
          ),
        ),
      ),
    ).then((selectedAgent) {
      if (selectedAgent != null) {
        _assignTicket(selectedAgent);
      }
    });
  }

  Future<void> _assignTicket(Agent agent) async {
    try {
      // Add logic to assign the ticket to the agent
      // For example, update the ticket in the database
      setState(() {
        _ticket = _ticket.copyWith(assignedTo: agent.id);
      });
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Ticket assigned to ${agent.name}',
        icon: Icons.check_circle,
        backgroundColor: Colors.green,
      );
    } catch (e) {
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Failed to assign ticket: $e',
        icon: Icons.error,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.assignment_ind),
            onPressed: () => _showAssignDialog(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _ticket.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            _buildPriorityChip(),
            const SizedBox(height: 16),
            Text(
              _ticket.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Status: ${_ticket.status}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Due Date: ${_ticket.dueDate}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Assigned To: ${_ticket.assignedTo ?? 'Unassigned'}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}