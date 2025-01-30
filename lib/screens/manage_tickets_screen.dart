import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../models/ticket.dart';
import '../widgets/ticket_card.dart';
import '../widgets/app_drawer.dart';

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
            onPressed: () => context.read<TicketProvider>().fetchTickets(),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Consumer<TicketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredTickets = _getFilteredTickets(provider.tickets);

          if (filteredTickets.isEmpty) {
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
                    'No tickets found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.assignment),
                    const SizedBox(width: 8),
                    Text(
                      'Total Tickets: ${filteredTickets.length}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredTickets.length,
                  itemBuilder: (context, index) {
                    return TicketCard(ticket: filteredTickets[index]);
                  },
                ),
              ),
            ],
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