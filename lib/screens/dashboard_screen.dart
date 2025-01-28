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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
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
        title: const Text('Support Dashboard'),
        actions: [
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

          final tickets = provider.tickets;
          final openCount = tickets.where((t) => t.status == 'OPEN').length;
          final inProgressCount =
              tickets.where((t) => t.status == 'IN_PROGRESS').length;
          final closedCount = tickets.where((t) => t.status == 'CLOSED').length;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _buildStatCard('Open', openCount, Colors.orange),
                    const SizedBox(width: 16),
                    _buildStatCard('In Progress', inProgressCount, Colors.blue),
                    const SizedBox(width: 16),
                    _buildStatCard('Closed', closedCount, Colors.green),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: tickets.isEmpty
                      ? const Center(
                          child: Text('No tickets available'),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: tickets.length,
                          itemBuilder: (context, index) => TicketCard(
                            ticket: tickets[index],
                          ),
                        ),
                ),
              ],
            ),
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
