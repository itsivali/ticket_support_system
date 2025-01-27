class Agent {
  final String id;
  final String name;

  Agent({
    required this.id,
    required this.name,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}