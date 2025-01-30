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
    return Agent(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'SUPPORT',
      isAvailable: json['isAvailable'] ?? true,
      isOnline: json['isOnline'] ?? false,
      currentTickets: List<String>.from(json['currentTickets'] ?? []),
      shiftSchedule: json['shiftSchedule'] != null 
          ? ShiftSchedule.fromJson(json['shiftSchedule'])
          : null,
    );
  }
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
    return ShiftSchedule(
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      weekdays: List<int>.from(json['weekdays']),
    );
  }
}