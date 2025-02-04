import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';
import '../utils/console_logger.dart';

class TicketService {
  final String baseUrl;
  final http.Client _client;
  static const int maxRetries = 3;
  
  TicketService({
    this.baseUrl = 'http://localhost:3000/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<Ticket> getTicket(String ticketId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/tickets/$ticketId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Ticket.fromJson(json.decode(response.body));
      }
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error fetching ticket', e.toString());
      rethrow;
    }
  }

  Future<List<Ticket>> getTickets() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData
            .map((json) => Ticket.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error fetching tickets', e.toString());
      return [];
    }
  }

  Future<Ticket> createTicket(Ticket ticket) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 201) {
        return Ticket.fromJson(json.decode(response.body));
      }
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error creating ticket', e.toString());
      rethrow;
    }
  }

  Future<Ticket> updateTicket(String ticketId, Map<String, dynamic> updates) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/tickets/$ticketId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return Ticket.fromJson(json.decode(response.body));
      }
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error updating ticket', e.toString());
      rethrow;
    }
  }

  Future<bool> deleteTicket(String ticketId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/tickets/$ticketId'),
        headers: {'Accept': 'application/json'},
      );

      return response.statusCode == 204;
    } catch (e) {
      ConsoleLogger.error('Error deleting ticket', e.toString());
      return false;
    }
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