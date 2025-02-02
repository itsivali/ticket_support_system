import '../models/ticket.dart';
import '../models/agent.dart';
import '../models/shift_schedule.dart';
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

    if (agent.currentTickets.length >= maxTicketsPerAgent) {
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
    final updatedTicket = Ticket(
      id: ticket.id,
      title: ticket.title,
      description: ticket.description,
      assignedTo: agent.id,
      status: 'IN_PROGRESS',
      dueDate: ticket.dueDate,
      estimatedHours: ticket.estimatedHours,
      priority: ticket.priority,
      createdAt: ticket.createdAt,
      lastUpdated: DateTime.now().toIso8601String(),
    );

    final List<String> updatedTickets = List.from(agent.currentTickets)..add(ticket.id);
    final updatedAgent = Agent(
      id: agent.id,
      name: agent.name,
      email: agent.email,
      role: agent.role,
      currentTickets: updatedTickets,
      lastAssignment: DateTime.now().toIso8601String(),
      isAvailable: agent.isAvailable,
      isOnline: agent.isOnline,
      shiftSchedule: agent.shiftSchedule,
    );

    await Future.wait([
      _ticketService.updateTicket(updatedTicket),
      _agentService.updateAgent(updatedAgent.id, updatedAgent),
    ]);
  }

  Future<List<Agent>> getEligibleAgents(Ticket ticket) async {
    final agents = await _agentService.getAgents();
    return agents.where((agent) => _canAssignTicket(ticket, agent)).toList();
  }
}