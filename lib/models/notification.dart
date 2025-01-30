enum NotificationType {
  TICKET_ASSIGNED,
  TICKET_UPDATED,
  QUEUE_ALERT,
  SHIFT_REMINDER
}

class Notification {
  final String id;
  final String recipientId;
  final String title;
  final String message;
  final NotificationType type;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  bool isRead;
  bool isDelivered;

  Notification({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    this.metadata,
    DateTime? createdAt,
    this.isRead = false,
    this.isDelivered = false,
  }) : this.createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipientId': recipientId,
    'title': title,
    'message': message,
    'type': type.toString(),
    'metadata': metadata,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'isDelivered': isDelivered,
  };
}