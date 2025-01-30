class AgentWorkload {
  final String agentId;
  final int currentTickets;
  final double hoursRemaining;
  final List<String> activeTicketIds;
  
  AgentWorkload({
    required this.agentId,
    this.currentTickets = 0,
    this.hoursRemaining = 0,
    this.activeTicketIds = const [],
  });

  bool canAcceptTicket(double estimatedHours) {
    return currentTickets < 3 && hoursRemaining >= estimatedHours;
  }

  double get utilizationPercentage => 
    currentTickets > 0 ? (currentTickets / 3) * 100 : 0;
}