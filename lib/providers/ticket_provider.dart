import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../models/agent.dart';
import '../services/ticket_service.dart';
import '../utils/console_logger.dart';

class TicketProvider with ChangeNotifier {
  final TicketService _ticketService = TicketService();

  List<Ticket> _tickets = [];
  List<Agent> _agents = [];
  bool _isLoading = false;
  String? _error;

  List<Ticket> get tickets => _tickets;
  List<Agent> get agents => _agents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTickets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _tickets = await _ticketService.getTickets();
    } catch (e) {
      ConsoleLogger.error('Error fetching tickets', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<void> deleteTicket(String ticketId) async {
  try {
    if (!_tickets.any((ticket) => ticket.id == ticketId)) {
      throw Exception('Ticket ID $ticketId not found in the list');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    await _ticketService.deleteTicket(ticketId);
    _tickets.removeWhere((ticket) => ticket.id == ticketId);
    ConsoleLogger.info('Ticket $ticketId deleted successfully');
  } catch (e, stack) {
    ConsoleLogger.error('Error deleting ticket: $e\n$stack');
    _error = 'Failed to delete ticket: ${e.toString()}';
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  Future<void> fetchAgents() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _agents = await _ticketService.getAgents();
    } catch (e) {
      ConsoleLogger.error('Error fetching agents', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTicket(Ticket ticket) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newTicket = await _ticketService.createTicket(ticket);
      _tickets.add(newTicket);
      ConsoleLogger.info('Ticket created successfully');
    } catch (e) {
      ConsoleLogger.error('Error creating ticket', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTicket(Ticket ticket) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedTicket = await _ticketService.updateTicket(ticket);
      final index = _tickets.indexWhere((t) => t.id == updatedTicket.id);
      if (index != -1) {
        _tickets[index] = updatedTicket;
        ConsoleLogger.info('Ticket updated successfully');
      }
    } catch (e) {
      ConsoleLogger.error('Error updating ticket', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> assignTicket(String ticketId, String agentId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _ticketService.assignTicket(ticketId, agentId);
      await fetchTickets();
      ConsoleLogger.info('Ticket $ticketId assigned to agent $agentId');
    } catch (e, stack) {
      ConsoleLogger.error('Error assigning ticket: $e\n$stack');
      _error = 'Failed to assign ticket: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}