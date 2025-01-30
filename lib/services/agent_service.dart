import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent.dart';
import '../utils/console_logger.dart';

class AgentService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<Agent>> getAgents() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/agents'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Agent.fromJson(json)).toList();
      }
      
      ConsoleLogger.error(
        'Failed to load agents: ${response.statusCode}',
        'Response body: ${response.body}'
      );
      throw Exception('Failed to load agents: ${response.statusCode}');
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }

  Future<Agent> createAgent(Agent agent) async {
    try {
      final payload = {
        'name': agent.name,
        'email': agent.email,
        'role': agent.role,
        'isAvailable': agent.isAvailable,
      };
      
      ConsoleLogger.info('Creating agent', 'Endpoint: $baseUrl/agents\nPayload: ${json.encode(payload)}');

      final response = await http.post(
        Uri.parse('$baseUrl/agents'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      ConsoleLogger.info('Server response', 'Status: ${response.statusCode}\nBody: ${response.body}');

      if (response.statusCode == 201) {
        return Agent.fromJson(json.decode(response.body));
      }
      
      throw Exception('Server error: ${response.statusCode}\n${response.body}');
    } catch (e, stack) {
      ConsoleLogger.error('Failed to create agent', e, stack);
      rethrow;
    }
  }

  Future<Agent> updateAgent(Agent agent) async {
    try {
      final payload = {
        'name': agent.name,
        'email': agent.email,
        'role': agent.role,
        'isAvailable': agent.isAvailable,
      };
      
      ConsoleLogger.info('Updating agent', 'Payload: ${json.encode(payload)}');

      final response = await http.put(
        Uri.parse('$baseUrl/agents/${agent.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(payload),
      );

      ConsoleLogger.info(
        'Server response',
        'Status: ${response.statusCode}\nBody: ${response.body}'
      );

      if (response.statusCode == 200) {
        return Agent.fromJson(json.decode(response.body));
      }
      
      final errorData = json.decode(response.body);
      final message = errorData['message'] ?? 'Failed to update agent';
      throw Exception(message);
    } catch (e, stack) {
      ConsoleLogger.error('Failed to update agent', e, stack);
      rethrow;
    }
  }

  Future<void> deleteAgent(String id) async {
    try {
      ConsoleLogger.info('Deleting agent', 'Agent ID: $id');

      final response = await http.delete(
        Uri.parse('$baseUrl/agents/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      ConsoleLogger.info(
        'Server response',
        'Status: ${response.statusCode}\nBody: ${response.body}'
      );

      if (response.statusCode != 204) {
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Failed to delete agent';
        throw Exception(message);
      }
    } catch (e, stack) {
      ConsoleLogger.error('Failed to delete agent', e, stack);
      rethrow;
    }
  }
}