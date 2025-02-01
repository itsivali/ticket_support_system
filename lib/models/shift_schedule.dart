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
  });

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

  bool isWorkingAt(DateTime time) {
    return weekdays.contains(time.weekday) &&
           time.isAfter(startTime) &&
           time.isBefore(endTime);
  }

  bool isWorkingAtDateTime(DateTime dateTime) {

    return isActive &&
         weekdays.contains(dateTime.weekday) &&
         dateTime.isAfter(DateTime(dateTime.year, dateTime.month, dateTime.day, startTime.hour, startTime.minute)) &&
         dateTime.isBefore(DateTime(dateTime.year, dateTime.month, dateTime.day, endTime.hour, endTime.minute));
  }
}