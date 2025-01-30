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
        final List<dynamic> jsonData =
            json.decode(response.body) as List<dynamic>;
        ConsoleLogger.info('Successfully fetched ${jsonData.length} tickets');

        return jsonData.map((json) {
          try {
            if (json is! Map<String, dynamic>) {
              throw const FormatException('Invalid ticket format');
            }
            return Ticket.fromJson(json);
          } catch (e) {
            ConsoleLogger.error('Error parsing ticket', e);
            rethrow;
          }
        }).toList();
      } else {
        ConsoleLogger.error('Failed to load tickets: ${response.statusCode}',
            'Response body: ${response.body}');
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
        ConsoleLogger.error('Failed to load agents: ${response.statusCode}',
            'Response body: ${response.body}');
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
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Failed to create ticket';
        ConsoleLogger.error(
          'Failed to create ticket: ${response.statusCode}',
          response.body,
        );
        throw Exception(message);
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      throw Exception('Unable to create ticket: ${e.toString()}');
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
        final errorData = json.decode(response.body);
        final message = errorData['message'] ?? 'Failed to update ticket';
        ConsoleLogger.error(
          'Failed to update ticket: ${response.statusCode}',
          'Response body: ${response.body}',
        );
        throw Exception(message);
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error', e, stack);
      if (e is FormatException) {
        throw Exception('Invalid response format');
      }
      throw Exception('Unable to update ticket: ${e.toString()}');
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

      if (response.statusCode == 200 || response.statusCode == 204) {
        ConsoleLogger.info('Ticket $ticketId successfully deleted');
      } else {
        final responseBody =
            response.body.isNotEmpty ? response.body : 'No response body';
        ConsoleLogger.error(
          'Failed to delete ticket: ${response.statusCode}',
          'Response body: $responseBody',
        );
        throw Exception('Failed to delete ticket: ${response.statusCode}');
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error while deleting ticket', e, stack);
      throw Exception('Network error: $e');
    }
  }

  Future<void> assignTicket(String ticketId, String? agentId) async {
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
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to assign ticket');
      }
    } catch (e) {
      ConsoleLogger.error('Failed to assign ticket', e);
      rethrow;
    }
  }

  Future<void> claimTicket(String ticketId, String agentId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$ticketId/claim'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'agentId': agentId}),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to claim ticket');
      }
    } catch (e) {
      ConsoleLogger.error('Failed to claim ticket', e);
      rethrow;
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

      if (response.statusCode == 200 || response.statusCode == 204) {
        ConsoleLogger.info('Agent $agentId successfully deleted');
      } else {
        final responseBody =
            response.body.isNotEmpty ? response.body : 'No response body';
        ConsoleLogger.error(
          'Failed to delete agent: ${response.statusCode}',
          'Response body: $responseBody',
        );
        throw Exception('Failed to delete agent: ${response.statusCode}');
      }
    } catch (e, stack) {
      ConsoleLogger.error('Network error while deleting agent', e, stack);
      throw Exception('Network error: $e');
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
