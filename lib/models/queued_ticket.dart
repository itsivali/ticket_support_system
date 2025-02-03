import '../models/ticket.dart' as ticket_model;

class QueuedTicket {
  final String id;
  final ticket_model.Ticket ticket;
  final double priority;
  final DateTime queuedAt;
  bool isExpanded;

  // Add title getter
  String get title => ticket.title;

  QueuedTicket({
    required this.id,
    required this.ticket,
    required this.priority,
    DateTime? queuedAt,
    this.isExpanded = false,
  }) : queuedAt = queuedAt ?? DateTime.now();

  // JSON serialization
  factory QueuedTicket.fromJson(Map<String, dynamic> json) {
    return QueuedTicket(
      id: json['id'] as String,
      ticket: ticket_model.Ticket.fromJson(json['ticket'] as Map<String, dynamic>),
      priority: json['priority'] as double,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      isExpanded: json['isExpanded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ticket': ticket.toJson(),
    'priority': priority,
    'queuedAt': queuedAt.toIso8601String(),
    'isExpanded': isExpanded,
  };

  @override
  String toString() => 'QueuedTicket(id: $id, title: ${ticket.title}, priority: $priority, queuedAt: $queuedAt, isExpanded: $isExpanded)';
}