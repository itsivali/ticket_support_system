import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../models/agent.dart';
import '../services/ticket_service.dart';
import '../utils/console_logger.dart';
import '../utils/ui_helpers.dart';

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

  Future<void> deleteTicket(String ticketId, BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _ticketService.deleteTicket(ticketId);
      _tickets.removeWhere((ticket) => ticket.id == ticketId);
      
      if (context.mounted) {
        // Show success dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700]),
                const SizedBox(width: 10),
                const Text('Success'),
              ],
            ),
            content: const Text('Ticket has been successfully deleted.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        
        // Show snackbar for additional feedback
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Ticket deleted successfully',
          icon: Icons.delete_forever,
          backgroundColor: Colors.green,
        );
      }
    } catch (e, stack) {
      ConsoleLogger.error('Error deleting ticket: $e\n$stack');
      _error = 'Failed to delete ticket: ${e.toString()}';
      if (context.mounted) {
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Failed to delete ticket: ${e.toString()}',
          icon: Icons.error_outline,
          backgroundColor: Colors.red,
        );
      }
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

  Future<void> createTicket(Ticket ticket, BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final newTicket = await _ticketService.createTicket(ticket);
      _tickets.add(newTicket);
      
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Ticket created successfully!',
        icon: Icons.check_circle,
        backgroundColor: Colors.green,
      );
      
    } catch (e) {
      ConsoleLogger.error('Error creating ticket', e);
      _error = e.toString();
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Failed to create ticket: ${e.toString()}',
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateTicket(Ticket ticket, BuildContext context) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Validate ticket fields before sending
      if (ticket.title.length < 3) {
        throw Exception('Title must be at least 3 characters');
      }
      if (ticket.description.length < 10) {
        throw Exception('Description must be at least 10 characters');
      }

      final updated = await _ticketService.updateTicket(ticket);
      final index = _tickets.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _tickets[index] = updated;
        UIHelpers.showCustomSnackBar(
          context: context,
          message: 'Ticket updated successfully!',
          icon: Icons.check_circle,
          backgroundColor: Colors.blue,
        );
      }
    } catch (e) {
      ConsoleLogger.error('Error updating ticket', e);
      _error = e.toString();
      UIHelpers.showCustomSnackBar(
        context: context,
        message: 'Failed to update ticket: ${e.toString()}',
        icon: Icons.error_outline,
        backgroundColor: Colors.red,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}