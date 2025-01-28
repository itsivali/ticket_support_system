import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TicketProvider>();
      provider.fetchTickets();
      provider.fetchAgents();
    });
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                count.toString(),
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
      body: Consumer<TicketProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Theme.of(context).colorScheme.error),
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
            );
          }

          final openCount = provider.tickets
              .where((ticket) => ticket.status == 'OPEN')
              .length;
          final inProgressCount = provider.tickets
              .where((ticket) => ticket.status == 'IN_PROGRESS')
              .length;
          final closedCount = provider.tickets
              .where((ticket) => ticket.status == 'CLOSED')
              .length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    _buildStatCard('Open', openCount, Colors.orange),
                    const SizedBox(width: 8),
                    _buildStatCard('In Progress', inProgressCount, Colors.blue),
                    const SizedBox(width: 8),
                    _buildStatCard('Closed', closedCount, Colors.green),
                  ],
                ),
              ),
              Expanded(
                child: provider.tickets.isEmpty
                    ? const Center(
                        child: Text('No tickets available'),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.5,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: provider.tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = provider.tickets[index];
                          return TicketCard(ticket: ticket);
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

  Future<void> _showFilterDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) {
    return AlertDialog(
      title: const Text('Filter Tickets'),
      content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
        title: const Text('Open'),
        value: context.read<TicketProvider>().filterOpen,
        onChanged: (value) {
          context.read<TicketProvider>().setFilterOpen(value ?? false);
        },
        ),
        CheckboxListTile(
        title: const Text('In Progress'),
        value: context.read<TicketProvider>().filterInProgress,
        onChanged: (value) {
          context.read<TicketProvider>().setFilterInProgress(value ?? false);
        },
        ),
        CheckboxListTile(
        title: const Text('Closed'),
        value: context.read<TicketProvider>().filterClosed,
        onChanged: (value) {
          context.read<TicketProvider>().setFilterClosed(value ?? false);
        },
        ),
      ],
      ),
      actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () {
        context.read<TicketProvider>().applyFilters();
        Navigator.pop(context);
        },
        child: const Text('Apply'),
      ),
      ],
    );
    },
  );
  }
}