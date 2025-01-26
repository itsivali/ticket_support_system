import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ticket_card.dart';
import '../models/ticket.dart';

class TicketListScreen extends StatefulWidget {
  const TicketListScreen({Key? key}) : super(key: key);

  @override
  State<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends State<TicketListScreen> {
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
        title: const Text('Support Tickets'),
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

          return RefreshIndicator(
            onRefresh: () => ticketProvider.fetchTickets(),
            child: ListView.builder(
              itemCount: ticketProvider.tickets.length,
              itemBuilder: (context, index) {
                final ticket = ticketProvider.tickets[index];
                return TicketCard(ticket: ticket);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/create-ticket'),
        child: const Icon(Icons.add),
        tooltip: 'Create New Ticket',
      ),
    );
  }
}