import '../utils/console_logger.dart';
import './ticket.dart';

class Agent {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isAvailable;
  final bool isOnline;
  final List<String> currentTickets;
  final ShiftSchedule? shiftSchedule;
  final DateTime? lastAssignment;

  static const List<String> validRoles = ['SUPPORT', 'SUPERVISOR', 'ADMIN'];

  Agent({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.currentTickets,
    required this.isAvailable,
    required this.isOnline,
    this.shiftSchedule,
    this.lastAssignment,
  }) {
    if (!validRoles.contains(role)) {
      throw ArgumentError('Invalid role: $role');
    }
  }

  factory Agent.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? '';
      final name = json['name']?.toString() ?? '';
      final email = json['email']?.toString() ?? '';
      final role = json['role']?.toString() ?? 'SUPPORT';

      return Agent(
        id: id,
        name: name,
        email: email,
        role: role,
        isAvailable: json['isAvailable'] ?? true,
        isOnline: json['isOnline'] ?? false,
        currentTickets: json['currentTickets'] != null 
            ? List<String>.from(json['currentTickets'].map((id) => id.toString()))
            : [],
        shiftSchedule: json['shiftSchedule'] != null 
            ? ShiftSchedule.fromJson(json['shiftSchedule'] as Map<String, dynamic>)
            : null,
      );
    } catch (e) {
      throw FormatException('Error parsing Agent from JSON: $e\nJSON: $json');
    }
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'role': role,
    'isAvailable': isAvailable,
    if (currentTickets.isNotEmpty) 'currentTickets': currentTickets,
    if (shiftSchedule != null) 'shiftSchedule': shiftSchedule!.toJson(),
  };
}

class ShiftSchedule {
  final DateTime startTime;
  final DateTime endTime;
  final List<int> weekdays;

  ShiftSchedule({
    required this.startTime,
    required this.endTime,
    required this.weekdays,
  });

  factory ShiftSchedule.fromJson(Map<String, dynamic> json) {
    try {
      // Set default times if not provided
      final now = DateTime.now();
      final startTime = json['startTime'] != null 
          ? DateTime.parse(json['startTime'].toString())
          : now;
      final endTime = json['endTime'] != null 
          ? DateTime.parse(json['endTime'].toString())
          : now.add(const Duration(hours: 8));
      
      return ShiftSchedule(
        startTime: startTime,
        endTime: endTime,
        weekdays: json['weekdays'] != null 
            ? List<int>.from(json['weekdays'])
            : [],
      );
    } catch (e) {
      ConsoleLogger.error(
        'Error parsing ShiftSchedule',
        'JSON: $json\nError: $e'
      );
      // Return a default schedule instead of throwing
      final now = DateTime.now();
      return ShiftSchedule(
        startTime: now,
        endTime: now.add(const Duration(hours: 8)),
        weekdays: [],
      );
    }
  }

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'weekdays': weekdays,
  };

  bool canHandleTicket(Ticket ticket) {
    // Add your shift schedule validation logic here
    // For example, check if the ticket's creation time falls within the agent's shift hours
    return true;
  }

  bool isWorkingAt(String dateTime) {
    final date = DateTime.parse(dateTime);
    // Implement your shift schedule logic here
    return true; // Default implementation
  }
}