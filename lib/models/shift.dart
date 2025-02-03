class Shift {
  final String id;
  final String agentId;
  final List<int> weekdays;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  Shift({
    required this.id,
    required this.agentId,
    required this.weekdays,
    required this.startTime,
    required this.endTime,
    this.isActive = true,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['_id'] ?? '',
      agentId: json['agentId'] ?? '',
      weekdays: List<int>.from(json['weekdays'] ?? []),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isActive: json['isActive'] ?? true,
    );
  }

  factory Shift.fromMap(Map<String, dynamic> map) {
    return Shift(
      id: map['id'] ?? '',
      agentId: map['agentId'] ?? '',
      startTime: map['startTime'] ?? DateTime.now(),
      endTime: map['endTime'] ?? DateTime.now(),
      weekdays: List<int>.from(map['weekdays'] ?? []),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'agentId': agentId,
    'weekdays': weekdays,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'isActive': isActive,
  };
}