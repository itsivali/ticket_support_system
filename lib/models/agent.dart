import 'shift_schedule.dart';

class Agent {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isAvailable;
  final bool isOnline;
  final List<String> skills;
  final List<String> currentTickets;
  final ShiftSchedule? shiftSchedule;
  final DateTime? lastAssignment;

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
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'SUPPORT',
      isAvailable: json['isAvailable'] ?? true,
      isOnline: json['isOnline'] ?? true,
      skills: List<String>.from(json['skills'] ?? []),
      currentTickets: List<String>.from(json['currentTickets'] ?? []),
      shiftSchedule: json['shiftSchedule'] != null 
          ? ShiftSchedule.fromJson(json['shiftSchedule'])
          : null,
      lastAssignment: json['lastAssignment'] != null
          ? DateTime.parse(json['lastAssignment'])
          : null,
    );
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