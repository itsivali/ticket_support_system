import '../models/notification.dart';

abstract class NotificationChannel {
  String get channelType;
  Future<bool> send(Notification notification);
  Future<bool> isDelivered(String notificationId);
  Future<void> markAsRead(String notificationId);
}