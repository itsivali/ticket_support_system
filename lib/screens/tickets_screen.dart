// Dart: lib/screens/tickets_screen.dart
import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/database_helper.dart';

class TicketsScreen extends StatelessWidget {
  const TicketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Ticket>>(
      future: DatabaseHelper.instance.getTickets(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Center(child: Text('Error loading tickets'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final tickets = snapshot.data!;
        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index];
            return ListTile(
              leading: const Icon(Icons.confirmation_number),
              title: Text(ticket.title),
              subtitle: Text(ticket.description),
              trailing: ticket.agentId != null 
                ? const Icon(Icons.assignment_ind) 
                : const Icon(Icons.assignment_late),
            );
          },
        );
      },
    );
  }
}