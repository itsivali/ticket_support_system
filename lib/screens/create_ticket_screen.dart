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
      context.read<TicketProvider>().fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<TicketProvider>().fetchTickets(),
          ),
        ],
      ),
      body: Consumer<TicketProvider>(
        builder: (context, ticketProvider, child) {
          if (ticketProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ticketProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${ticketProvider.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ticketProvider.fetchTickets(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (ticketProvider.tickets.isEmpty) {
            return const Center(
              child: Text('No tickets available'),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: ticketProvider.tickets.length,
            itemBuilder: (context, index) {
              final ticket = ticketProvider.tickets[index];
              return TicketCard(ticket: ticket);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        tooltip: 'Create New Ticket',
        child: const Icon(Icons.add),
      ),
    );
  }
}