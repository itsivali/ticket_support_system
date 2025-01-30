class Agent {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isAvailable;
  final bool isOnline;
  final List<String> currentTickets;
  final ShiftSchedule? shiftSchedule;

  static const List<String> validRoles = ['SUPPORT', 'SUPERVISOR', 'ADMIN'];

  Agent({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isAvailable = true,
    this.isOnline = false,
    this.currentTickets = const [],
    this.shiftSchedule,
  }) {
    if (!validRoles.contains(role)) {
      throw ArgumentError('Invalid role: $role');
    }
  }

  factory Agent.fromJson(Map<String, dynamic> json) {
    try {
      // Handle potential null values with null-aware operators
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
      return ShiftSchedule(
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        weekdays: List<int>.from(json['weekdays'] as List),
      );
    } catch (e) {
      throw FormatException('Error parsing ShiftSchedule from JSON: $e\nJSON: $json');
    }
  }

  Map<String, dynamic> toJson() => {
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'weekdays': weekdays,
  };
}