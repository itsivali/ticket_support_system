class Notification {
  final String id;
  final String recipientId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  bool isDelivered;

  Notification({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    this.metadata,
    bool? isDelivered,
    DateTime? createdAt,
  })  : isDelivered = isDelivered ?? false,
        createdAt = createdAt ?? DateTime.now();

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      recipientId: json['recipientId'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      metadata: json['metadata'],
      isDelivered: json['isDelivered'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipientId': recipientId,
        'title': title,
        'message': message,
        'type': type,
        'metadata': metadata,
        'isDelivered': isDelivered,
        'createdAt': createdAt.toIso8601String(),
      };
}