import 'package:mailer/mailer.dart';
import 'base_channel.dart';

class EmailChannel implements NotificationChannel {
  final SmtpServer _server;
  final Map<String, DeliveryStatus> _deliveryTracker = {};

  EmailChannel(this._server);

  @override
  String get channelType => 'email';

  @override
  Future<bool> send(Notification notification) async {
    try {
      final message = Message()
        ..from = Address(notification.sender ?? 'system@support.com')
        ..recipients.add(notification.recipientEmail)
        ..subject = notification.title
        ..html = _buildEmailTemplate(notification);

      final sendReport = await send(message, _server);
      _deliveryTracker[notification.id] = DeliveryStatus(
        sent: true,
        timestamp: DateTime.now(),
      );
      
      return true;
    } catch (e) {
      _deliveryTracker[notification.id] = DeliveryStatus(
        sent: false,
        error: e.toString(),
        timestamp: DateTime.now(),
      );
      return false;
    }
  }

  @override
  Future<bool> isDelivered(String notificationId) async {
    return _deliveryTracker[notificationId]?.sent ?? false;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Email notifications are considered read once delivered
    return;
  }

  String _buildEmailTemplate(Notification notification) {
    // Template implementation
    return '''
      <html>
        <body>
          <h1>${notification.title}</h1>
          <p>${notification.message}</p>
        </body>
      </html>
    ''';
  }
}

class DeliveryStatus {
  final bool sent;
  final String? error;
  final DateTime timestamp;

  DeliveryStatus({
    required this.sent,
    this.error,
    required this.timestamp,
  });
}