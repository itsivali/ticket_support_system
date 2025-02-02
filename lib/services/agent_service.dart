import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent.dart';
import '../utils/console_logger.dart';

class AgentService {
  final String baseUrl = 'http://localhost:3000/api';
  final http.Client _client = http.Client();

  Future<List<Agent>> getAgents() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/agents'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Agent.fromJson(json)).toList();
      }
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Failed to get agents', e.toString());
      rethrow;
    }
  }

  Future<Agent> createAgent(Agent agent) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/agents'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(agent.toJson()),
      );

      if (response.statusCode == 201) {
        return Agent.fromJson(json.decode(response.body));
      }
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Failed to get agents', e.toString());
      rethrow;
    }
  }

  Future<Agent> updateAgent(String id, Agent agent) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/agents/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(agent.toJson()),
      );

      if (response.statusCode == 200) {
        return Agent.fromJson(json.decode(response.body));
      }
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Failed to get agents', e.toString());
      rethrow;
    }
  }

  Future<bool> deleteAgent(String id) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/agents/$id'),
        headers: {'Accept': 'application/json'},
      );

      return response.statusCode == 204;
    } catch (e) {
      ConsoleLogger.error('Failed to get agents', e.toString());
      rethrow;
    }
  }

  Future<bool> updateAgentStatus(String id, bool isAvailable) async {
    try {
      final response = await _client.patch(
        Uri.parse('$baseUrl/agents/$id/status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'isAvailable': isAvailable}),
      );

      return response.statusCode == 200;
    } catch (e) {
      ConsoleLogger.error('Failed to get agents', e.toString());
      rethrow;
    }
  }

  Future<Agent> getAgent(String agentId) async {
    // TODO: Implement agent retrieval logic
    throw UnimplementedError('getAgent method needs to be implemented');
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