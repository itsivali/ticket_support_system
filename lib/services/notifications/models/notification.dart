class Notification {
  final String id;
  final String recipientId;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  bool isDelivered;

  Notification({
    required this.id,
    required this.recipientId,
    required this.title,
    required this.message,
    required this.type,
    bool? isDelivered,
  }) : 
    createdAt = DateTime.now(),
    isDelivered = isDelivered ?? false;

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipientId': recipientId,
    'title': title,
    'message': message,
    'type': type,
    'createdAt': createdAt.toIso8601String(),
    'isDelivered': isDelivered,
  };
}