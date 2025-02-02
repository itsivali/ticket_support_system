import '../models/ticket.dart';
import '../utils/console_logger.dart';

class WorkloadTracker {
  final Map<String, List<Ticket>> _assignments = {};
  final Map<String, double> _workloadHistory = {};
  static const double maxWorkload = 1.0;

  double getCurrentWorkload(String agentId) {
    final tickets = _assignments[agentId] ?? [];
    return tickets.fold(0.0, (sum, ticket) => 
      sum + (ticket.estimatedHours / 8.0));
  }

  Future<bool> addTicket(String agentId, Ticket ticket) async {
    try {
      if (!_canAddTicket(agentId, ticket)) {
        return false;
      }

      _assignments.putIfAbsent(agentId, () => []).add(ticket);
      _updateWorkloadHistory(agentId);
      
      return true;
    } catch (e) {
      ConsoleLogger.error('Error adding ticket to workload', e.toString());
      return false;
    }
  }

  bool _canAddTicket(String agentId, Ticket ticket) {
    final currentLoad = getCurrentWorkload(agentId);
    final additionalLoad = ticket.estimatedHours / 8.0;
    
    return (currentLoad + additionalLoad) <= maxWorkload;
  }

  void _updateWorkloadHistory(String agentId) {
    final currentLoad = getCurrentWorkload(agentId);
    _workloadHistory[agentId] = currentLoad;
  }

  Future<bool> removeTicket(String agentId, String ticketId) async {
    try {
      final tickets = _assignments[agentId];
      if (tickets == null) return false;

      final lengthBefore = tickets.length;
      tickets.removeWhere((t) => t.id == ticketId);
      final removed = tickets.length < lengthBefore;
      if (removed) {
        _updateWorkloadHistory(agentId);
      }
      
      return removed;
    } catch (e) {
      ConsoleLogger.error('Error removing ticket from workload', e.toString());
      return false;
    }
  }

  double getAverageWorkload(String agentId) {
    final history = _workloadHistory[agentId];
    return history ?? 0.0;
  }

  List<Ticket> getAssignedTickets(String agentId) {
    return List.unmodifiable(_assignments[agentId] ?? []);
  }

  void clearWorkload(String agentId) {
    _assignments.remove(agentId);
    _workloadHistory.remove(agentId);
  }
}