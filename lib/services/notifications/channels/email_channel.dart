import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import '../utils/console_logger.dart';
import 'base_channel.dart';

class EmailNotification {
  final String id;
  final String recipientEmail;
  final String title;
  final String message;
  final String? sender;

  EmailNotification({
    required this.id,
    required this.recipientEmail,
    required this.title,
    required this.message,
    this.sender,
  });
}

class DeliveryStatus {
  final bool sent;
  final DateTime timestamp;
  final String? error;

  DeliveryStatus({
    required this.sent,
    required this.timestamp,
    this.error,
  });
}

class EmailChannel implements NotificationChannel {
  final SmtpServer _server;
  final Map<String, DeliveryStatus> _deliveryTracker = {};

  EmailChannel(this._server);

  @override
  String get channelType => 'email';

  String _buildEmailTemplate(EmailNotification notification) {
    return '''
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <h2 style="color: #2196F3;">${notification.title}</h2>
        <div style="padding: 20px; background-color: #f5f5f5; border-radius: 4px;">
          ${notification.message}
        </div>
        <p style="color: #666; font-size: 12px; margin-top: 20px;">
          This is an automated message from the Support System
        </p>
      </div>
    ''';
  }

  @override
  Future<bool> send(EmailNotification notification) async {
    try {
      ConsoleLogger.info(
        'Sending email notification',
        'To: ${notification.recipientEmail}\nSubject: ${notification.title}'
      );

      final message = Message()
        ..from = Address(notification.sender ?? 'support@system.com')
        ..recipients.add(notification.recipientEmail)
        ..subject = notification.title
        ..html = _buildEmailTemplate(notification);

      final sendReport = await mailer.send(message, _server);
      
      _deliveryTracker[notification.id] = DeliveryStatus(
        sent: true,
        timestamp: DateTime.now(),
      );
      
      ConsoleLogger.info(
        'Email sent successfully',
        'Message ID: ${sendReport.messageid}'
      );

      return true;
    } catch (e, stack) {
      ConsoleLogger.error('Failed to send email', e, stack);
      
      _deliveryTracker[notification.id] = DeliveryStatus(
        sent: false,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
      
      return false;
    }
  }

  @override
  Future<bool> isDelivered(String notificationId) async {
    final status = _deliveryTracker[notificationId];
    return status?.sent ?? false;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Email notifications don't need read status tracking
    return;
  }

  DeliveryStatus? getDeliveryStatus(String notificationId) {
    return _deliveryTracker[notificationId];
  }

  void clearDeliveryHistory() {
    _deliveryTracker.clear();
  }
}

class NotificationException implements Exception {
  final String message;
  final dynamic error;

  NotificationException(this.message, [this.error]);

  @override
  String toString() => 'NotificationException: $message${error != null ? '\nCause: $error' : ''}';
}