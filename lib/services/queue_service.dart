import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/queue_manager.dart';
import '../utils/console_logger.dart';

class QueueService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<QueueManager> getQueueStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/queue/status'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return QueueManager.fromJson(json.decode(response.body));
      }
      
      throw Exception('Failed to get queue status: ${response.statusCode}');
    } catch (e) {
      ConsoleLogger.error('Error getting queue status', e);
      rethrow;
    }
  }

  Future<bool> assignTicket(String ticketId, String? agentId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tickets/$ticketId/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'assignedTo': agentId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      ConsoleLogger.error('Error assigning ticket', e);
      return false;
    }
  }

  Future<bool> claimTicket(String ticketId, String agentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$ticketId/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'agentId': agentId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      ConsoleLogger.error('Error claiming ticket', e);
      return false;
    }
  }

  Future<void> updateSettings(QueueSettings settings) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/queue/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(settings.toJson()),
      );
    } catch (e) {
      ConsoleLogger.error('Error updating queue settings', e);
      rethrow;
    }
  }
}