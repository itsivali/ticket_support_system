import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../providers/agent_provider.dart';
import '../widgets/ticket_card.dart';
import '../models/ticket.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({super.key});

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
  String _statusFilter = 'all';
  String _priorityFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ticketProvider = context.read<TicketProvider>();
      final agentProvider = context.read<AgentProvider>();
      ticketProvider.fetchTickets();
      agentProvider.fetchAgents();
    });
  }

  List<Ticket> _getFilteredTickets(List<Ticket> tickets) {
    return tickets.where((ticket) {
      final matchesStatus = _statusFilter == 'all' || 
                          ticket.status.toLowerCase() == _statusFilter;
      final matchesPriority = _priorityFilter == 'all' || 
                            ticket.priority.toLowerCase() == _priorityFilter;
      return matchesStatus && matchesPriority;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Support Tickets Dashboard'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<TicketProvider>().fetchTickets(),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: Consumer<TicketProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (provider.error != null) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, 
                            size: 48, 
                            color: Theme.of(context).colorScheme.error),
                          const SizedBox(height: 16),
                          Text(provider.error!),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.fetchTickets(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredTickets = _getFilteredTickets(provider.tickets);

                if (filteredTickets.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No tickets available'),
                        ],
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => TicketCard(ticket: filteredTickets[index]),
                    childCount: filteredTickets.length,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        icon: const Icon(Icons.add),
        label: const Text('New Ticket'),
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog(
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
                items: ['all', 'open', 'in_progress', 'closed']
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _statusFilter = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _priorityFilter,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['all', 'high', 'medium', 'low']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.toUpperCase()),
                        ))
                    .toList(),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}