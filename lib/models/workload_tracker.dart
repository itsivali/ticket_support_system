import 'ticket.dart';

class WorkloadTracker {
  final Map<String, AgentWorkload> _workloads = {};
  static const double maxHoursPerDay = 8.0;

  AgentWorkload getAgentWorkload(String agentId) {
    return _workloads.putIfAbsent(
      agentId,
      () => AgentWorkload(agentId: agentId),
    );
  }

  bool canAcceptTicket(String agentId) {
    final workload = _workloads[agentId];
    if (workload == null) return true;
    return workload.canAcceptMore;
  }

  Future<void> addTicket(String agentId, Ticket ticket) async {
    final workload = getAgentWorkload(agentId);
    workload.addTicket(ticket);
  }

  Future<void> removeTicket(String agentId, String ticketId) async {
    final workload = _workloads[agentId];
    workload?.removeTicket(ticketId);
  }

  WorkloadMetrics getMetrics(String agentId) {
    final workload = _workloads[agentId];
    if (workload == null) return WorkloadMetrics.empty(agentId);
    return workload.metrics;
  }
}

class AgentWorkload {
  final String agentId;
  final List<Ticket> _tickets = [];
  double _allocatedHours = 0.0;

  AgentWorkload({required this.agentId});

  bool get canAcceptMore =>
      _tickets.length < 3 &&
      _allocatedHours < WorkloadTracker.maxHoursPerDay;

  void addTicket(Ticket ticket) {
    if (!canAcceptMore) {
      throw StateError('Agent workload limit exceeded');
    }
    _tickets.add(ticket);
    _allocatedHours += ticket.estimatedHours;
  }

  void removeTicket(String ticketId) {
    final ticket = _tickets.firstWhere((t) => t.id == ticketId);
    _tickets.remove(ticket);
    _allocatedHours -= ticket.estimatedHours;
  }

  WorkloadMetrics get metrics => WorkloadMetrics(
        agentId: agentId,
        ticketCount: _tickets.length,
        allocatedHours: _allocatedHours,
        utilization: _allocatedHours / WorkloadTracker.maxHoursPerDay * 100,
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
