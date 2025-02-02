import '../models/ticket.dart';
import '../models/agent.dart';
import '../utils/console_logger.dart';

class WorkloadDistribution {
  static const double maxUtilization = 1.0;
  static const int maxTicketsPerAgent = 3;

  List<AgentWorkload> calculateWorkloads(List<Agent> agents) {
    return agents.map((agent) {
      final totalHours = agent.currentTickets.length * 8.0;
      final maxHours = agent.shiftSchedule?.hoursPerDay ?? 8.0;
      final utilization = totalHours / maxHours;
      
      return AgentWorkload(
        agentId: agent.id,
        totalHours: totalHours,
        utilizationPercentage: utilization,
      );
    }).toList();
  }

  Agent? findBestAgent(Ticket ticket, List<Agent> agents) {
    if (agents.isEmpty) return null;

    final availableAgents = agents.where((agent) => 
      agent.isAvailable && 
      agent.isOnline && 
      agent.currentTickets.length < maxTicketsPerAgent
    ).toList();

    if (availableAgents.isEmpty) return null;

    final workloads = calculateWorkloads(availableAgents);
    
    return availableAgents
        .where((agent) => _canHandleTicket(agent, ticket, workloads))
        .fold<Agent?>(null, (best, current) => 
            _compareAgents(best, current, workloads, ticket));
  }

  bool _canHandleTicket(
    Agent agent, 
    Ticket ticket, 
    List<AgentWorkload> workloads
  ) {
    final workload = workloads.firstWhere((w) => w.agentId == agent.id);
    final newUtilization = workload.utilizationPercentage + 
        (ticket.estimatedHours / 8.0);
    
    return newUtilization <= maxUtilization &&
           agent.skills.any((s) => ticket.requiredSkills.contains(s));
  }

  Agent? _compareAgents(
    Agent? best,
    Agent current,
    List<AgentWorkload> workloads,
    Ticket ticket
  ) {
    if (best == null) return current;

    final bestScore = _calculateAgentScore(best, workloads, ticket);
    final currentScore = _calculateAgentScore(current, workloads, ticket);

    return currentScore > bestScore ? current : best;
  }

  double _calculateAgentScore(
    Agent agent,
    List<AgentWorkload> workloads,
    Ticket ticket
  ) {
    final workload = workloads.firstWhere((w) => w.agentId == agent.id);
    final skillMatch = agent.skills
        .where((s) => ticket.requiredSkills.contains(s))
        .length;

    return (1 - workload.utilizationPercentage) * 0.7 + 
           (skillMatch / ticket.requiredSkills.length) * 0.3;
  }
}

class AgentWorkload {
  final String agentId;
  final double totalHours;
  final double utilizationPercentage;

  const AgentWorkload({
    required this.agentId,
    required this.totalHours,
    required this.utilizationPercentage,
  });

  bool canAcceptTicket(double hours) {
    return (utilizationPercentage + (hours / 8.0)) <= 1.0;
  }
}