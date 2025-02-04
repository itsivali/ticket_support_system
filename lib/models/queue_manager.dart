import 'package:flutter/foundation.dart';
import '../models/agent.dart';
import '../utils/console_logger.dart';

class AssignmentRule {
  final String id;
  final String name; 
  final String description;
  final String condition;
  final String priority;
  final bool isActive;
  final DateTime createdAt;
  final Map<String, dynamic>? parameters;

  AssignmentRule({
    required this.id,
    required this.name,
    required this.description,
    required this.priority, 
    required this.condition,
    this.isActive = true,
    this.parameters,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory AssignmentRule.fromJson(Map<String, dynamic> json) {
    return AssignmentRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      condition: json['condition'] as String, 
      priority: json['priority'] as String, 
      isActive: json['isActive'] as bool? ?? true,
      parameters: json['parameters'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, 
      'description': description,
      'condition': condition,
      'isActive': isActive,
      if (parameters != null) 'parameters': parameters,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AssignmentRule copyWith({
    String? id,
    String? name,
    String? description,
    String? condition,
    bool? isActive,
    Map<String, dynamic>? parameters,
    DateTime? createdAt,
  }) {
    return AssignmentRule(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      priority: priority,
      isActive: isActive ?? this.isActive,
      parameters: parameters ?? this.parameters,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class Ticket {
  final String id;
  final String title;
  final String priority;
  final DateTime dueDate;
  final DateTime createdAt;
  String? assignedTo;
  String status;

  Ticket({
    required this.id,
    required this.title,
    required this.priority,
    required this.dueDate,
    DateTime? createdAt,
    this.assignedTo,
    this.status = 'OPEN',
  }) : createdAt = createdAt ?? DateTime.now();

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: json['priority'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      assignedTo: json['assignedTo'] as String?,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'assignedTo': assignedTo,
      'status': status,
    };
  }
}

class QueuedTicket {
  factory QueuedTicket.fromJson(Map<String, dynamic> json) {
    return QueuedTicket(
      id: json['id'] as String,
      ticket: Ticket.fromJson(json['ticket'] as Map<String, dynamic>),
      priority: json['priority'] as double,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
    );
  }
  final String id;
  final Ticket ticket;
  final double priority;
  final DateTime queuedAt;

  QueuedTicket({
    required this.id,
    required this.ticket,
    required this.priority,
    required this.queuedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket': ticket.toJson(),
      'priority': priority,
      'queuedAt': queuedAt.toIso8601String(),
    };
  }
}

class QueueSettings {
  final bool autoAssignEnabled;
  final int maxTicketsPerAgent;
  final Map<String, int> priorityWeights;
  final List<AssignmentRule> rules;  

  QueueSettings({
    this.autoAssignEnabled = true,
    this.maxTicketsPerAgent = 5,
    required this.priorityWeights,
    required this.rules,
  });

factory QueueSettings.fromJson(Map<String, dynamic> json) {
  return QueueSettings(
    autoAssignEnabled: json['autoAssignEnabled'] as bool? ?? true,
    maxTicketsPerAgent: json['maxTicketsPerAgent'] as int? ?? 5,
    priorityWeights: Map<String, int>.from(json['priorityWeights'] as Map),
    rules: (json['rules'] as List?)
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
    };
  }

  QueueSettings copyWith({
    bool? autoAssignEnabled,
    int? maxTicketsPerAgent,
    Map<String, int>? priorityWeights,
    List<AssignmentRule>? rules,
  }) {
    return QueueSettings(
      autoAssignEnabled: autoAssignEnabled ?? this.autoAssignEnabled,
      maxTicketsPerAgent: maxTicketsPerAgent ?? this.maxTicketsPerAgent,
      priorityWeights: priorityWeights ?? this.priorityWeights,
      rules: rules ?? this.rules,
    );
  }
}

class QueueManager {
  final String id;
  QueueSettings settings; 
  final List<QueuedTicket> pendingTickets;
  final Map<String, List<String>> agentAssignments;
  final DateTime lastAssignmentCheck;

  QueueManager({
    required this.id,
    required this.settings,
    required this.pendingTickets,
    required this.agentAssignments,
    required this.lastAssignmentCheck,
  });

  QueueManager copyWith({
    String? id,
    QueueSettings? settings,
    List<QueuedTicket>? pendingTickets,
    Map<String, List<String>>? agentAssignments,
  }) {
    return QueueManager(
      id: id ?? this.id,
      settings: settings ?? this.settings,
      pendingTickets: pendingTickets ?? this.pendingTickets,
      agentAssignments: agentAssignments ?? this.agentAssignments,
      lastAssignmentCheck: DateTime.now(),
    );
  }

  int get size => pendingTickets.length;

  bool canAssignTicketTo(Agent agent, Ticket ticket) {
    if (!agent.isAvailable || !agent.isOnline) {
      return false;
    }
    
    final currentAssignments = agentAssignments[agent.id]?.length ?? 0;
    if (currentAssignments >= settings.maxTicketsPerAgent) {
      return false;
    }

    final shiftEnd = agent.shiftSchedule.endTime;
    if (ticket.dueDate.isAfter(shiftEnd)) return false;

    return true;
  }

  List<Agent> getPotentialAgents(Ticket ticket, List<Agent> availableAgents) {
    return availableAgents
        .where((agent) => canAssignTicketTo(agent, ticket))
        .toList();
  }

  void addTicket(Ticket ticket) {
    final queuedTicket = QueuedTicket(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ticket: ticket,
      priority: _calculatePriority(ticket),
      queuedAt: DateTime.now(),
    );
    pendingTickets.add(queuedTicket);
    _sortQueue();
  }

  double _calculatePriority(Ticket ticket) {
    double priority = settings.priorityWeights[ticket.priority]?.toDouble() ?? 1.0;
    
    final waitingTime = DateTime.now().difference(ticket.createdAt).inHours;
    priority += (waitingTime / 24.0);
    
    final timeUntilDue = ticket.dueDate.difference(DateTime.now()).inHours;
    if (timeUntilDue < 24) {
      priority *= 1.5;
    }
    
    return priority;
  }

  void _sortQueue() {
    pendingTickets.sort((a, b) => b.priority.compareTo(a.priority));
  }

  Map<String, int> getQueueStats() {
    return {
      'total': pendingTickets.length,
      'high': pendingTickets.where((qt) => qt.ticket.priority == 'HIGH').length,
      'medium': pendingTickets.where((qt) => qt.ticket.priority == 'MEDIUM').length,
      'low': pendingTickets.where((qt) => qt.ticket.priority == 'LOW').length,
      'urgent': pendingTickets.where((qt) => 
        qt.ticket.dueDate.difference(DateTime.now()).inHours < 24).length,
    };
  }

  QueuedTicket? getNextTicket() {
    return pendingTickets.isNotEmpty ? pendingTickets.first : null;
  }

  bool assignTicket(String ticketId, String agentId) {
    final index = pendingTickets.indexWhere((qt) => qt.ticket.id == ticketId);
    if (index == -1) return false;

    agentAssignments.putIfAbsent(agentId, () => []).add(ticketId);
    pendingTickets.removeAt(index);
    return true;
  }

  factory QueueManager.fromJson(Map<String, dynamic> json) {
    try {
      return QueueManager(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        settings: QueueSettings.fromJson(json['settings'] as Map<String, dynamic>),
        pendingTickets: (json['pendingTickets'] as List?)
            ?.map((ticket) => QueuedTicket.fromJson(ticket as Map<String, dynamic>))
            .toList() ?? [],
        agentAssignments: Map<String, List<String>>.from(
          json['agentAssignments'] as Map<String, dynamic>? ?? {},
        ),
        lastAssignmentCheck: DateTime.parse(json['lastAssignmentCheck'] as String? ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      ConsoleLogger.error('Error parsing QueueManager from JSON', e.toString());
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'settings': settings.toJson(),
      'pendingTickets': pendingTickets.map((qt) => qt.toJson()).toList(),
      'agentAssignments': agentAssignments,
    };
  }

  QueueManager copyWithSettings({QueueSettings? settings}) {
    return QueueManager(
      id: id,
      settings: settings ?? this.settings,
      pendingTickets: pendingTickets,
      agentAssignments: agentAssignments,
      lastAssignmentCheck: lastAssignmentCheck,
    );
  }
}

class QueueProvider with ChangeNotifier {
  QueueManager? queueManager;

  Future<void> updateRule(AssignmentRule updatedRule) async {
    
    final rules = queueManager?.settings.rules ?? [];
    final index = rules.indexWhere((rule) => rule.id == updatedRule.id);
    if (index != -1) {
      rules[index] = updatedRule;
      notifyListeners();
    }
  }
}