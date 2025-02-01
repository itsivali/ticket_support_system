import '../models/agent.dart';
import '../models/ticket.dart';

class WorkloadManager {
  static const int MAX_WORKLOAD = 24; // hours
  static const int MAX_TICKETS = 3;

  bool canAssignTicket(Agent agent, Ticket ticket) {
    // Current workload check
    final currentWorkload = agent.currentTickets.length;
    if (currentWorkload >= MAX_TICKETS) return false;

    // Shift validation
    if (agent.shiftSchedule != null) {
      final shiftEnd = agent.shiftSchedule!.endTime;
      final ticketDue = ticket.dueDate;
      
      if (ticketDue.isAfter(shiftEnd)) return false;
      
      final remainingTime = shiftEnd.difference(DateTime.now());
      if (remainingTime.inHours < ticket.estimatedHours) return false;
    }

    return true;
  }

  double calculateWorkloadScore(Agent agent) {
    double score = 0;
    
    // Base workload score
    score += (agent.currentTickets.length / MAX_TICKETS) * 100;
    
    // Shift time remaining factor
    if (agent.shiftSchedule != null) {
      final remainingHours = agent.shiftSchedule!.endTime
          .difference(DateTime.now()).inHours;
      score += ((MAX_WORKLOAD - remainingHours) / MAX_WORKLOAD) * 50;
    }

    return score;
  }

  List<Agent> getAvailableAgents(List<Agent> agents, Ticket ticket) {
    return agents.where((agent) => 
      canAssignTicket(agent, ticket)
    ).toList()
      ..sort((a, b) => 
        calculateWorkloadScore(a).compareTo(calculateWorkloadScore(b))
      );
  }
}