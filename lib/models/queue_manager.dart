import '../models/agent.dart';


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
  final String id;
  final Ticket ticket;
  final double priority;
  final DateTime queuedAt;
  bool isExpanded;

  // Add title getter
  String get title => ticket.title;

  QueuedTicket({
    required this.id,
    required this.ticket,
    required this.priority,
    DateTime? queuedAt,
    this.isExpanded = false,
  }) : queuedAt = queuedAt ?? DateTime.now();

  factory QueuedTicket.fromJson(Map<String, dynamic> json) {
    return QueuedTicket(
      id: json['id'] as String,
      ticket: Ticket.fromJson(json['ticket'] as Map<String, dynamic>),
      priority: json['priority'] as double,
      queuedAt: DateTime.parse(json['queuedAt'] as String),
      isExpanded: json['isExpanded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticket': ticket.toJson(),
      'priority': priority,
      'queuedAt': queuedAt.toIso8601String(),
      'isExpanded': isExpanded,
    };
  }

  @override
  String toString() => 'QueuedTicket(id: $id, title: ${ticket.title}, priority: $priority, queuedAt: $queuedAt, isExpanded: $isExpanded)';
}

class QueueSettings {
  final bool autoAssignEnabled;
  final int maxTicketsPerAgent;
  final Map<String, int> priorityWeights;

  QueueSettings({
    required this.autoAssignEnabled,
    required this.maxTicketsPerAgent,
    required this.priorityWeights,
  });

  factory QueueSettings.fromJson(Map<String, dynamic> json) {
    return QueueSettings(
      autoAssignEnabled: json['autoAssignEnabled'] as bool,
      maxTicketsPerAgent: json['maxTicketsPerAgent'] as int,
      priorityWeights: Map<String, int>.from(json['priorityWeights']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'autoAssignEnabled': autoAssignEnabled,
      'maxTicketsPerAgent': maxTicketsPerAgent,
      'priorityWeights': priorityWeights,
    };
  }

  QueueSettings copyWith({bool? autoAssignEnabled}) {
    return QueueSettings(
      autoAssignEnabled: autoAssignEnabled ?? this.autoAssignEnabled,
      maxTicketsPerAgent: maxTicketsPerAgent,
      priorityWeights: priorityWeights,
    );
  }
}

class QueueManager {
  final String id;
  QueueSettings settings;
  final List<QueuedTicket> pendingTickets;
  final Map<String, List<String>> agentAssignments;

  QueueManager({
    required this.id,
    required this.settings,
    required this.pendingTickets,
    required this.agentAssignments,
  });

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
    return QueueManager(
      id: json['id'] as String,
      settings: QueueSettings(
        autoAssignEnabled: json['settings']['autoAssignEnabled'] as bool,
        maxTicketsPerAgent: json['settings']['maxTicketsPerAgent'] as int,
        priorityWeights: Map<String, int>.from(json['settings']['priorityWeights']),
      ),
      pendingTickets: (json['pendingTickets'] as List)
          .map((ticketJson) => QueuedTicket(
                id: ticketJson['id'] as String,
                ticket: Ticket.fromJson(ticketJson['ticket'] as Map<String, dynamic>),
                priority: ticketJson['priority'] as double,
                queuedAt: DateTime.parse(ticketJson['queuedAt'] as String),
              ))
          .toList(),
      agentAssignments: Map<String, List<String>>.from(json['agentAssignments']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'settings': settings.toJson(),
      'pendingTickets': pendingTickets.map((qt) => qt.toJson()).toList(),
      'agentAssignments': agentAssignments,
    };
  }
}