import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../models/agent.dart';
import '../services/ticket_service.dart';
import '../utils/logger.dart';

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
      AppLogger.error('Error fetching tickets', error: e);
      _error = e.toString();
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
      AppLogger.error('Error fetching agents', error: e);
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
      AppLogger.info('Ticket created successfully');
    } catch (e) {
      AppLogger.error('Error creating ticket', error: e);
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
    } catch (e) {
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

      await _ticketService.updateTicket(ticket);
      final index = _tickets.indexWhere((t) => t.id == ticket.id);
      _tickets[index] = ticket;
      AppLogger.info('Ticket updated successfully');
    } catch (e) {
      AppLogger.error('Error updating ticket', error: e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
Future<void> deleteTicket(String id) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _ticketService.deleteTicket(id);
    _tickets.removeWhere((ticket) => ticket.id == id);
    AppLogger.info('Ticket deleted successfully');
  } catch (e) {
    AppLogger.error('Error deleting ticket', error: e);
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
}