import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';
import '../utils/console_logger.dart';
import 'base_channel.dart';

class EmailNotification {
  final String id;
  final String? sender;
  final String recipientEmail;
  final String title;
  final String message;

  EmailNotification({
    required this.id,
    this.sender,
    required this.recipientEmail,
    required this.title,
    required this.message,
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
  Future<bool> send(Notification notification) async {
    final emailNotification = notification as EmailNotification;
      ConsoleLogger.info(
        'Sending email notification',
        'To: ${emailNotification.recipientEmail}\nSubject: ${emailNotification.title}'
      );

      final emailMessage = mailer.Message()
        ..from = mailer.Address(emailNotification.sender ?? 'system@support.com')
        ..recipients.add(emailNotification.recipientEmail)
        ..subject = emailNotification.title
        ..html = _buildEmailTemplate(emailNotification);
        ..html = _buildEmailTemplate(notification);

      final sendReport = await mailer.send(emailMessage, _server);
      _deliveryTracker[emailNotification.id] = DeliveryStatus(
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
    // Implementation for marking email as read
    // Note: This is a basic implementation, modify according to your needs
    return;
  }
}