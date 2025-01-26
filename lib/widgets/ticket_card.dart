import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ticket.dart';

class TicketCard extends StatelessWidget {
  final Ticket ticket;

  const TicketCard({
    super.key,
    required this.ticket,
  });

  Color _getPriorityColor() {
    switch (ticket.priority.toLowerCase()) {
      case 'high':
        return Colors.red[100]!;
      case 'medium':
        return Colors.orange[100]!;
      case 'low':
        return Colors.green[100]!;
      default:
        return Colors.grey[100]!;
    }
  }

  String _getFormattedDate(DateTime date) {
    return DateFormat('MMM dd, yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _getPriorityColor(),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ExpansionTile(
          title: Text(
            ticket.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${_getFormattedDate(ticket.dueDate)}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.priority.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      ticket.status,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ticket.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Assigned to: ${ticket.assignedTo ?? "Unassigned"}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Estimated hours: ${ticket.estimatedHours}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}