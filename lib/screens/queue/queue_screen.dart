import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/ticket.dart';
import '../../providers/queue_provider.dart';
import '../../widgets/ticket_list_item.dart';
import '../../utils/ui_helpers.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refreshQueue();
  }

  Future<void> _refreshQueue() async {
    setState(() => _isLoading = true);
    try {
      await context.read<QueueProvider>().refreshQueue();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket Queue'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshQueue,
            ),
        ],
      ),
      body: Consumer<QueueProvider>(
        builder: (context, provider, child) {
          if (provider.tickets.isEmpty) {
            return const Center(
              child: Text('No tickets in queue'),
            );
          }

          return ListView.builder(
            itemCount: provider.tickets.length,
            itemBuilder: (context, index) {
              final ticket = provider.tickets[index];
              return TicketListItem(
                ticket: ticket,
                onAssign: () => _showAssignDialog(ticket),
              );
            },
          );
        },
      ),
    );
  }
}