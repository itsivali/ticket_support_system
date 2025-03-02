class Ticket {
  final int? id;
  final String title;
  final String description;
  final int? agentId;
  final DateTime createdAt;

  Ticket({
    this.id,
    required this.title,
    required this.description,
    this.agentId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'agentId': agentId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      agentId: map['agentId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Ticket copyWith({
    int? id,
    String? title,
    String? description,
    int? agentId,
    DateTime? createdAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      agentId: agentId ?? this.agentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}