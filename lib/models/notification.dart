class Notification {
  final String id;
  final String title;
  final String message;
  final String recipientId;
  final String? recipientEmail;
  final String? sender;
  final NotificationType type;
  final Map<String, dynamic>? metadata;
  bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.recipientId,
    this.recipientEmail,
    this.sender,
    required this.type,
    this.metadata,
    this.isRead = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      recipientId: json['recipientId'],
      recipientEmail: json['recipientEmail'],
      sender: json['sender'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.general,
      ),
      metadata: json['metadata'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'recipientId': recipientId,
    'recipientEmail': recipientEmail,
    'sender': sender,
    'type': type.toString(),
    'metadata': metadata,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };
}

enum NotificationType {
  general,
  ticketAssigned,
  ticketUpdated,
  shiftReminder,
  queueAlert
}