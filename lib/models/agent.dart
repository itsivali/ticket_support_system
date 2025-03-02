class Agent {
  final int? id;
  final String name;
  final bool online;
  final DateTime shiftStart;

  Agent({
    this.id,
    required this.name,
    required this.online,
    required this.shiftStart,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'online': online ? 1 : 0,
      'shiftStart': shiftStart.toIso8601String(),
    };
  }

  factory Agent.fromMap(Map<String, dynamic> map) {
    return Agent(
      id: map['id'],
      name: map['name'],
      online: map['online'] == 1,
      shiftStart: DateTime.parse(map['shiftStart']),
    );
  }
}