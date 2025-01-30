import '../models/ticket.dart';
import '../utils/priority_queue.dart';

class TicketQueueManager {
  final PriorityQueue<Ticket> _queue;
  
  static const Map<String, double> PRIORITY_WEIGHTS = {
    'HIGH': 3.0,
    'MEDIUM': 2.0,
    'LOW': 1.0
  };

  TicketQueueManager() : _queue = PriorityQueue<Ticket>((a, b) {
    // Compare due dates if priorities are equal
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

  Map<String, int> getQueueAnalytics() {
    final tickets = getPendingTickets();
    return {
      'total': tickets.length,
      'high': tickets.where((t) => t.priority == 'HIGH').length,
      'medium': tickets.where((t) => t.priority == 'MEDIUM').length,
      'low': tickets.where((t) => t.priority == 'LOW').length,
    };
  }
}