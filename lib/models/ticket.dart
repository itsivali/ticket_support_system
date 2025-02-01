class Ticket {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final double estimatedHours;
  final String status;
  final String priority;
  final String? assignedTo;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.estimatedHours,
    required this.status,
    required this.priority,
    this.assignedTo,
    required this.createdAt,
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
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
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
    'createdAt': createdAt.toIso8601String(),
  };
}