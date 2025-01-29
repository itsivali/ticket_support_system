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
        return jsonData
            .map((json) => Agent.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        ConsoleLogger.error(
          'Failed to load agents: ${response.statusCode}',
          'Response body: ${response.body}'
        );
        throw Exception('Failed to load agents: ${response.statusCode}');
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }

  Future<Agent> createAgent(Agent agent) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agents'),
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

      if (response.statusCode == 201) {
        return Agent.fromJson(json.decode(response.body));
      } else {
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Failed to create agent';
        throw Exception(message);
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }

  Future<Agent> updateAgent(Agent agent) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/agents/${agent.id}'),
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
      } else {
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Failed to update agent';
        throw Exception(message);
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteAgent(String agentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/agents/$agentId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final responseBody = response.body.isNotEmpty ? response.body : 'No response body';
        ConsoleLogger.error(
          'Failed to delete agent: ${response.statusCode}',
          'Response body: $responseBody',
        );
        throw Exception('Failed to delete agent: ${response.statusCode}');
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }
}