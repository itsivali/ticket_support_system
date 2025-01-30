class Agent {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isAvailable;

  static const List<String> validRoles = ['SUPPORT', 'SUPERVISOR', 'ADMIN'];

  Agent({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isAvailable,
  }) {
    if (!validRoles.contains(role)) {
      throw ArgumentError('Invalid role: $role');
    }
  }

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