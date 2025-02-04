import 'ticket.dart';
import 'shift.dart';
class ShiftSchedule {
  final String id;
  final String agentId;
  final List<int> weekdays;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final String scheduleType;

  ShiftSchedule({
    required this.id,
    required this.agentId,
    required this.weekdays,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.scheduleType,
  });

  factory ShiftSchedule.fromJson(Map<String, dynamic> json) {
    return ShiftSchedule(
      id: json['id'] ?? '',
      agentId: json['agentId'] ?? '',
      weekdays: List<int>.from(json['weekdays'] ?? []),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isActive: json['isActive'] ?? true,
      scheduleType: json['scheduleType'] ?? 'FIXED',
    );
  }

  factory ShiftSchedule.fromShift(Shift shift) {
    return ShiftSchedule(
      id: shift.id,
      agentId: shift.agentId,
      startTime: shift.startTime,
      endTime: shift.endTime,
      weekdays: shift.weekdays,
      isActive: shift.isActive,
      scheduleType: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'agentId': agentId,
      'weekdays': weekdays,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isActive': isActive,
      'scheduleType': scheduleType,
    };
  }

  bool isWorkingAt(DateTime date) {
    if (!weekdays.contains(date.weekday)) return false;

    final todayStart = DateTime(date.year, date.month, date.day, startTime.hour, startTime.minute);
    final todayEnd = DateTime(date.year, date.month, date.day, endTime.hour, endTime.minute);

    return date.isAfter(todayStart) && date.isBefore(todayEnd);
  }

  double getRemainingHours() {
    final now = DateTime.now();
    if (!isWorkingAt(now)) return 0.0;

    final remaining = endTime.difference(now).inMinutes / 60.0;
    return remaining.clamp(0.0, 24.0);
  }

  bool canHandleTicket(Ticket ticket) {
    return isWorkingAt(ticket.createdAt);
  }

  double get hoursPerDay {
    return 8.0; // example value
  }

  Map<String, dynamic> toShift() {
    return {
      'id': id,
      'agentId': agentId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'weekdays': weekdays,
      'isActive': isActive,
    };
  }
}