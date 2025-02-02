class Ticket {
  final String id;
  final String title;
  final String description;
  final String? assignedTo;
  final String status;
  final String dueDate;
  final double estimatedHours;
  final String priority;
  final String createdAt;
  final String? lastUpdated;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    this.assignedTo,
    required this.status,
    required this.dueDate,
    required this.estimatedHours,
    required this.priority,
    required this.createdAt,
    this.lastUpdated,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      dueDate: json['dueDate']?.toString() ?? '',
      estimatedHours: (json['estimatedHours'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? 'OPEN',
      priority: json['priority']?.toString() ?? 'MEDIUM',
      assignedTo: json['assignedTo']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      lastUpdated: json['lastUpdated']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dueDate': dueDate,
    'estimatedHours': estimatedHours,
    'status': status,
    'priority': priority,
    if (assignedTo != null) 'assignedTo': assignedTo,
    'createdAt': createdAt,
    if (lastUpdated != null) 'lastUpdated': lastUpdated,
  };
}