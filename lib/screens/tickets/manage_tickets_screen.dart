import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ticket_provider.dart';
import '../../providers/agent_provider.dart';
import '../../widgets/ticket_list_item.dart';
import '../../widgets/app_drawer.dart';
import '../../models/ticket.dart';
import '../../models/agent.dart';
import '../../models/shift_schedule.dart';

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
    _loadData();
  }

  Future<void> _loadData() async {
    final ticketProvider = context.read<TicketProvider>();
    final agentProvider = context.read<AgentProvider>();
    await Future.wait([
      ticketProvider.fetchTickets(),
      agentProvider.fetchAgents(),
    ]);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tickets'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _statusFilter,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(
                    value: 'OPEN',
                    child: Row(
                      children: [
                        Icon(Icons.fiber_new, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        const Text('Open'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'IN_PROGRESS',
                    child: Row(
                      children: [
                        Icon(Icons.trending_up, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        const Text('In Progress'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'CLOSED',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text('Closed'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _statusFilter = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priorityFilter,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(
                    value: 'HIGH',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_upward, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        const Text('High'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'MEDIUM',
                    child: Row(
                      children: [
                        Icon(Icons.remove, color: Colors.orange[700]),
                        const SizedBox(width: 8),
                        const Text('Medium'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'LOW',
                    child: Row(
                      children: [
                        Icon(Icons.arrow_downward, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        const Text('Low'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _priorityFilter = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _statusFilter = 'all';
                _priorityFilter = 'all';
              });
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  List<Ticket> _getFilteredTickets(List<Ticket> tickets) {
    return tickets.where((ticket) {
      final matchesStatus = _statusFilter == 'all' || 
                          ticket.status == _statusFilter;
      final matchesPriority = _priorityFilter == 'all' || 
                             ticket.priority == _priorityFilter;
      return matchesStatus && matchesPriority;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Tickets',
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Tickets',
            onPressed: _loadData,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer2<TicketProvider, AgentProvider>(
        builder: (context, ticketProvider, agentProvider, _) {
          if (ticketProvider.isLoading || agentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tickets = _getFilteredTickets(ticketProvider.tickets);

          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final assignedAgent = agentProvider.agents
                  .firstWhere(
                    (agent) => agent.id == ticket.assignedTo,
                    orElse: () => Agent(
                      id: '',
                      name: 'Unassigned',
                      email: '',
                      role: 'SUPPORT',
                      shiftSchedule: ShiftSchedule(
                        id: '',
                        agentId: '',
                        weekdays: [],
                        startTime: DateTime.now(),
                        endTime: DateTime.now(),
                        isActive: false,
                        scheduleType: '',
                      ),
                      lastAssignment: DateTime.now(),
                    ),
                  );

              return TicketListItem(
                ticket: ticket,
                onTap: () => Navigator.pushNamed(
                  context,
                  '/edit-ticket',
                  arguments: ticket,
                ),
                trailing: Text(
                  assignedAgent.name,
                  style: TextStyle(
                    color: assignedAgent.id.isEmpty ? Colors.grey : Colors.black,
                    fontStyle: assignedAgent.id.isEmpty ? FontStyle.italic : FontStyle.normal,
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