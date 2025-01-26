class TicketService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<Ticket>> getTickets() async {
    final response = await http.get(Uri.parse('$baseUrl/tickets'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ticket.fromJson(json)).toList();
    }
    throw Exception('Failed to load tickets');
  }

  Future<Ticket> createTicket(Ticket ticket) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tickets'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(ticket.toJson()),
    );
    if (response.statusCode == 201) {
      return Ticket.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create ticket');
  }
}