class Ticket {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final double estimatedHours;
  final String status;
  final String? assignedTo;
  final String priority;
  final DateTime createdAt;

  Ticket({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.estimatedHours,
    String? status,
    this.assignedTo,
    String? priority,
    DateTime? createdAt,
  }) : status = status ?? 'PENDING',
       priority = priority ?? 'MEDIUM',
       createdAt = createdAt ?? DateTime.now() {
    if (!validStatuses.contains(this.status)) {
      throw ArgumentError('Invalid status: ${this.status}');
    }
    if (!validPriorities.contains(this.priority)) {
      throw ArgumentError('Invalid priority: ${this.priority}');
    }
    if (estimatedHours <= 0) {
      throw ArgumentError('Estimated hours must be greater than 0');
    }
    if (dueDate.isBefore(DateTime.now())) {
      throw ArgumentError('Due date must be in the future');
    }
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate']) 
          : DateTime.now().add(const Duration(days: 1)),
      estimatedHours: (json['estimatedHours'] ?? 0.0).toDouble(),
      status: json['status'],
      assignedTo: json['assignedTo'],
      priority: json['priority'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }


  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'estimatedHours': estimatedHours,
    'status': status,
    'assignedTo': assignedTo,
    'priority': priority,
    'createdAt': createdAt.toIso8601String(),
  };

 
  Ticket copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    double? estimatedHours,
    String? status,
    String? assignedTo,
    String? priority,
    DateTime? createdAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  
  static const List<String> validStatuses = [
    'PENDING',
    'ASSIGNED',
    'IN_PROGRESS',
    'COMPLETED'
  ];

  
  static const List<String> validPriorities = [
    'LOW',
    'MEDIUM',
    'HIGH'
  ];


  bool isValid() {
    return title.isNotEmpty &&
           description.isNotEmpty &&
           estimatedHours > 0 &&
           dueDate.isAfter(DateTime.now()) &&
           validStatuses.contains(status) &&
           validPriorities.contains(priority);
  }

  // Helper methods
  bool get isPending => status == 'PENDING';
  bool get isAssigned => status == 'ASSIGNED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCompleted => status == 'COMPLETED';
  bool get isHighPriority => priority == 'HIGH';

  bool canBeAssignedTo(DateTime agentShiftEnd) {
    final estimatedCompletionTime = DateTime.now().add(
      Duration(hours: estimatedHours.ceil())
    );
    return estimatedCompletionTime.isBefore(agentShiftEnd) &&
           !isCompleted;
  }

  @override
  String toString() {
    return 'Ticket{id: $id, title: $title, status: $status, priority: $priority}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ticket &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}