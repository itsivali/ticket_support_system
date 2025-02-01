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
    if (startTime.isAfter(endTime)) {
      throw ArgumentError('Start time must be before end time');
    }
    if (weekdays.any((day) => day < 1 || day > 7)) {
      throw ArgumentError('Weekdays must be between 1 and 7');
    }
  }

  factory ShiftSchedule.fromJson(Map<String, dynamic> json) {
    return ShiftSchedule(
      id: json['_id'] ?? '',
      agentId: json['agentId'] ?? '',
      weekdays: List<int>.from(json['weekdays'] ?? []),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isActive: json['isActive'] ?? true,
    );
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

    final shiftStart = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      startTime.hour,
      startTime.minute,
    );

    final shiftEnd = DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      endTime.hour,
      endTime.minute,
    );

    return dateTime.isAfter(shiftStart) && 
           dateTime.isBefore(shiftEnd);
  }

  Duration getTimeUntilNextShift(DateTime fromTime) {
    if (isWorkingAt(fromTime)) return Duration.zero;

    var nextDate = fromTime;
    while (!weekdays.contains(nextDate.weekday)) {
      nextDate = nextDate.add(const Duration(days: 1));
    }

    final nextShiftStart = DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      startTime.hour,
      startTime.minute,
    );

    if (nextShiftStart.isBefore(fromTime)) {
      nextDate = nextDate.add(const Duration(days: 1));
    }

    return nextShiftStart.difference(fromTime);
  }
}