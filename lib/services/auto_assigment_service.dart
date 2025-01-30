import 'package:flutter/foundation.dart';
import '../models/queue_manager.dart';
import '../models/agent.dart';
import '../models/ticket.dart';
import '../utils/console_logger.dart';

class AutoAssignmentService {
  static const int MAX_TICKETS_PER_AGENT = 3;
  static const Duration MIN_REMAINING_SHIFT = Duration(hours: 1);

  Future<List<Assignment>> processQueue(
    List<Ticket> queuedTickets,
    List<Agent> availableAgents
  ) async {
    final assignments = <Assignment>[];
    final sortedTickets = _sortByPriority(queuedTickets);
    
    for (final ticket in sortedTickets) {
      final agent = _findBestMatch(ticket, availableAgents);
      if (agent != null) {
        assignments.add(Assignment(
          ticketId: ticket.id,
          agentId: agent.id,
          score: _calculateMatchScore(ticket, agent)
        ));
        
        // Update agent workload
        agent.currentTickets.add(ticket.id);
      }
    }
    
    return assignments;
  }

  Agent? _findBestMatch(Ticket ticket, List<Agent> agents) {
    return agents
        .where((a) => _isAgentEligible(a, ticket))
        .fold<Agent?>(null, (best, current) {
          if (best == null) return current;
          return _compareAgents(best, current, ticket);
        });
  }

  bool _isAgentEligible(Agent agent, Ticket ticket) {
    if (!agent.isAvailable || !agent.isOnline) return false;
    if (agent.currentTickets.length >= MAX_TICKETS_PER_AGENT) return false;
    
    if (agent.shiftSchedule != null) {
      final shiftTimeRemaining = agent.shiftSchedule!.endTime
          .difference(DateTime.now());
      
      if (shiftTimeRemaining < MIN_REMAINING_SHIFT) return false;
      if (shiftTimeRemaining.inHours < ticket.estimatedHours) return false;
    }
    
    return true;
  }

  double _calculateMatchScore(Ticket ticket, Agent agent) {
    var score = 100.0;
    
    // Workload penalty
    score -= (agent.currentTickets.length * 20);
    
    // Skills match bonus
    if (ticket.requiredSkills.any((s) => agent.skills.contains(s))) {
      score += 30;
    }
    
    // Shift time remaining
    if (agent.shiftSchedule != null) {
      final hoursLeft = agent.shiftSchedule!.endTime
          .difference(DateTime.now()).inHours;
      score += (hoursLeft - ticket.estimatedHours) * 5;
    }
    
    return score;
  }

  List<Ticket> _sortByPriority(List<Ticket> tickets) {
    return List<Ticket>.from(tickets)
      ..sort((a, b) {
        final priorityOrder = {'HIGH': 3, 'MEDIUM': 2, 'LOW': 1};
        return (priorityOrder[b.priority] ?? 0)
            .compareTo(priorityOrder[a.priority] ?? 0);
      });
  }
}

class Assignment {
  final String ticketId;
  final String agentId;
  final double score;

  Assignment({
    required this.ticketId,
    required this.agentId,
    required this.score,
  });
}