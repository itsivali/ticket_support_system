import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/agent.dart';

class TicketService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<Ticket>> getTickets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      throw HttpException('Network error: $e');
    }
  }

  Future<List<Agent>> getAgents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/agents'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => Agent.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException('Failed to load agents: ${response.statusCode}');
      }
    } catch (e) {
      throw HttpException('Network error: $e');
    }
  }

  Future<Ticket> createTicket(Ticket ticket) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
        body:import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/agent.dart';

class TicketService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<Ticket>> getTickets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      throw HttpException('Network error: $e');
    }
  }

  Future<List<Agent>> getAgents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/agents'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => Agent.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException('Failed to load agents: ${response.statusCode}');
      }
    } catch (e) {
      throw HttpException('Network error: $e');
    }
  }

  Future<Ticket> createTicket(Ticket ticket) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
                body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Ticket.fromJson(jsonData);
      } else {
        throw HttpException('Failed to create ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw HttpException('Network error: $e');
    }
  }

  Future<void> assignTicket(String ticketId, String agentId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tickets/$ticketId/assign'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'assignedTo': agentId}),
      );

      if (response.statusCode != 200) {
        throw HttpException('Failed to assign ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw HttpException('Network error: $e');
    }
  }
}