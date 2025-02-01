
abstract class NotificationChannel {

  Future<void> send(Notification notification);

  Future<bool> isDelivered(String notificationId);

}



class Notification {

  final String id;

  final String recipientEmail;

  final String title;

  final String message;



  Notification({

    required this.id,

    required this.recipientEmail,

    required this.title,

    required this.message,

  });

}



class NotificationException implements Exception {

  final String message;

  NotificationException(this.message);

}
