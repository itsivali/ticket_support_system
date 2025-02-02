import '../models/ticket.dart';
import '../models/agent.dart';
import '../utils/console_logger.dart';
import './ticket_service.dart';
import './agent_service.dart';

class AutoAssignmentService {
  final TicketService _ticketService;
  final AgentService _agentService;
  static const int maxTicketsPerAgent = 3;

  AutoAssignmentService(this._ticketService, this._agentService);

  Future<bool> assignTicket(String ticketId, String agentId) async {
    try {
      final ticket = await _ticketService.getTicket(ticketId);
      final agent = await _agentService.getAgent(agentId);

      if (!_canAssignTicket(ticket, agent)) {
        return false;
      }

      await _processAssignment(ticket, agent);
      return true;
    } catch (e) {
      ConsoleLogger.error('Assignment failed', e.toString());
      return false;
    }
  }

  bool _canAssignTicket(Ticket ticket, Agent agent) {
    if (!agent.isAvailable || !agent.isOnline) {
      return false;
    }

    if (agent.currentTickets.length >= MAX_TICKETS_PER_AGENT) {
      return false;
    }

    if (agent.shiftSchedule != null) {
      if (!agent.shiftSchedule!.canHandleTicket(ticket)) {
        return false;
      }
    }

    return true;
  }

  Future<void> _processAssignment(Ticket ticket, Agent agent) async {
    final updates = {
      'assignedTo': agent.id,
      'status': 'IN_PROGRESS',
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    final agentUpdates = {
      'currentTickets': [...agent.currentTickets, ticket.id],
      'lastAssignment': DateTime.now().toIso8601String(),
    };

    ticket.assignedTo = agent.id;
    ticket.status = 'IN_PROGRESS';
    ticket.lastUpdated = DateTime.now().toIso8601String();

    agent.currentTickets.add(ticket.id);
    agent.lastAssignment = DateTime.now().toIso8601String();

    await Future.wait([
      _ticketService.updateTicket(ticket),
      _agentService.updateAgent(agent),
    ]);
  }

  Future<List<Agent>> getEligibleAgents(Ticket ticket) async {
    final agents = await _agentService.getAgents();
    return agents.where((agent) => _canAssignTicket(ticket, agent)).toList();
  }
}