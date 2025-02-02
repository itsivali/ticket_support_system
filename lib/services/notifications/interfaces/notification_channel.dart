import 'package:ticket_support_system/models/notification.dart';

abstract class NotificationChannel {

  Future<bool> send(Notification notification);

  Future<bool> isDelivered(String notificationId);

  Future<void> markAsRead(String notificationId);

}