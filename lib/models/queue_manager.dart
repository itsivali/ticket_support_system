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
}

class QueuedTicket {
  final String id;
  final String title;
  final Ticket ticket;
  final DateTime addedAt;
  double priority;

  QueuedTicket({
    required this.id,
    required this.title,
    required this.ticket,
    required this.priority,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();
}

class QueueSettings {
  final bool autoAssignEnabled;
  final int maxTicketsPerAgent;
  final Map<String, int> priorityWeights;

  const QueueSettings({
    this.autoAssignEnabled = true,
    this.maxTicketsPerAgent = 3,
    this.priorityWeights = const {
      'HIGH': 3,
      'MEDIUM': 2,
      'LOW': 1,
    },
  });
}

class QueueManager {
  final String id;
  final List<QueuedTicket> pendingTickets;
  final Map<String, List<String>> agentAssignments;
  final QueueSettings settings;

  QueueManager({
    required this.id,
    this.pendingTickets = const [],
    this.agentAssignments = const {},
    required this.settings,
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

    if (agent.shiftSchedule != null) {
      final shiftEnd = agent.shiftSchedule!.endTime;
      if (ticket.dueDate.isAfter(shiftEnd)) return false;
    }

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
      title: ticket.title,
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
                title: ticketJson['title'] as String,
                ticket: Ticket(
                  id: ticketJson['ticket']['id'] as String,
                  title: ticketJson['ticket']['title'] as String,
                  priority: ticketJson['ticket']['priority'] as String,
                  dueDate: DateTime.parse(ticketJson['ticket']['dueDate'] as String),
                  createdAt: DateTime.parse(ticketJson['ticket']['createdAt'] as String),
                  assignedTo: ticketJson['ticket']['assignedTo'] as String?,
                  status: ticketJson['ticket']['status'] as String,
                ),
                priority: ticketJson['priority'] as double,
                addedAt: DateTime.parse(ticketJson['addedAt'] as String),
              ))
          .toList(),
      agentAssignments: Map<String, List<String>>.from(json['agentAssignments']),
    );
  }
}