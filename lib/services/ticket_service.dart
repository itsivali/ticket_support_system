import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';

class TicketService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<Ticket>> getTickets() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Ticket.fromJson(json)).toList();
      } else {
        throw HttpException('Failed to load tickets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Ticket> createTicket(Ticket ticket) async {
    if (!_validateTicket(ticket)) {
      throw HttpException('Invalid ticket data');
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_ticketToJson(ticket)),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Ticket.fromJson(data);
      } else {
        throw HttpException('Failed to create ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Map<String, dynamic> _ticketToJson(Ticket ticket) {
    return {
      'title': ticket.title,
      'description': ticket.description,
      'dueDate': ticket.dueDate.toIso8601String(),
      'estimatedHours': ticket.estimatedHours,
      'status': ticket.status,
      'assignedTo': ticket.assignedTo,
      'priority': ticket.priority,
    };
  }

  bool _validateTicket(Ticket ticket) {
    return ticket.title.isNotEmpty && 
           ticket.description.isNotEmpty && 
           ticket.estimatedHours > 0 &&
           ticket.dueDate.isAfter(DateTime.now());
  }
}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);
  
  @override
  String toString() => message;
}