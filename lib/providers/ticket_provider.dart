import 'package:flutter/foundation.dart';
import '../models/ticket.dart';
import '../services/ticket_service.dart';

class TicketProvider with ChangeNotifier {
  final TicketService _ticketService = TicketService();
  List<Ticket> _tickets = [];
  bool _isLoading = false;
  String? _error;

  List<Ticket> get tickets => _tickets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTickets() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _tickets = await _ticketService.getTickets();
    } catch (e) {
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
    } catch (e) {
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

      // Add implementation for ticket assignment
      // await _ticketService.assignTicket(ticketId, agentId);
      
      // Update local ticket data
      await fetchTickets();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}