import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shift.dart';
import '../utils/console_logger.dart';

class ShiftService {
  final String baseUrl;
  final http.Client _client;

  ShiftService({
    this.baseUrl = 'http://localhost:3000/api',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<List<Shift>> getAgentShifts(String agentId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/shifts/$agentId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Shift.fromJson(json)).toList();
      }
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error fetching shifts', e.toString());
      rethrow;
    }
  }

  Future<Shift> createShift(Shift shift) async {
    try {
      final response = await _client.post(
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
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error creating shift', e.toString());
      rethrow;
    }
  }

  Future<Shift> updateShift(String shiftId, Map<String, dynamic> updates) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/shifts/$shiftId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return Shift.fromJson(json.decode(response.body));
      }
      throw _handleError(response);
    } catch (e) {
      ConsoleLogger.error('Error updating shift', e.toString());
      rethrow;
    }
  }

  Future<bool> deleteShift(String shiftId) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl/shifts/$shiftId'),
        headers: {'Accept': 'application/json'},
      );

      return response.statusCode == 204;
    } catch (e) {
      ConsoleLogger.error('Error deleting shift', e.toString());
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