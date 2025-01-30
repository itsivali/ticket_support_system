class WorkloadTracker {
  final Map<String, AgentWorkload> _workloads = {};
  static const int MAX_TICKETS = 3;
  static const double MAX_HOURS = 8.0;

  bool canAcceptTicket(String agentId) {
    final workload = _workloads[agentId];
    if (workload == null) return true;
    return workload.currentTickets < MAX_TICKETS && 
           workload.allocatedHours < MAX_HOURS;
  }

  double getCurrentWorkload(String agentId) {
    return _workloads[agentId]?.utilizationPercentage ?? 0.0;
  }

  Future<void> addTicket(String agentId, Ticket ticket) async {
    if (!_workloads.containsKey(agentId)) {
      _workloads[agentId] = AgentWorkload(agentId: agentId);
    }
    _workloads[agentId]!.addTicket(ticket);
  }

  WorkloadMetrics getMetrics(String agentId) {
    final workload = _workloads[agentId];
    if (workload == null) {
      return WorkloadMetrics.empty(agentId);
    }
    return workload.metrics;
  }
}

class AgentWorkload {
  final String agentId;
  final List<Ticket> tickets = [];
  double allocatedHours = 0.0;

  AgentWorkload({required this.agentId});

  void addTicket(Ticket ticket) {
    tickets.add(ticket);
    allocatedHours += ticket.estimatedHours;
  }

  int get currentTickets => tickets.length;
  double get utilizationPercentage => 
      (allocatedHours / WorkloadTracker.MAX_HOURS) * 100;

  WorkloadMetrics get metrics => WorkloadMetrics(
    agentId: agentId,
    ticketCount: currentTickets,
    allocatedHours: allocatedHours,
    utilization: utilizationPercentage
  );
}

class WorkloadMetrics {
  final String agentId;
  final int ticketCount;
  final double allocatedHours;
  final double utilization;

  const WorkloadMetrics({
    required this.agentId,
    required this.ticketCount,
    required this.allocatedHours,
    required this.utilization,
  });

  factory WorkloadMetrics.empty(String agentId) => WorkloadMetrics(
    agentId: agentId,
    ticketCount: 0,
    allocatedHours: 0.0,
    utilization: 0.0,
  );
}