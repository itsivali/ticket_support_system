import 'dart:async';
import 'package:flutter/material.dart';
import '../models/queue_manager.dart' as queue_manager;
import '../services/queue_service.dart';
import '../models/ticket.dart' as ticket_model;
import '../utils/console_logger.dart';
import '../models/queue_manager.dart' show AssignmentRule;

class QueueProvider with ChangeNotifier {
  queue_manager.QueueManager? _queueManager;
  Timer? _autoAssignmentTimer;
  final QueueService _queueService = QueueService();

  final bool _isLoading = false;

  bool get isLoading => _isLoading;

  queue_manager.QueueManager? get queueManager => _queueManager;

  bool get autoAssign => _queueManager?.settings.autoAssignEnabled ?? false;

  set queueManager(queue_manager.QueueManager? value) {
    _queueManager = value;
    notifyListeners();
  }

  bool _isAutoAssignEnabled = false;

  bool get isAutoAssignEnabled => _isAutoAssignEnabled;

  List<ticket_model.Ticket> tickets = [];

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

       notifyListeners();
  }

  Future<void> addRule(AssignmentRule rule) async {
    if (queueManager == null) return;

    final settings = queueManager!.settings;
    final newSettings = settings.copyWith(
      rules: [...settings.rules, rule],
    );
    queueManager = queueManager!.copyWith(settings: newSettings);
    notifyListeners();
  }

  Future<void> updateRule(AssignmentRule updatedRule) async {
    if (queueManager == null) return;

    final settings = queueManager!.settings;
    final rules = [...settings.rules];
    final index = rules.indexWhere((r) => r.id == updatedRule.id);
    
    if (index != -1) {
      rules[index] = updatedRule;
      final newSettings = settings.copyWith(rules: rules);
      queueManager = queueManager!.copyWith(settings: newSettings);
      notifyListeners();
    }
  }

  Future<void> deleteRule(String ruleId) async {
    if (queueManager == null) return;

    final settings = queueManager!.settings;
    final rules = settings.rules.where((r) => r.id != ruleId).toList();
    final newSettings = settings.copyWith(rules: rules);
    queueManager = queueManager!.copyWith(settings: newSettings);
    notifyListeners();
  }
}