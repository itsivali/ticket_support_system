import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../models/agent.dart';
import '../utils/console_logger.dart';

class TicketService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<Ticket>> getTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        ConsoleLogger.info('Successfully fetched ${jsonData.length} tickets');
        return jsonData
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        ConsoleLogger.error(
          'Failed to load tickets: ${response.statusCode}',
          'Response body: ${response.body}'
        );
        throw Exception('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }

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

  Future<Ticket> createTicket(Ticket ticket) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Ticket.fromJson(jsonData);
      } else {
        ConsoleLogger.error(
          'Failed to create ticket: ${response.statusCode}',
          'Response body: ${response.body}'
        );
        throw Exception('Failed to create ticket: ${response.statusCode}');
      }
        } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }

  Future<Ticket> updateTicket(Ticket ticket) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tickets/${ticket.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Ticket.fromJson(jsonData);
      } else {
        ConsoleLogger.error(
          'Failed to update ticket: ${response.statusCode}',
          'Response body: ${response.body}'
        );
        throw Exception('Failed to update ticket: ${response.statusCode}');
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteTicket(String ticketId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tickets/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        ConsoleLogger.error(
          'Failed to delete ticket: ${response.statusCode}',
          'Response body: ${response.body}'
        );
        throw Exception('Failed to delete ticket: ${response.statusCode}');
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }

  Future<void> assignTicket(String ticketId, String agentId) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/tickets/$ticketId/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'assignedTo': agentId}),
      );

      if (response.statusCode != 200) {
        ConsoleLogger.error(
          'Failed to assign ticket: ${response.statusCode}',
          'Response body: ${response.body}'
        );
        throw Exception('Failed to assign ticket: ${response.statusCode}');
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      throw Exception('Network error: $e');
    }
  }
}