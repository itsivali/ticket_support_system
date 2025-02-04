import '../models/assignment_rule.dart';
class QueueSettings {
  final bool autoAssignEnabled;
  final int maxTicketsPerAgent;
  final AssignmentRule defaultRule;
  final Map<String, int> priorityWeights;
  final List<AssignmentRule> rules;
  final List<AssignmentRule> assignmentRules;

  QueueSettings({
    required this.autoAssignEnabled,
    required this.maxTicketsPerAgent,
    required this.defaultRule,
    required this.priorityWeights,
    required this.rules,
    required this.assignmentRules,
  });

  factory QueueSettings.fromJson(Map<String, dynamic> json) {
    return QueueSettings(
      autoAssignEnabled: json['autoAssignEnabled'] as bool,
      maxTicketsPerAgent: json['maxTicketsPerAgent'] as int,
      priorityWeights: Map<String, int>.from(json['priorityWeights']),
      rules: (json['rules'] as List?)
          ?.map((rule) => AssignmentRule.fromJson(rule as Map<String, dynamic>))
          .toList() ?? [],
      defaultRule: AssignmentRule.fromJson(json['defaultRule'] as Map<String, dynamic>),
      assignmentRules: (json['assignmentRules'] as List?)
          ?.map((rule) => AssignmentRule.fromJson(rule as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoAssignEnabled': autoAssignEnabled,
      'maxTicketsPerAgent': maxTicketsPerAgent,
      'priorityWeights': priorityWeights,
      'rules': rules.map((rule) => rule.toJson()).toList(),
      'defaultRule': defaultRule.toJson(),
      'assignmentRules': assignmentRules.map((rule) => rule.toJson()).toList(),
    };
  }

  QueueSettings copyWith({
    bool? autoAssignEnabled,
    int? maxTicketsPerAgent,
    Map<String, int>? priorityWeights,
    List<AssignmentRule>? rules,
    AssignmentRule? defaultRule,
    List<AssignmentRule>? assignmentRules,
  }) {
    return QueueSettings(
      autoAssignEnabled: autoAssignEnabled ?? this.autoAssignEnabled,
      maxTicketsPerAgent: maxTicketsPerAgent ?? this.maxTicketsPerAgent,
      priorityWeights: priorityWeights ?? this.priorityWeights,
      rules: rules ?? this.rules,
      defaultRule: defaultRule ?? this.defaultRule,
      assignmentRules: assignmentRules ?? this.assignmentRules,
    );
  }
}