import 'package:flutter/material.dart';
import '../models/ticket.dart';
import 'package:intl/intl.dart';

class TicketListItem extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onTap;
  final VoidCallback? onAssign;
  final VoidCallback? onClaim;
  final bool isExpanded;

  const TicketListItem({
    super.key,
    required this.ticket,
    this.onTap,
    this.onAssign,
    this.onClaim,
    this.isExpanded = false,
  });

  Color _getStatusColor() {
    switch (ticket.status) {
      case 'OPEN':
        return Colors.blue;
      case 'IN_PROGRESS':
        return Colors.orange;
      case 'CLOSED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor() {
    switch (ticket.priority) {
      case 'HIGH':
        return Colors.red;
      case 'MEDIUM':
        return Colors.orange;
      case 'LOW':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withAlpha(25),
        border: Border.all(color: _getStatusColor()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        ticket.status,
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    return Container(
      width: 4,
      height: double.infinity,
      decoration: BoxDecoration(
        color: _getPriorityColor(),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriorityIndicator(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '#${ticket.id} - ${ticket.title}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusBadge(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ticket.description,
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded ? null : TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormatter.formatDateTime(ticket.createdAt),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            if (ticket.estimatedHours > 0) ...[
                              Icon(
                                Icons.timer,
                                size: 16,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${ticket.estimatedHours}h',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (ticket.assignedTo == null && (onAssign != null || onClaim != null))
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onAssign != null)
                        TextButton.icon(
                          onPressed: onAssign,
                          icon: const Icon(Icons.person_add),
                          label: const Text('Assign'),
                        ),
                      if (onClaim != null) ...[
                        if (onAssign != null)
                          const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: onClaim,
                          icon: const Icon(Icons.pan_tool),
                          label: const Text('Claim'),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y HH:mm').format(dateTime);
  }
}