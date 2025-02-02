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
  static const double maxWorkload = 1.0;
  
  AutoDistributionService(this._workloadTracker, this._notificationService);

  Future<bool> distributeTicket(Ticket ticket, List<Agent> availableAgents) async {
    try {
      if (!_isValidTicket(ticket) || availableAgents.isEmpty) {
        ConsoleLogger.info('Invalid ticket or no available agents');
        return false;
      }

      final scoredAgents = await _scoreAgents(ticket, availableAgents);
      if (scoredAgents.isEmpty) {
        ConsoleLogger.info('No eligible agents found for ticket');
        return false;
      }

      final bestAgent = scoredAgents.first;
      return await _assignTicket(ticket, bestAgent.agent);
    } catch (e) {
      ConsoleLogger.error('Distribution failed', e.toString());
      return false;
    }
  }

  bool _isValidTicket(Ticket ticket) {
    return ticket.estimatedHours > 0 && 
           ticket.priority.isNotEmpty && 
           ticket.status == 'OPEN';
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
    if (currentWorkload >= maxWorkload) return false;

    if (agent.shiftSchedule != null) {
      final remainingHours = agent.shiftSchedule!.getRemainingHours();
      if (remainingHours < ticket.estimatedHours) return false;
    }

    return true;
  }

  double _calculateAssignmentScore(Agent agent, Ticket ticket) {
    double score = 100.0;
    
    // Workload impact
    final workloadImpact = _workloadTracker.getCurrentWorkload(agent.id);
    score -= workloadImpact * workloadWeight;
    
    // Skills matching
    final skillsMatch = agent.skills.where(
      (skill) => ticket.requiredSkills.contains(skill)
    ).length;
    score += (skillsMatch / ticket.requiredSkills.length) * skillsMatchBonus;
    
    // Time availability
    if (agent.shiftSchedule != null) {
      final hoursLeft = agent.shiftSchedule!.getRemainingHours();
      final timeScore = (hoursLeft - ticket.estimatedHours) * hoursRemainingWeight;
      score += timeScore.clamp(0.0, hoursRemainingWeight * 8);
    }
    
    return score.clamp(0.0, 100.0);
  }

  Future<bool> _assignTicket(Ticket ticket, Agent agent) async {
    try {
      if (await _workloadTracker.addTicket(agent.id, ticket)) {
        await _notificationService.notify(
          recipientId: agent.id,
          title: 'New Ticket Assigned',
          message: 'Ticket ${ticket.id} has been assigned to you',
          type: 'ASSIGNMENT',
        );
        return true;
      }
      return false;
    } catch (e) {
      ConsoleLogger.error('Assignment failed', e.toString());
      return false;
    }
  }
}

class ScoredAgent {
  final Agent agent;
  final double score;

  const ScoredAgent({
    required this.agent, 
    required this.score,
  });
}