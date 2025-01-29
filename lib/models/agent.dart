class Agent {
  final String id;
  final String name;
  final bool isAvailable;

  Agent({
    required this.id,
    required this.name,
    required this.isAvailable,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['_id']?.toString() ?? '',  
      name: json['name'] as String,
      isAvailable: json['isAvailable'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'isAvailable': isAvailable,
    };
  }
}