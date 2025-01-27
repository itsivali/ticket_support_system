class Ticket {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final double estimatedHours;
  final String status;
  final String priority;
  final String? assignedTo;

  Ticket({
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
}