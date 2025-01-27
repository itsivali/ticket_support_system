import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket.dart';

class TicketService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<Ticket>> getTickets() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tickets'));

      if (response.statusCode == 200) {
        // Properly decode the JSON response
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

  Future<Ticket> createTicket(Ticket ticket) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(ticket.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Ticket.fromJson(data);
      } else {
        throw HttpException('Failed to create ticket: ${response.statusCode}');
      }
    } catch (e) {
      throw HttpException('Network error: $e');
    }
  }

}

class HttpException implements Exception {
  final String message;
  HttpException(this.message);

  @override
  String toString() => message;
}
