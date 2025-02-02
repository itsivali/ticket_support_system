import 'package:flutter/foundation.dart';
import '../models/agent.dart';
import '../services/agent_service.dart';
import '../utils/console_logger.dart';

class AgentProvider with ChangeNotifier {
  final AgentService _service = AgentService();
  List<Agent> _agents = [];
  bool _isLoading = false;
  String? _error;

  List<Agent> get agents => _agents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAgents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _agents = await _service.getAgents();
    } catch (e) {
      _error = e.toString();
      ConsoleLogger.error('Failed to fetch agents', e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createAgent(Agent agent) async {
    try {
      final newAgent = await _service.createAgent(agent);
      _agents.add(newAgent);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      ConsoleLogger.error('Failed to create agent', e.toString());
      return false;
    }
  }

  Future<bool> updateAgent(String id, Map<String, dynamic> updates) async {
    try {
      final updatedAgent = Agent.fromJson({..._agents.firstWhere((a) => a.id == id).toJson(), ...updates});
      await _service.updateAgent(id, updatedAgent);
      final index = _agents.indexWhere((a) => a.id == id);
      if (index != -1) {
        _agents[index] = Agent.fromJson({..._agents[index].toJson(), ...updates});
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      ConsoleLogger.error('Failed to update agent', e.toString());
      return false;
    }
  }

  Future<bool> deleteAgent(String id) async {
    try {
      final success = await _service.deleteAgent(id);
      if (success) {
        _agents.removeWhere((a) => a.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      ConsoleLogger.error('Failed to delete agent', e.toString());
      return false;
    }
  }

  Future<bool> updateAgentStatus(String id, bool isAvailable) async {
    try {
      final success = await _service.updateAgentStatus(id, isAvailable);
      if (success) {
        final index = _agents.indexWhere((a) => a.id == id);
        if (index != -1) {
          _agents[index] = Agent.fromJson({
            ..._agents[index].toJson(),
            'isAvailable': isAvailable,
          });
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _error = e.toString();
      ConsoleLogger.error('Failed to update agent status', e.toString());
      return false;
    }
  }

  Agent? getAgentById(String id) {
    return _agents.firstWhere((a) => a.id == id);
  }

  List<Agent> getAvailableAgents() {
    return _agents.where((a) => a.isAvailable && a.isOnline).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}