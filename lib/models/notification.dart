class Notification {
  final String id;
  final String recipientId;
  final String title;
  final String message;
  final String type;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  bool isRead;

  Notification({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    this.metadata,
    bool? isRead,
    DateTime? createdAt,
  }) : 
    isRead = isRead ?? false,
    createdAt = createdAt ?? DateTime.now();

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      recipientId: json['recipientId'],
      type: json['type'],
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
    'type': type,
    'metadata': metadata,
    'isRead': isRead,
    'createdAt': createdAt.toIso8601String(),
  };
}