import 'package:equatable/equatable.dart';

class AssignmentRule extends Equatable {
  final String id;
  final String name;
  final String description;
  final String condition;
  final String priority;
  final double weight;
  final bool isActive;

  const AssignmentRule({
    required this.id,
    required this.name,
    required this.description,
    required this.condition,
    required this.priority,
    this.weight = 1.0,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, description, condition, priority, weight, isActive];

  AssignmentRule copyWith({
    String? id,
    String? name,
    String? description,
    String? condition,
    String? priority,
    double? weight,
    bool? isActive,
  }) {
    return AssignmentRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      priority: priority ?? this.priority,
      weight: weight ?? this.weight,
      isActive: isActive ?? this.isActive,
    );
  }

  factory AssignmentRule.fromJson(Map<String, dynamic> json) {
    return AssignmentRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      condition: json['condition'] as String,
      priority: json['priority'] as String,
      weight: (json['weight'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'condition': condition,
      'priority': priority,
      'weight': weight,
      'isActive': isActive,
    };
  }
}