import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/queue_manager.dart';
import '../utils/console_logger.dart';

class QueueService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<QueueManager> getQueueStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/queue'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return QueueManager.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to fetch queue status');
    } catch (e) {
      ConsoleLogger.error('Error fetching queue status', e);
      rethrow;
    }
  }

  Future<bool> assignTicket(String ticketId, String? agentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/queue/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'ticketId': ticketId,
          'agentId': agentId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      ConsoleLogger.error('Error assigning ticket', e);
      rethrow;
    }
  }

  Future<bool> claimTicket(String ticketId, String agentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/queue/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'ticketId': ticketId,
          'agentId': agentId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      ConsoleLogger.error('Error claiming ticket', e);
      rethrow;
    }
  }

  Future<QueueSettings> updateSettings(QueueSettings settings) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/queue/settings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(settings.toJson()),
      );

      if (response.statusCode == 200) {
        return QueueSettings.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to update queue settings');
    } catch (e) {
      ConsoleLogger.error('Error updating queue settings', e);
      rethrow;
    }
  }
}