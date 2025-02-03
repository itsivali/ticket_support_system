import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/queue_manager.dart' as qm;
import '../models/agent.dart';
import '../models/ticket.dart';
import '../utils/console_logger.dart';

class QueueService {
  final String baseUrl;
  final http.Client _client;
  static const int maxRetries = 3;

  QueueService({
    this.baseUrl = 'http://localhost:3000/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<qm.QueueManager> getQueueStatus() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/queue/status'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
      return qm.QueueManager.fromJson(json.decode(response.body));
      }
      
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error getting queue status', e.toString());
      rethrow;
    }
  }

  Future<bool> assignTicket(String ticketId, String? agentId) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/tickets/$ticketId/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'agentId': agentId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      ConsoleLogger.error('Error assigning ticket', e.toString());
      return false;
    }
  }

  Future<bool> claimTicket(String ticketId, String agentId) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/tickets/$ticketId/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'agentId': agentId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      ConsoleLogger.error('Error claiming ticket', e.toString());
      return false;
    }
  }

  Future<Map<String, int>> getQueueMetrics() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/queue/metrics'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Map<String, int>.from(json.decode(response.body));
      }
      
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error getting queue metrics', e.toString());
      return {};
    }
  }

  Future<List<Agent>> getAvailableAgents() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/agents/available'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((agent) => Agent.fromJson(agent))
            .toList();
      }

      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error getting available agents', e.toString());
      return [];
    }
  }

  Future<qm.QueueManager> getQueueManager() async {
    try {
      final response = await _client.get(
      Uri.parse('$baseUrl/queue/manager'),
      headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
      return qm.QueueManager.fromJson(json.decode(response.body));
      }

      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error fetching queue manager', e.toString());
      throw Exception('Failed to fetch queue manager: ${e.toString()}');
    }
  }

  Future<List<Ticket>> getTickets() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return (json.decode(response.body) as List)
            .map((ticket) => Ticket.fromJson(ticket))
            .toList();
      }

      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error fetching tickets', e.toString());
      return [];
    }
  }

  Exception _handleError(http.Response response) {
    try {
      final error = json.decode(response.body)['error'];
      return Exception(error ?? 'Unknown error');
    } catch (_) {
      return Exception('Request failed: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}