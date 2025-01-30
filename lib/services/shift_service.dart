class ShiftService {
  final String baseUrl = 'http://localhost:3000/api';

  Future<List<Shift>> getAgentShifts(String agentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/shifts/$agentId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Shift.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch shifts');
    } catch (e) {
      ConsoleLogger.error('Error fetching shifts', e);
      rethrow;
    }
  }

  Future<Shift> createShift(Shift shift) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/shifts'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(shift.toJson()),
      );

      if (response.statusCode == 201) {
        return Shift.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to create shift');
    } catch (e) {
      ConsoleLogger.error('Error creating shift', e);
      rethrow;
    }
  }
}