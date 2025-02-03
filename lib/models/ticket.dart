class Ticket {
  final String id;
  final String title; 
  final String description;
  final String status;
  final String priority;
  final String? assignedTo;
  final DateTime createdAt;
  final DateTime dueDate;
  final double estimatedHours;
  final List<String> requiredSkills;

   Ticket({
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
  });

  // From JSON factory
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
      estimatedHours: (json['estimatedHours'] as num).toDouble(),
      requiredSkills: List<String>.from(json['requiredSkills'] as List),
    );
  }

  // To JSON method
  Map<String, dynamic> toJson() {
    return {
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
    };
  }

  // Copy with method
  Ticket copyWith({
    String? id,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? assignedTo,
    DateTime? createdAt,
    DateTime? dueDate,
    double? estimatedHours,
    List<String>? requiredSkills,
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
    );
  }

  double calculatePriority() {
    double priority = 0.0;
    
    switch (this.priority) {
      case 'HIGH': priority = 3.0;
      case 'MEDIUM': priority = 2.0;
      case 'LOW': priority = 1.0;
      default: priority = 0.0;
    }

    final waitingTime = DateTime.now().difference(createdAt).inHours;
    priority += (waitingTime / 24.0);
    
    final timeUntilDue = dueDate.difference(DateTime.now()).inHours;
    if (timeUntilDue < 24) {
      priority *= 1.5;
    }
    
    return priority;
  }

  bool get isUrgent => 
    dueDate.difference(DateTime.now()).inHours < 24;
}