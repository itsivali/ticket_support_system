import 'package:flutter/material.dart';

enum TicketStatus { OPEN, IN_PROGRESS, CLOSED }
enum TicketPriority { LOW, MEDIUM, HIGH }

class Ticket {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final double estimatedHours;
  final String status;
  final String priority;
  final String? assignedTo;

  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.estimatedHours,
    required this.status,
    required this.priority,
    this.assignedTo,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      status: json['status'] as String,
      priority: json['priority'] as String,
      assignedTo: json['assignedTo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'estimatedHours': estimatedHours,
      'status': status,
      'priority': priority,
      'assignedTo': assignedTo,
    };
  }

  Color get statusColor {
    switch (status) {
      case 'OPEN':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'CLOSED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color get priorityColor {
    switch (priority) {
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

  bool get isOpen => status == 'OPEN';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isClosed => status == 'CLOSED';
}