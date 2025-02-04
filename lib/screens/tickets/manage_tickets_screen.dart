import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ticket_provider.dart';
import '../../models/ticket.dart';
import '../../widgets/loading_overlay.dart';


class ManageTicketsScreen extends StatefulWidget {
  const ManageTicketsScreen({super.key});

  @override 
  State<ManageTicketsScreen> createState() => _ManageTicketsScreenState();
}

class _ManageTicketsScreenState extends State<ManageTicketsScreen> {
  String _statusFilter = 'all';
  String _priorityFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tickets'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _statusFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Status')),
              const PopupMenuItem(value: 'OPEN', child: Text('Open')),
              const PopupMenuItem(value: 'IN_PROGRESS', child: Text('In Progress')),
              const PopupMenuItem(value: 'CLOSED', child: Text('Closed')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.priority_high),
            onSelected: (value) => setState(() => _priorityFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('All Priorities')),
              const PopupMenuItem(value: 'HIGH', child: Text('High')),
              const PopupMenuItem(value: 'MEDIUM', child: Text('Medium')), 
              const PopupMenuItem(value: 'LOW', child: Text('Low')),
            ],
          ),
        ],
      ),
      body: Consumer<TicketProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return LoadingOverlay(
              isLoading: provider.isLoading,
              child: Container(),
            );
          }

          final tickets = provider.filterTickets(
            status: _statusFilter,
            priority: _priorityFilter,
          );

          if (tickets.isEmpty) {
            return const Center(child: Text('No tickets found'));
          }

          return ListView.builder(
            itemCount: tickets.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              return Card(
                child: ExpansionTile(
                  title: Text(ticket.title),
                  subtitle: Text('Status: ${ticket.status} | Priority: ${ticket.priority}'),
                  leading: _getPriorityIcon(ticket.priority),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Description: ${ticket.description}'),
                          const SizedBox(height: 8),
                          Text('Created: ${_formatDate(ticket.createdAt)}'),
                          Text('Due: ${_formatDate(ticket.dueDate)}'),
                          Text('Estimated Hours: ${ticket.estimatedHours}'),
                          if (ticket.requiredSkills.isNotEmpty)
                            Text('Skills: ${ticket.requiredSkills.join(", ")}'),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit'),
                                onPressed: () => _editTicket(context, ticket),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: const Text('Delete', 
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () => _deleteTicket(context, ticket),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _getPriorityIcon(String priority) {
    final color = switch(priority) {
      'HIGH' => Colors.red,
      'MEDIUM' => Colors.orange,
      'LOW' => Colors.green,
      _ => Colors.grey,
    };
    return Icon(Icons.flag, color: color);
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
           '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _editTicket(BuildContext context, Ticket ticket) async {
    await Navigator.pushNamed(
      context, 
      '/edit-ticket',
      arguments: ticket,
    );
  }

  Future<void> _deleteTicket(BuildContext context, Ticket ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Ticket'),
        content: Text('Are you sure you want to delete "${ticket.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<TicketProvider>().deleteTicket(ticket.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ticket deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting ticket: $e')),
          );
        }
      }
    }
  }
}