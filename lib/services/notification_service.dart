import 'dart:async';
import 'dart:collection';
import '../models/notification.dart' as model;
import '../interfaces/notification_channel.dart' as channel;
import '../utils/console_logger.dart';

class NotificationService {
  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(minutes: 1);
  
  final Map<String, channel.NotificationChannel> _channels = {};
  final Queue<NotificationItem> _queue = Queue();
  Timer? _processTimer;

  NotificationService() {
    _startQueueProcessing();
  }

  void registerChannel(String type, channel.NotificationChannel channel) {
    _channels[type] = channel;
  }

  Future<void> notify({
    required String recipientId,
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_channels.containsKey(type)) {
      throw ArgumentError('No channel registered for type: $type');
    }

    final notification = model.Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipientId: recipientId,
      title: title,
      message: message,
      type: type,
      metadata: metadata,
    );

    _queue.add(NotificationItem(notification: notification));
    ConsoleLogger.info('Notification queued', 'ID: ${notification.id}');
  }

  void _startQueueProcessing() {
    _processTimer?.cancel();
    _processTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _processQueue()
    );
  }

  Future<void> _processQueue() async {
    if (_queue.isEmpty) return;

    final item = _queue.removeFirst();
    final channel = _channels[item.notification.type];
    
    if (channel != null) {
      try {
        final channelNotification = channel.notification(
          id: item.notification.id,
          recipientId: item.notification.recipientId,
          title: item.notification.title,
          message: item.notification.message,
          type: item.notification.type,
          metadata: item.notification.metadata,
        );
        final success = await channel.send(channelNotification);
        if (!success && item.retryCount < maxRetries) {
          _scheduleRetry(item);
        }
      } catch (e) {
        ConsoleLogger.error('Delivery failed', e.toString());
        if (item.retryCount < maxRetries) {
          _scheduleRetry(item);
        }
      }
    }
  }

  void _scheduleRetry(NotificationItem item) {
    item.retryCount++;
    Future.delayed(
      retryInterval * item.retryCount,
      () => _queue.add(item)
    );
  }

  void dispose() {
    _processTimer?.cancel();
    _queue.clear();
  }
}

class NotificationItem {
  final model.Notification notification;
  int retryCount;

  NotificationItem({
    required this.notification,
    this.retryCount = 0,
  });
}