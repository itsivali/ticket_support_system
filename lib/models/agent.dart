import '../utils/console_logger.dart';
import 'shift_schedule.dart';
import './ticket.dart';

class Agent {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isAvailable;
  final bool isOnline;
  final List<String> currentTickets;
  final List<String> skills;
  final ShiftSchedule? shiftSchedule;
  final DateTime? lastAssignment;

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
    this.shiftSchedule,
    this.lastAssignment,
  }) : assert(role == 'SUPPORT' || role == 'SUPERVISOR' || role == 'ADMIN', 'Invalid role');

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
        skills: json['skills'] != null 
            ? List<String>.from(json['skills'].map((skill) => skill.toString()))
            : [],
        shiftSchedule: json['shiftSchedule'] != null 
            ? ShiftSchedule.fromJson(json['shiftSchedule'] as Map<String, dynamic>)
            : null,
        lastAssignment: json['lastAssignment'] != null
            ? DateTime.parse(json['lastAssignment'])
            : null,
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
    'currentTickets': currentTickets,
    'shiftSchedule': shiftSchedule?.toJson(),
    'lastAssignment': lastAssignment?.toIso8601String(),
  };

  bool isWorkingAt(DateTime date) {
    if (shiftSchedule == null) return false;
    return shiftSchedule!.isWorkingAt(date);
  }

  double getRemainingHours() {
    if (shiftSchedule == null) return 0.0;
    
    final now = DateTime.now();
    if (!isWorkingAt(now)) return 0.0;

    final endTime = shiftSchedule!.endTime;
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
    List<String>? currentTickets,
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

  bool isWorkingAt(DateTime date) {
    // Check if the date falls on a working weekday
    if (!weekdays.contains(date.weekday)) return false;
    
    // Create DateTime objects for comparison with the same date
    final todayStart = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
    final todayEnd = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);
    
    // Check if the date falls within working hours
    return date.isAfter(todayStart) && date.isBefore(todayEnd);
  }

  double getRemainingHours() {
    // Calculate remaining hours in the shift
    // This is a basic implementation - adjust the logic according to your needs
    return 8.0; // Default to 8 hours
  }
}