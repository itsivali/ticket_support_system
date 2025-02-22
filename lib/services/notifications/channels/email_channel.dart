import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as mailer;
import 'package:ticket_support_system/utils/console_logger.dart';

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

class EmailChannel {
  final mailer.SmtpServer _server;
  final Map<String, DeliveryStatus> _deliveryTracker = {};

  EmailChannel(this._server);

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

  Future<bool> send(EmailNotification notification) async {
    try {
      ConsoleLogger.info(
        'Sending email notification',
        'To: ${notification.recipientEmail}\nSubject: ${notification.title}'
      );

      final message = mailer.Message()
        ..from = mailer.Address(notification.sender ?? 'support@system.com')
        ..recipients.add(notification.recipientEmail)
        ..subject = notification.title
        ..html = _buildEmailTemplate(notification);

      await mailer.send(message, _server);
      
      _deliveryTracker[notification.id] = DeliveryStatus(
        sent: true,
        timestamp: DateTime.now(),
      );
      
      ConsoleLogger.info(
        'Email sent successfully',
        'Email sent successfully'
      );

      return true;
    } catch (e) {
      ConsoleLogger.error('Failed to send email', e.toString());
      
      _deliveryTracker[notification.id] = DeliveryStatus(
        sent: false,
        timestamp: DateTime.now(),
        error: e.toString(),
      );
      
      return false;
    }
  }

  Future<bool> isDelivered(String notificationId) async {
    final status = _deliveryTracker[notificationId];
    return status?.sent ?? false;
  }

  DeliveryStatus? getDeliveryStatus(String notificationId) {
    return _deliveryTracker[notificationId];
  }

  void clearDeliveryHistory() {
    _deliveryTracker.clear();
  }
}

void main() async {
  final smtpServer = mailer.SmtpServer(
    'smtp.example.com',
    username: 'your_username',
    password: 'your_password',
    port: 587,
    ssl: true,
  );

  final emailChannel = EmailChannel(smtpServer);

  final notification = EmailNotification(
    id: 'unique_id',
    recipientEmail: 'recipient@example.com',
    title: 'Test Notification',
    message: 'This is a test notification',
  );

  try {
    final sent = await emailChannel.send(notification);
    if (sent) {
      ConsoleLogger.info('Email sent successfully', 'Notification ID: ${notification.id}');
    }
  } catch (e) {
    ConsoleLogger.error('Failed to send email', e.toString());
  }
}