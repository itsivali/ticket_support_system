import './ticket.dart';
import './shift.dart';

class ShiftSchedule {
  final String id;
  final String agentId;
  final List<int> weekdays;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final double hoursPerDay;
  final String scheduleType;

  ShiftSchedule({
    required this.id,
    required this.agentId,
    required this.weekdays,
    required this.startTime,
    required this.endTime,
    required this.hoursPerDay,
    this.isActive = true,
    this.scheduleType = 'REGULAR',
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
        hoursPerDay: json['hoursPerDay'] ?? 8.0,
        scheduleType: json['scheduleType'] ?? 'default',
      );
    } catch (e) {
      throw FormatException('Error parsing ShiftSchedule: $e\nJSON: $json');
    }
  }

  factory ShiftSchedule.fromShift(Shift shift) {
    return ShiftSchedule(
      id: shift.id,
      agentId: shift.agentId,
      startTime: shift.startTime,
      endTime: shift.endTime,
      weekdays: shift.weekdays,
      isActive: shift.isActive,
      hoursPerDay: 8.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'agentId': agentId,
    'weekdays': weekdays,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'isActive': isActive,
    'hoursPerDay': hoursPerDay,
    'scheduleType': scheduleType,
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

  bool parseAndCheckWorkingAt(String dateTime) {
    final date = DateTime.parse(dateTime);
    return isWorkingAt(date);
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
    
    final dueDate = ticket.dueDate;
    if (!weekdays.contains(dueDate.weekday)) return false;

    // Calculate time needed to complete ticket
    final ticketDuration = Duration(hours: ticket.estimatedHours.ceil());
    final ticketEndTime = DateTime.now().add(ticketDuration);

    // Check if there's enough time in shift to complete ticket
    return isWorkingAt(DateTime.now()) && 
           isWorkingAt(ticketEndTime);
  }

  double getRemainingHours() {
    final now = DateTime.now();
    if (!isWorkingAt(now)) return 0.0;
    
    // Create end time for today's shift
    final todayShiftEnd = DateTime(
      now.year, 
      now.month, 
      now.day,
      endTime.hour,
      endTime.minute
    );
    
    // Calculate remaining time in hours
    final remainingMinutes = todayShiftEnd.difference(now).inMinutes;
    return remainingMinutes / 60.0;
  }

  ShiftSchedule copyWith({
    String? id,
    String? agentId,
    DateTime? startTime,
    DateTime? endTime,
    List<int>? weekdays,
    bool? isActive,
    double? hoursPerDay,
  }) {
    return ShiftSchedule(
      id: id ?? this.id,
      agentId: agentId ?? this.agentId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      weekdays: weekdays ?? this.weekdays,
      isActive: isActive ?? this.isActive,
      hoursPerDay: hoursPerDay ?? this.hoursPerDay,
    );
  }

  Map<String, dynamic> toShift() {
    return {
      'id': id,
      'agentId': agentId,
      'weekdays': weekdays,
      'startTime': startTime.toString(),
      'endTime': endTime.toString(),
      'isActive': isActive,
    };
  }
}