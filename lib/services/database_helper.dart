import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/agent.dart';
import '../models/ticket.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  DatabaseHelper._init();

  static const String baseUrl = 'http://localhost:3000';

  // Agent CRUD Methods
  Future<String> createAgent(Agent agent) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agents'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(agent.toMap()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['id'];
      } else {
        throw Exception('Failed to create agent: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create agent: $e');
    }
  }

  Future<List<Agent>> getAgents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/agents'));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((map) => Agent.fromMap(map)).toList();
      } else {
        throw Exception('Failed to load agents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load agents: $e');
    }
  }

  // Ticket CRUD Methods
  Future<String> createTicket(Ticket ticket) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(ticket.toMap()),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body)['id'];
      } else {
        throw Exception('Failed to create ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create ticket: $e');
    }
  }

  Future<List<Ticket>> getTickets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets'));
      if (response.statusCode == 200) {
        final List list = jsonDecode(response.body);
        return list.map((map) => Ticket.fromMap(map)).toList();
      } else {
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load tickets: $e');
    }
  }

  Future<void> updateTicket(String id, Map<String, dynamic> update) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(update),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update ticket: $e');
    }
  }

  Future<void> deleteTicket(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tickets/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete ticket: $e');
    }
  }
}