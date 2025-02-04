import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/agent_provider.dart';
import '../../utils/date_formatter.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<TicketProvider>().fetchTickets(),
      context.read<AgentProvider>().fetchAgents(),
    ]);
  }

  String _getAssignedAgentName(String? agentId) {
    if (agentId == null) return 'Unassigned';
    
    final agent = context.read<AgentProvider>().getAgentById(agentId);
    return agent?.name ?? 'Unknown Agent';
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'CLOSED':
        return Colors.green;
      default:
        return Colors.grey;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Consumer<TicketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = provider.tickets;

          if (tickets.isEmpty) {
            return const Center(
              child: Text('No tickets found'),
            );
          }

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final assignedAgentName = _getAssignedAgentName(ticket.assignedTo);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    ticket.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(ticket.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ticket.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(ticket.priority),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ticket.priority,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Assigned to: $assignedAgentName'),
                      Text(
                        'Due: ${DateFormatter.format(ticket.dueDate)}',
                        style: TextStyle(
                          color: ticket.dueDate.isBefore(DateTime.now())
                              ? Colors.red
                              : null,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/edit-ticket',
                    arguments: ticket,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/edit-ticket',
                      arguments: ticket,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
    );
  }
}