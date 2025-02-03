class Ticket {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime dueDate;
  final int estimatedHours;
  final List<String> requiredSkills;
  final DateTime lastUpdated;

  const Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.assignedTo,
    required this.createdAt,
    required this.dueDate,
    required this.estimatedHours,
    required this.requiredSkills,
    required this.lastUpdated,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String, 
      status: json['status'] as String,
      priority: json['priority'] as String,
      assignedTo: json['assignedTo'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      dueDate: DateTime.parse(json['dueDate'] as String),
      estimatedHours: json['estimatedHours'] as int,
      requiredSkills: List<String>.from(json['requiredSkills'] as List),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'assignedTo': assignedTo,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'estimatedHours': estimatedHours,
    'requiredSkills': requiredSkills,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  Ticket copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? dueDate,
    int? estimatedHours,
    List<String>? requiredSkills,
    DateTime? lastUpdated,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      requiredSkills: requiredSkills ?? this.requiredSkills,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get isUrgent => DateTime.now().difference(dueDate).inHours < 24;
  bool get isOverdue => DateTime.now().isAfter(dueDate);
  bool get isAssigned => assignedTo != null;
}