import 'dart:async';
import 'dart:collection';
import 'package:ticket_support_system/models/notification.dart';
import './interfaces/notification_channel.dart';
import 'package:ticket_support_system/utils/console_logger.dart';

class NotificationService {
  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(minutes: 1);
  
  final Map<String, NotificationChannel> _channels = {};
  final Queue<NotificationItem> _queue = Queue();
  Timer? _processTimer;

  NotificationService() {
    _startQueueProcessing();
  }

  void registerChannel(String type, NotificationChannel channel) {
    _channels[type] = channel;
  }

  Future<void> notify({
    required String recipientId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipientId: recipientId,
      title: title,
      message: message,
      type: type,
      metadata: metadata,
    );

    _queue.add(NotificationItem(notification: notification));
  }

  void _startQueueProcessing() {
    _processTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _processQueue()
    );
  }

  Future<void> _processQueue() async {
    if (_queue.isEmpty) return;

    final notification = _queue.removeFirst();
    final channel = _channels[notification.notification.type];
    
    if (channel != null) {
      try {
        final success = await channel.send(notification.notification);
        if (!success && notification.retryCount < maxRetries) {
          notification.retryCount++;
          _scheduleRetry(notification);
        }
      } catch (e) {
        ConsoleLogger.error(
          'Notification delivery failed', 
          'Type: ${notification.notification.type}\nError: $e'
        );
        if (notification.retryCount < maxRetries) {
          notification.retryCount++;
          _scheduleRetry(notification);
        }
      }
    }
  }

  void _scheduleRetry(NotificationItem notification) {
    Future.delayed(
      retryInterval * notification.retryCount,
      () => _queue.add(notification)
    );
  }

  Future<bool> isDelivered(String notificationId) async {
    for (final channel in _channels.values) {
      if (await channel.isDelivered(notificationId)) {
        return true;
      }
    }
    return false;
  }

  void dispose() {
    _processTimer?.cancel();
    _queue.clear();
  }
}

class NotificationItem {
  final Notification notification;
  int retryCount;

  NotificationItem({
    required this.notification,
    this.retryCount = 0,
  });
}