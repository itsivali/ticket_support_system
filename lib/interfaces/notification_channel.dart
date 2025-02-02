abstract class NotificationChannel {

  Notification notification({

    required String id,

    required String recipientId,

    required String title,

    required String message,

    required String type,

    Map<String, dynamic>? metadata,

  });

  Future<bool> send(Notification notification);

  Future<bool> isDelivered(String notificationId);

  Future<void> markAsRead(String notificationId);

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
