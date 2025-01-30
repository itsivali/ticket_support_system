import '../models/ticket.dart';
import '../models/agent.dart';
import '../utils/workload_tracker.dart';

class AutoDistributionService {
  final WorkloadTracker _workloadTracker;
  final NotificationService _notificationService;
  
  AutoDistributionService(this._workloadTracker, this._notificationService);

  Future<DistributionResult> distributeTicket(Ticket ticket, List<Agent> agents) async {
    final availableAgents = _filterAvailableAgents(agents);
    final selectedAgent = _selectBestAgent(ticket, availableAgents);
    
    if (selectedAgent != null) {
      await _assignTicket(ticket, selectedAgent);
      return DistributionResult(
        success: true,
        agentId: selectedAgent.id,
        message: 'Ticket assigned successfully'
      );
    }

    return DistributionResult(
      success: false,
      message: 'No available agents found'
    );
  }

  List<Agent> _filterAvailableAgents(List<Agent> agents) {
    return agents.where((agent) =>
      agent.isAvailable &&
      agent.isOnline &&
      _workloadTracker.canAcceptTicket(agent.id)
    ).toList();
  }

  Agent? _selectBestAgent(Ticket ticket, List<Agent> agents) {
    if (agents.isEmpty) return null;
    
    return agents.reduce((a, b) {
      final scoreA = _calculateAssignmentScore(a, ticket);
      final scoreB = _calculateAssignmentScore(b, ticket);
      return scoreA > scoreB ? a : b;
    });
  }

  double _calculateAssignmentScore(Agent agent, Ticket ticket) {
    double score = 100;
    
    // Workload factor
    score -= _workloadTracker.getCurrentWorkload(agent.id) * 20;
    
    // Skills match
    if (agent.skills.any((s) => ticket.requiredSkills.contains(s))) {
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

  Future<void> _assignTicket(Ticket ticket, Agent agent) async {
    await _workloadTracker.addTicket(agent.id, ticket);
    await _notificationService.notifyAgent(
      agent.id,
      'New ticket assigned: ${ticket.title}'
    );
  }
}