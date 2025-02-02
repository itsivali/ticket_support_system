import '../models/ticket.dart';
import '../models/agent.dart';
import '../services/workload_tracker.dart';
import '../services/notification_service.dart';
import '../utils/console_logger.dart';

class AutoDistributionService {
  final WorkloadTracker _workloadTracker;
  final NotificationService _notificationService;
  
  static const double workloadWeight = 20.0;
  static const double skillsMatchBonus = 30.0;
  static const double hoursRemainingWeight = 5.0;
  
  AutoDistributionService(this._workloadTracker, this._notificationService);

  Future<bool> distributeTicket(Ticket ticket, List<Agent> availableAgents) async {
    try {
      if (availableAgents.isEmpty) {
        ConsoleLogger.info('No available agents for ticket distribution');
        return false;
      }

      final scoredAgents = await _scoreAgents(ticket, availableAgents);
      if (scoredAgents.isEmpty) return false;

      final bestAgent = scoredAgents.first;
      await _assignTicket(ticket, bestAgent.agent);
      
      return true;
    } catch (e) {
      ConsoleLogger.error('Error distributing ticket', e.toString());
      return false;
    }
  }

  Future<List<ScoredAgent>> _scoreAgents(
    Ticket ticket, 
    List<Agent> agents
  ) async {
    final scoredAgents = <ScoredAgent>[];

    for (final agent in agents) {
      if (!_canAssignTicket(agent, ticket)) continue;
      
      final score = _calculateAssignmentScore(agent, ticket);
      scoredAgents.add(ScoredAgent(agent: agent, score: score));
    }

    scoredAgents.sort((a, b) => b.score.compareTo(a.score));
    return scoredAgents;
  }

  bool _canAssignTicket(Agent agent, Ticket ticket) {
    if (!agent.isAvailable || !agent.isOnline) return false;
    
    final currentWorkload = _workloadTracker.getCurrentWorkload(agent.id);
    if (currentWorkload >= 1.0) return false;

    if (agent.shiftSchedule != null) {
      final remainingHours = agent.shiftSchedule!.endTime
          .difference(DateTime.now()).inHours;
      if (remainingHours < ticket.estimatedHours) return false;
    }

    return true;
  }

  double _calculateAssignmentScore(Agent agent, Ticket ticket) {
    double score = 100.0;
    
    // Workload factor
    score -= _workloadTracker.getCurrentWorkload(agent.id) * workloadWeight;
    
    // Skills match
    if (agent.skills.any((s) => ticket.requiredSkills.contains(s))) {
      score += SKILLS_MATCH_BONUS;
    }
    
    // Shift time remaining
    if (agent.shiftSchedule != null) {
      final hoursLeft = agent.shiftSchedule!.endTime
          .difference(DateTime.now()).inHours;
      score += (hoursLeft - ticket.estimatedHours) * HOURS_REMAINING_WEIGHT;
    }
    
    return score.clamp(0.0, 100.0);
  }

  Future<void> _assignTicket(Ticket ticket, Agent agent) async {
    try {
      await _workloadTracker.addTicket(agent.id, ticket);
      await _notificationService.notifyAgent(
        agent.id,
        'New ticket assigned',
        'Ticket: ${ticket.title}\nPriority: ${ticket.priority}',
      );
    } catch (e) {
      ConsoleLogger.error('Error assigning ticket', e.toString());
      rethrow;
    }
  }
}

class ScoredAgent {
  final Agent agent;
  final double score;

  ScoredAgent({required this.agent, required this.score});
}