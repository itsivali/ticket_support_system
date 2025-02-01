import '../models/ticket.dart';
import '../models/agent.dart';
import '../models/ticket_queue_manager.dart';
import '../utils/console_logger.dart';

class AutoAssignmentService {
  final TicketQueueManager _queueManager;
  
  AutoAssignmentService(this._queueManager);

  Future<void> processQueue(List<Agent> availableAgents) async {
    if (_queueManager.isEmpty) return;

    ConsoleLogger.info(
      'Processing ticket queue',
      'Available agents: ${availableAgents.length}'
    );

    while (!_queueManager.isEmpty) {
      final ticket = _queueManager.getNextTicket();
      if (ticket == null) break;

      final agent = _queueManager.findBestAgent(ticket, availableAgents);
      
      if (agent != null) {
        await _assignTicket(ticket, agent);
        ConsoleLogger.info(
          'Assigned ticket automatically',
          'Ticket: ${ticket.id}\nAgent: ${agent.name}'
        );
      } else {
        // Put ticket back in queue if no agent available
        _queueManager.addTicket(ticket);
        ConsoleLogger.info(
          'No eligible agent found',
          'Ticket returned to queue: ${ticket.id}'
        );
        break; // Stop processing if we can't assign current ticket
      }
    }
  }

  Future<bool> manuallyAssignTicket(Ticket ticket, Agent agent) async {
    if (!_queueManager.canAssignToAgent(ticket, agent)) {
      ConsoleLogger.error(
        'Cannot assign ticket to agent',
        'Agent: ${agent.name}\nReason: Not eligible'
      );
      return false;
    }

    await _assignTicket(ticket, agent);
    ConsoleLogger.info(
      'Manually assigned ticket',
      'Ticket: ${ticket.id}\nAgent: ${agent.name}'
    );
    return true;
  }

  Future<void> _assignTicket(Ticket ticket, Agent agent) async {
    // Update ticket
    ticket.assignedTo = agent.id;
    ticket.status = 'IN_PROGRESS';
    
    // Update agent
    agent.currentTickets.add(ticket.id);
    
    // Save changes
    await Future.wait([
      _updateTicket(ticket),
      _updateAgent(agent),
    ]);
  }

  Future<void> _updateTicket(Ticket ticket) async {
    // Implement API call to update ticket
  }

  Future<void> _updateAgent(Agent agent) async {
    // Implement API call to update agent
  }
}