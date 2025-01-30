import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../models/agent.dart';

class QueueManager {
  final String id;
  final List<QueuedTicket> pendingTickets;
  final Map<String, List<String>> agentAssignments; // agentId -> ticketIds
  final QueueSettings settings;

  QueueManager({
    required this.id,
    this.pendingTickets = const [],
    this.agentAssignments = const {},
    required this.settings,
  });

  bool canAssignTicketTo(Agent agent, Ticket ticket) {
    if (!agent.isAvailable || !agent.isOnline) return false;
    
    final currentAssignments = agentAssignments[agent.id]?.length ?? 0;
    if (currentAssignments >= settings.maxTicketsPerAgent) return false;

    if (agent.shiftSchedule != null) {
      if (!agent.shiftSchedule!.isWorkingAt(ticket.dueDate)) return false;
    }

    return true;
  }

  List<Agent> getPotentialAgents(Ticket ticket, List<Agent> availableAgents) {
    return availableAgents
        .where((agent) => canAssignTicketTo(agent, ticket))
        .toList();
  }

  QueuedTicket? getNextTicketForAgent(Agent agent) {
    if (!agent.isAvailable) return null;

    return pendingTickets
        .where((ticket) => canAssignTicketTo(agent, ticket.ticket))
        .firstOrNull;
  }

  factory QueueManager.fromJson(Map<String, dynamic> json) {
    return QueueManager(
      id: json['_id'] ?? '',
      pendingTickets: (json['pendingTickets'] as List?)
          ?.map((t) => QueuedTicket.fromJson(t))
          .toList() ?? [],
      agentAssignments: Map<String, List<String>>.from(
        json['agentAssignments']?.map(
          (k, v) => MapEntry(k, List<String>.from(v))
        ) ?? {}
      ),
      settings: QueueSettings.fromJson(json['settings'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'pendingTickets': pendingTickets.map((t) => t.toJson()).toList(),
    'agentAssignments': agentAssignments,
    'settings': settings.toJson(),
  };
}

class QueueSettings {
  final bool autoAssignEnabled;
  final int maxTicketsPerAgent;
  final Duration reassignmentDelay;
  final Map<String, int> priorityWeights;

  const QueueSettings({
    this.autoAssignEnabled = true,
    this.maxTicketsPerAgent = 3,
    this.reassignmentDelay = const Duration(minutes: 15),
    this.priorityWeights = const {
      'HIGH': 3,
      'MEDIUM': 2,
      'LOW': 1
    },
  });

  factory QueueSettings.fromJson(Map<String, dynamic> json) {
    return QueueSettings(
      autoAssignEnabled: json['autoAssignEnabled'] ?? true,
      maxTicketsPerAgent: json['maxTicketsPerAgent'] ?? 3,
      reassignmentDelay: Duration(
        minutes: json['reassignmentDelayMinutes'] ?? 15
      ),
      priorityWeights: Map<String, int>.from(
        json['priorityWeights'] ?? const {
          'HIGH': 3, 
          'MEDIUM': 2,
          'LOW': 1
        }
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'autoAssignEnabled': autoAssignEnabled,
    'maxTicketsPerAgent': maxTicketsPerAgent,
    'reassignmentDelayMinutes': reassignmentDelay.inMinutes,
    'priorityWeights': priorityWeights,
  };
}