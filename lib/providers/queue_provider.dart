import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/queue_manager.dart';
import '../models/ticket.dart';
import '../models/agent.dart';
import '../services/queue_service.dart';
import '../utils/console_logger.dart';

class QueueProvider with ChangeNotifier {
  final QueueService _queueService = QueueService();
  QueueManager? _queueManager;
  bool _isLoading = false;
  String? _error;
  Timer? _autoAssignmentTimer;

  QueueManager? get queueManager => _queueManager;
  bool get isLoading => _isLoading;
  String? get error => _error;

  QueueProvider() {
    _startAutoAssignment();
  }

  @override
  void dispose() {
    _autoAssignmentTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchQueueStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _queueManager = await _queueService.getQueueStatus();
      _error = null;
    } catch (e) {
      _error = e.toString();
      ConsoleLogger.error('Error fetching queue status', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _startAutoAssignment() {
    _autoAssignmentTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _processAutoAssignment(),
    );
  }

  Future<void> _processAutoAssignment() async {
    if (_queueManager == null || !_queueManager!.settings.autoAssignEnabled) {
      return;
    }

    try {
      final agents = await _queueService.getAvailableAgents();
      final ticket = _queueManager!.getNextTicket();

      if (ticket != null) {
        final potentialAgents = _queueManager!.getPotentialAgents(
          ticket.ticket,
          agents,
        );

        if (potentialAgents.isNotEmpty) {
          final agent = potentialAgents.first;
          await assignTicket(ticket.ticket.id, agent.id);
        }
      }
    } catch (e) {
      ConsoleLogger.error('Error in auto assignment', e);
    }
  }

  Future<bool> assignTicket(String ticketId, String agentId) async {
    try {
      final success = await _queueService.assignTicket(ticketId, agentId);
      if (success) {
        await fetchQueueStatus();
      }
      return success;
    } catch (e) {
      ConsoleLogger.error('Error assigning ticket', e);
      return false;
    }
  }

  Future<bool> claimTicket(String ticketId, String agentId) async {
    try {
      final success = await _queueService.claimTicket(ticketId, agentId);
      if (success) {
        await fetchQueueStatus();
      }
      return success;
    } catch (e) {
      ConsoleLogger.error('Error claiming ticket', e);
      return false;
    }
  }

  Map<String, int> getQueueMetrics() {
    return _queueManager?.getQueueStats() ?? {
      'total': 0,
      'high': 0,
      'medium': 0,
      'low': 0,
      'urgent': 0,
    };
  }
}