import './ticket.dart';

class ShiftSchedule {
  final String id;
  final String agentId;
  final List<int> weekdays;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  ShiftSchedule({
    required this.id,
    required this.agentId,
    required this.weekdays,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  }) {
    // Validate schedule data
    if (weekdays.any((day) => day < 1 || day > 7)) {
      throw ArgumentError('Weekdays must be between 1 and 7');
    }
  }

  factory ShiftSchedule.fromJson(Map<String, dynamic> json) {
    try {
      // Handle missing or null values
      final id = json['_id']?.toString() ?? '';
      final agentId = json['agentId']?.toString() ?? '';
      
      // Parse weekdays with fallback
      final weekdays = (json['weekdays'] as List<dynamic>?)
          ?.map((day) => int.parse(day.toString()))
          .toList() ?? [];
          
      // Parse dates with defaults
      final now = DateTime.now();
      final startTime = json['startTime'] != null 
          ? DateTime.parse(json['startTime'].toString())
          : DateTime(now.year, now.month, now.day, 9, 0); // 9 AM default
          
      final endTime = json['endTime'] != null
          ? DateTime.parse(json['endTime'].toString())
          : DateTime(now.year, now.month, now.day, 17, 0); // 5 PM default

      return ShiftSchedule(
        id: id,
        agentId: agentId,
        weekdays: weekdays,
        startTime: startTime,
        endTime: endTime,
        isActive: json['isActive'] ?? true,
      );
    } catch (e) {
      throw FormatException('Error parsing ShiftSchedule: $e\nJSON: $json');
    }
  }

  Map<String, dynamic> toJson() => {
    'agentId': agentId,
    'weekdays': weekdays,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'isActive': isActive,
  };

  bool isWorkingAt(DateTime dateTime) {
    if (!isActive) return false;
    if (!weekdays.contains(dateTime.weekday)) return false;

    // Create comparison times for just the hours/minutes
    final timeToCheck = DateTime(
      1970, 1, 1,
      dateTime.hour, dateTime.minute
    );
    
    final shiftStart = DateTime(
      1970, 1, 1,
      startTime.hour, startTime.minute
    );
    
    final shiftEnd = DateTime(
      1970, 1, 1,
      endTime.hour, endTime.minute
    );

    return !timeToCheck.isBefore(shiftStart) && 
           !timeToCheck.isAfter(shiftEnd);
  }

  Duration getTimeUntilNextShift(DateTime fromTime) {
    if (isWorkingAt(fromTime)) return Duration.zero;

    // Find next working day
    var nextDate = fromTime;
    int daysChecked = 0;
    while (!weekdays.contains(nextDate.weekday)) {
      nextDate = nextDate.add(const Duration(days: 1));
      daysChecked++;
      if (daysChecked > 7) return const Duration(days: 365); // No shifts found
    }

    // Set next shift start time
    final nextShiftStart = DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      startTime.hour,
      startTime.minute,
    );

    // If next shift start is before current time, add a day
    if (nextShiftStart.isBefore(fromTime)) {
      return getTimeUntilNextShift(
        fromTime.add(const Duration(days: 1))
      );
    }

    return nextShiftStart.difference(fromTime);
  }

  bool canHandleTicket(Ticket ticket) {
    // Check if ticket due date is within shift hours
    if (!isActive) return false;
    
    final dueDate = DateTime.parse(ticket.dueDate);
    if (!weekdays.contains(dueDate.weekday)) return false;

    // Calculate time needed to complete ticket
    final ticketDuration = Duration(hours: ticket.estimatedHours.ceil());
    final ticketEndTime = DateTime.now().add(ticketDuration);

    // Check if there's enough time in shift to complete ticket
    return isWorkingAt(DateTime.now()) && 
           isWorkingAt(ticketEndTime);
  }

}