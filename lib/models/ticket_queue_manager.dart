import '../models/ticket.dart';
import '../utils/priority_queue.dart';
import '../models/agent.dart';

class TicketQueueManager {
  final PriorityQueue<Ticket> _queue;
  
  static const Map<String, double> PRIORITY_WEIGHTS = {
    'HIGH': 3.0,
    'MEDIUM': 2.0,
    'LOW': 1.0
  };

  TicketQueueManager() : _queue = PriorityQueue<Ticket>((a, b) {
    // First compare priorities
    final priorityDiff = (PRIORITY_WEIGHTS[b.priority] ?? 1.0)
        .compareTo(PRIORITY_WEIGHTS[a.priority] ?? 1.0);
    
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
    double priority = PRIORITY_WEIGHTS[ticket.priority] ?? 1.0;
    
    // Factor in waiting time
    final waitingHours = DateTime.now().difference(ticket.createdAt).inHours;
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
    if (agent.currentTickets.length >= 3) return false;
    
    // Check shift schedule
    if (agent.shiftSchedule != null) {
      final shiftEnd = agent.shiftSchedule!.endTime;
      
      // Ensure ticket due date is within shift
      if (ticket.dueDate.isAfter(shiftEnd)) return false;
      
      // Ensure enough time to complete ticket
      final remainingHours = shiftEnd.difference(DateTime.now()).inHours;
      if (remainingHours < ticket.estimatedHours) return false;
    }
    
    return true;
  }

  Agent? findBestAgent(Ticket ticket, List<Agent> availableAgents) {
    final eligibleAgents = availableAgents
        .where((agent) => canAssignToAgent(ticket, agent))
        .toList();

    if (eligibleAgents.isEmpty) return null;

    // Sort by workload and return agent with least load
    eligibleAgents.sort((a, b) => 
      a.currentTickets.length.compareTo(b.currentTickets.length));
    
    return eligibleAgents.first;
  }

  Map<String, dynamic> getQueueStats() {
    final tickets = getPendingTickets();
    return {
      'total': tickets.length,
      'high': tickets.where((t) => t.priority == 'HIGH').length,
      'medium': tickets.where((t) => t.priority == 'MEDIUM').length,
      'low': tickets.where((t) => t.priority == 'LOW').length,
      'urgent': tickets.where((t) => 
        t.dueDate.difference(DateTime.now()).inHours < 24).length,
    };
  }
}