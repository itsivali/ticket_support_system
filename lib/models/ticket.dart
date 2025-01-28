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
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'].toString())
          : DateTime.now(),
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'OPEN',
      priority: json['priority']?.toString() ?? 'MEDIUM',
      assignedTo: json['assignedTo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'estimatedHours': estimatedHours,
    'status': status,
    'priority': priority,
    if (assignedTo != null) 'assignedTo': assignedTo,
    if (id.isNotEmpty) '_id': id,
  };
}