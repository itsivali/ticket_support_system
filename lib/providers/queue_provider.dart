import 'dart:async';
import 'package:flutter/material.dart';
import '../models/queue_manager.dart';
import '../services/queue_service.dart';
import '../utils/console_logger.dart';

class QueueProvider extends ChangeNotifier {
  QueueManager? _queueManager;
  Timer? _autoAssignmentTimer;
  final QueueService _queueService = QueueService();

  final bool _isLoading = false;

  bool get isLoading => _isLoading;

  QueueManager? get queueManager => _queueManager;

  bool get autoAssign => _queueManager?.settings.autoAssignEnabled ?? false;

  bool _isAutoAssignEnabled = false;

  bool get isAutoAssignEnabled => _isAutoAssignEnabled;

  List<Ticket> tickets = [];

  Future<void> fetchQueueStatus() async {
    try {
      _queueManager = await _queueService.getQueueManager();
      notifyListeners();
    } catch (e) {
      ConsoleLogger.error('Failed to fetch queue status', e.toString());
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
      ConsoleLogger.error('Error in auto assignment', e.toString());
    }
  }

  Future<void> updateAutoAssign(bool isEnabled) async {
    if (_queueManager == null) return;

    _queueManager!.settings = _queueManager!.settings.copyWith(autoAssignEnabled: isEnabled);
    notifyListeners();

    if (isEnabled) {
      _startAutoAssignment();
    } else {
      _autoAssignmentTimer?.cancel();
    }
  }

  Future<void> assignTicket(String ticketId, String agentId) async {
    try {
      await _queueService.assignTicket(ticketId, agentId);
      await fetchQueueStatus();
    } catch (e) {
      ConsoleLogger.error('Failed to assign ticket', e.toString());
    }
  }

  Future<void> toggleAutoAssign(bool value) async {
    _isAutoAssignEnabled = value;
    notifyListeners();
  }

  Future<bool> claimTicket(String ticketId, String agentId) async {
    try {
      await _queueService.claimTicket(ticketId, agentId);
      await fetchQueueStatus();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> refreshQueue() async {
    try {
      tickets = await _queueService.getTickets();
    } catch (e) {
      ConsoleLogger.error('Failed to refresh queue', e.toString());
      tickets = [];
    }

    // Example:

    // tickets = await yourApiService.getTickets();

    notifyListeners();
  }
}