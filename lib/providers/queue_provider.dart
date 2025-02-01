import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/queue_manager.dart';
import '../models/ticket.dart';
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
    } catch (e) {
      _error = e.toString();
      ConsoleLogger.error('Error fetching queue status', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> assignTicket(String ticketId, String? agentId) async {
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

  Future<void> updateSettings(QueueSettings settings) async {
    try {
      await _queueService.updateSettings(settings);
      await fetchQueueStatus();
    } catch (e) {
      ConsoleLogger.error('Error updating queue settings', e);
    }
  }

  void _startAutoAssignment() {
    _autoAssignmentTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _checkQueueAssignments(),
    );
  }

  Future<void> _checkQueueAssignments() async {
    if (_queueManager?.settings.autoAssignEnabled != true) return;
    await fetchQueueStatus();
  if (_queueManager == null) return;

  final unassignedTickets = _queueManager!.tickets
    .where((ticket) => ticket.status == TicketStatus.unassigned)
    .toList();

  final availableAgents = _queueManager!.agents
    .where((agent) => agent.isAvailable && agent.isOnline)
    .toList();

  if (unassignedTickets.isEmpty || availableAgents.isEmpty) return;

  for (final ticket in unassignedTickets) {
    final agent = _findLeastLoadedAgent(availableAgents);
    if (agent != null) {
    await assignTicket(ticket.id, agent.id);
    }
  }
  }

  Agent? _findLeastLoadedAgent(List<Agent> agents) {
    if (agents.isEmpty) return null;
    
    return agents.reduce((a, b) {
      final aCount = _queueManager?.agentAssignments[a.id]?.length ?? 0;
      final bCount = _queueManager?.agentAssignments[b.id]?.length ?? 0;
      return aCount <= bCount ? a : b;
    });
  }
}