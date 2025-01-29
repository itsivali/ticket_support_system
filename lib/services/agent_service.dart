import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent.dart';
import '../utils/console_logger.dart';

class AgentService {
  final String baseUrl = 'http://localhost:3000/api/agents';

  Future<List<Agent>> getAgents() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
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
      // Log request details
      ConsoleLogger.info(
        'Creating agent - Endpoint: $baseUrl\nPayload: ${json.encode({
          'name': agent.name,
          'email': agent.email,
          'role': agent.role,
          'isAvailable': agent.isAvailable,
        })}'
      );

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': agent.name,
          'email': agent.email,
          'role': agent.role,
          'isAvailable': agent.isAvailable,
        }),
      );

      // Log response details
      ConsoleLogger.info(
        'Server response - Status: ${response.statusCode}\nBody: ${response.body}'
      );

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
      final response = await http.put(
        Uri.parse('$baseUrl/${agent.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': agent.name,
          'email': agent.email,
          'role': agent.role,
          'isAvailable': agent.isAvailable,
        }),
      );

      if (response.statusCode == 200) {
        return Agent.fromJson(json.decode(response.body));
      }
      
      ConsoleLogger.error(
        'Failed to update agent: ${response.statusCode}',
        'Response body: ${response.body}'
      );
      throw Exception('Failed to update agent: ${response.statusCode}');
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteAgent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        ConsoleLogger.error(
          'Failed to delete agent: ${response.statusCode}',
          'Response body: ${response.body}'
        );
        throw Exception('Failed to delete agent: ${response.statusCode}');
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }
}