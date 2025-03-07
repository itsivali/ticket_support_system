class Agent {
  final dynamic id; 
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
      if (id != null) '_id': id,
      'name': name,
      'online': online,
      'shiftStart': shiftStart.toIso8601String(),
    };
  }

  factory Agent.fromMap(Map<String, dynamic> map) {
    return Agent(
      id: map['_id'],
      name: map['name'],
      online: map['online'],
      shiftStart: DateTime.parse(map['shiftStart']),
    );
  }
}