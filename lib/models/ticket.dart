// lib/models/ticket.dart
class Ticket {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final double estimatedHours;
  final String status;
  final String? assignedTo;
  final String priority;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.estimatedHours,
    required this.status,
    this.assignedTo,
    required this.priority,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      estimatedHours: json['estimatedHours'].toDouble(),
      status: json['status'],
      assignedTo: json['assignedTo'],
      priority: json['priority'],
    );
  }
}