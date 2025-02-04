import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';
import '../utils/console_logger.dart';


class TicketProvider with ChangeNotifier {
  final TicketService _ticketService = TicketService();
  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _error;

  List<Ticket> get tickets => List.unmodifiable(_tickets);
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchTickets() async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _error = null;
      final fetchedTickets = await _ticketService.getTickets();
      _tickets = fetchedTickets;
    } catch (e) {
      ConsoleLogger.error('Error fetching tickets', e.toString());
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createTicket(Ticket ticket) async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _error = null;
      final newTicket = await _ticketService.createTicket(ticket);
      _tickets = [..._tickets, newTicket];
    } catch (e) {
      ConsoleLogger.error('Error creating ticket', e.toString());
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTicket(Ticket ticket) async {
    if (_isLoading) return;

    try {
      _setLoading(true);
      _error = null;
      final updatedTicket = await _ticketService.updateTicket(ticket.id, ticket.toJson());
      _tickets = _tickets.map((t) => t.id == updatedTicket.id ? updatedTicket : t).toList();
    } catch (e) {
      ConsoleLogger.error('Error updating ticket', e.toString());
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTicket(String ticketId) async {
    if (_isLoading) return false;

    try {
      _setLoading(true);
      _error = null;
      final success = await _ticketService.deleteTicket(ticketId);
      if (success) {
        _tickets = _tickets.where((t) => t.id != ticketId).toList();
      }
      return success;
    } catch (e) {
      ConsoleLogger.error('Error deleting ticket', e.toString());
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<Ticket> filterTickets({String? status, String? priority}) {
    return _tickets.where((ticket) {
      if (status != null && status != 'all' && ticket.status != status) {
        return false;
      }
      if (priority != null && priority != 'all' && ticket.priority != priority) {
        return false;
      }
      return true;
    }).toList();
  }
}