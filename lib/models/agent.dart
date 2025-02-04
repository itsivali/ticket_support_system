import './ticket.dart';
import './shift_schedule.dart';

class Agent {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isAvailable;
  final bool isOnline;
  final List<Ticket> currentTickets;
  final List<String> skills;
  final ShiftSchedule shiftSchedule;
  final DateTime lastAssignment;

  static const List<String> validRoles = ['SUPPORT', 'SUPERVISOR', 'ADMIN'];

  const Agent({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isAvailable = true,
    this.isOnline = true,
    this.skills = const [],
    this.currentTickets = const [],
    required this.shiftSchedule,
    required this.lastAssignment,
  }) : assert(role == 'SUPPORT' || role == 'SUPERVISOR' || role == 'ADMIN', 'Invalid role');

  factory Agent.fromJson(Map<String, dynamic> json) {
    try {
      final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      final name = json['name']?.toString() ?? '';
      final email = json['email']?.toString() ?? '';
      final role = json['role']?.toString() ?? 'SUPPORT';
      final shiftScheduleJson = json['shiftSchedule'] as Map<String, dynamic>? ?? {};

      return Agent(
        id: id,
        name: name,
        email: email,
        role: role,
        isAvailable: json['isAvailable'] ?? true,
        isOnline: json['isOnline'] ?? false,
        currentTickets: (json['currentTickets'] as List?)
            ?.map((ticket) => Ticket.fromJson(ticket as Map<String, dynamic>))
            .toList() ?? [],
        skills: (json['skills'] as List?)
            ?.map((skill) => skill.toString())
            .toList() ?? [],
        shiftSchedule: ShiftSchedule(
          id: shiftScheduleJson['id']?.toString() ?? '',
          agentId: id,
          weekdays: List<int>.from(shiftScheduleJson['weekdays'] ?? []),
          startTime: shiftScheduleJson['startTime'] != null 
              ? DateTime.parse(shiftScheduleJson['startTime']) 
              : DateTime.now(),
          endTime: shiftScheduleJson['endTime'] != null 
              ? DateTime.parse(shiftScheduleJson['endTime'])
              : DateTime.now().add(const Duration(hours: 8)),
          isActive: shiftScheduleJson['isActive'] ?? true,
          scheduleType: shiftScheduleJson['scheduleType']?.toString() ?? 'FIXED',
        ),
        lastAssignment: json['lastAssignment'] != null
            ? DateTime.parse(json['lastAssignment'])
            : DateTime.now(),
      );
    } catch (e) {
      throw FormatException('Error parsing Agent from JSON: $e\nJSON: $json');
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role,
    'isAvailable': isAvailable,
    'isOnline': isOnline,
    'skills': skills,
    'currentTickets': currentTickets.map((ticket) => ticket.toJson()).toList(),
    'shiftSchedule': shiftSchedule.toJson(),
    'lastAssignment': lastAssignment.toIso8601String(),
  };

  bool isWorkingAt(DateTime date) {
    return shiftSchedule.isWorkingAt(date);
  }

  double getRemainingHours() {
    final now = DateTime.now();
    if (!isWorkingAt(now)) return 0.0;

    final endTime = shiftSchedule.endTime;
    final remaining = endTime.difference(now).inMinutes / 60.0;
    
    return remaining.clamp(0.0, 24.0);
  }

  bool canHandleTicket(double estimatedHours) {
    if (!isAvailable || !isOnline) return false;
    if (currentTickets.length >= 3) return false;
    
    final remainingHours = getRemainingHours();
    return remainingHours >= estimatedHours;
  }

  Agent copyWith({
    String? name,
    String? email,
    String? role,
    bool? isAvailable,
    bool? isOnline,
    List<String>? skills,
    List<Ticket>? currentTickets,
    ShiftSchedule? shiftSchedule,
    DateTime? lastAssignment,
  }) {
    return Agent(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isAvailable: isAvailable ?? this.isAvailable,
      isOnline: isOnline ?? this.isOnline,
      skills: skills ?? this.skills,
      currentTickets: currentTickets ?? this.currentTickets,
      shiftSchedule: shiftSchedule ?? this.shiftSchedule,
      lastAssignment: lastAssignment ?? this.lastAssignment,
    );
  }
}