class Notification {
  final String id;
  final String message;

  Notification({required this.id, required this.message});
}

abstract class NotificationChannel {
  Future<void> send(Notification notification);
  Future<bool> isDelivered(String notificationId);
}