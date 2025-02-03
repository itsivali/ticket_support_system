import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ticket_provider.dart';
import '../../models/ticket.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/app_drawer.dart';

class TicketQueueScreen extends StatefulWidget {
  const TicketQueueScreen({super.key});

  @override
  State<TicketQueueScreen> createState() => _TicketQueueScreenState();
}

class _TicketQueueScreenState extends State<TicketQueueScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().fetchTickets();
    });
  }

  List<Ticket> _getQueuedTickets(List<Ticket> tickets) {
    return tickets.where((ticket) => 
      ticket.assignedTo == null && ticket.status != 'CLOSED'
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Queue',
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

          final queuedTickets = _getQueuedTickets(provider.tickets);

          if (queuedTickets.isEmpty) {
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
                    'No tickets in queue',
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
                    Icon(Icons.queue, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Queued Tickets: ${queuedTickets.length}',
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
                  itemCount: queuedTickets.length,
                  itemBuilder: (context, index) {
                    return TicketCard(ticket: queuedTickets[index]);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}