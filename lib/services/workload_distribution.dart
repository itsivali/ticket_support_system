class WorkloadDistributor {
  static const maxTicketsPerAgent = 3;
  static const minHoursRequired = 1.0;

  List<AgentWorkload> calculateWorkloads(List<Agent> agents) {
    return agents.map((agent) {
      final hoursLeft = agent.shiftSchedule?.endTime
          .difference(DateTime.now()).inHours.toDouble() ?? 0;
          
      return AgentWorkload(
        agentId: agent.id,
        currentTickets: agent.currentTickets.length,
        hoursRemaining: hoursLeft,  
        activeTicketIds: agent.currentTickets,
      );
    }).toList();
  }

  Agent? findBestAgent(Ticket ticket, List<Agent> agents) {
    final workloads = calculateWorkloads(agents);
    
    return agents.where((agent) {
      final workload = workloads
          .firstWhere((w) => w.agentId == agent.id);
      return workload.canAcceptTicket(ticket.estimatedHours);
    })
    .fold<Agent?>(null, (best, current) {
      if (best == null) return current;
      return _compareAgentWorkloads(best, current, workloads);
    });
  }

  Agent _compareAgentWorkloads(
    Agent a, 
    Agent b,
    List<AgentWorkload> workloads
  ) {
    final aWorkload = workloads
        .firstWhere((w) => w.agentId == a.id);
    final bWorkload = workloads
        .firstWhere((w) => w.agentId == b.id);
        
    return aWorkload.utilizationPercentage < bWorkload.utilizationPercentage 
        ? a : b;
  }
}