class Agent {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isAvailable;

  Agent({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isAvailable,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['_id']?.toString() ?? '',
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      isAvailable: json['isAvailable'] as bool,
    );
  }
}