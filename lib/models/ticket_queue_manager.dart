import '../models/ticket.dart';
import '../models/agent.dart';
import '../utils/priority_queue.dart';

class TicketQueueManager {
  final PriorityQueue<Ticket> _queue;
  final Map<String, List<String>> _agentAssignments = {};
  
  static const Map<String, double> priorityWeights = {
    'HIGH': 3.0,
    'MEDIUM': 2.0,
    'LOW': 1.0
  };

  TicketQueueManager() : _queue = PriorityQueue<Ticket>((a, b) {
    // First compare priorities
    final priorityDiff = (priorityWeights[b.priority] ?? 1.0)
        .compareTo(priorityWeights[a.priority] ?? 1.0);
    
    if (priorityDiff != 0) return priorityDiff;
    
    // Then compare due dates for same priority
    return a.dueDate.compareTo(b.dueDate);
  });

  void addTicket(Ticket ticket) {
    final priority = _calculatePriority(ticket);
    _queue.enqueue(ticket, priority);
  }

  Ticket? getNextTicket() => _queue.dequeue();
  
  List<Ticket> getPendingTickets() => _queue.items;
  
  bool get isEmpty => _queue.isEmpty;
  
  int get size => _queue.length;

  double _calculatePriority(Ticket ticket) {
    double priority = priorityWeights[ticket.priority] ?? 1.0;
    
    // Factor in waiting time
    final waitingHours = DateTime.now().difference(DateTime.parse(ticket.createdAt)).inHours;
    priority += (waitingHours / 24.0); // Increase priority with wait time
    
    // Factor in due date proximity
    final hoursUntilDue = ticket.dueDate.difference(DateTime.now()).inHours;
    if (hoursUntilDue < 24) {
      priority *= 1.5; // Urgent multiplier
    }
    
    return priority;
  }

  bool canAssignToAgent(Ticket ticket, Agent agent) {
    if (!agent.isAvailable || !agent.isOnline) return false;
    
    final currentAssignments = _agentAssignments[agent.id]?.length ?? 0;
    if (currentAssignments >= 3) return false;

    if (agent.shiftSchedule != null) {
      if (!agent.shiftSchedule!.isWorkingAt(ticket.dueDate)) {
        return false;
      }
    }

    return true;
  }

  Agent? findBestAgent(Ticket ticket, List<Agent> availableAgents) {
    final eligibleAgents = availableAgents
        .where((agent) => canAssignToAgent(ticket, agent))
        .toList();

    if (eligibleAgents.isEmpty) return null;

    eligibleAgents.sort((a, b) {
      final aLoad = _agentAssignments[a.id]?.length ?? 0;
      final bLoad = _agentAssignments[b.id]?.length ?? 0;
      return aLoad.compareTo(bLoad);
    });
    
    return eligibleAgents.first;
  }

  Map<String, int> getQueueStats() {
    final tickets = _queue.items;
    final now = DateTime.now();
    
    return {
      'total': tickets.length,
      'high': tickets.where((t) => t.priority == 'HIGH').length,
      'medium': tickets.where((t) => t.priority == 'MEDIUM').length,
      'low': tickets.where((t) => t.priority == 'LOW').length,
      'urgent': tickets.where((t) => 
        t.dueDate.difference(now).inHours < 24).length,
    };
  }
}