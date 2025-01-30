import 'package:mailer/mailer.dart';
import '../interfaces/notification_channel.dart';

class EmailChannel implements NotificationChannel {
  final SmtpServer _server;
  final Map<String, bool> _deliveryStatus = {};

  EmailChannel(this._server);

  @override
  Future<void> send(Notification notification) async {
    final message = Message()
      ..from = Address('support@system.com')
      ..recipients.add(notification.recipientEmail)
      ..subject = notification.title
      ..text = notification.message;

    try {
      final sendReport = await send(message, _server);
      _deliveryStatus[notification.id] = sendReport.sent;
    } catch (e) {
      _deliveryStatus[notification.id] = false;
      throw NotificationException('Email delivery failed: $e');
    }
  }

  @override
  Future<bool> isDelivered(String notificationId) async {
    return _deliveryStatus[notificationId] ?? false;
  }
}