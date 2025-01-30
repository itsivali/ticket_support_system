abstract class NotificationChannel {
  Future<void> send(Notification notification);
  Future<bool> isDelivered(String notificationId);
}