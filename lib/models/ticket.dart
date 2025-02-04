import 'package:ticket_support_system/utils/console_logger.dart';

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
  try {
    return Ticket(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      priority: json['priority']?.toString() ?? 'MEDIUM',
      assignedTo: json['assignedTo']?.toString(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      dueDate: json['dueDate'] != null 
          ? DateTime.parse(json['dueDate'].toString())
          : DateTime.now().add(const Duration(days: 1)),
      estimatedHours: (json['estimatedHours'] as num?)?.toInt() ?? 1,
      requiredSkills: (json['requiredSkills'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      lastUpdated: json['lastUpdated'] != null 
          ? DateTime.parse(json['lastUpdated'].toString())
          : DateTime.now(),
    );
  } catch (e) {
    ConsoleLogger.error('Error parsing Ticket from JSON', 'Data: $json\nError: $e');
    rethrow;
  }
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