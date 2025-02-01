import 'dart:async';
import 'dart:collection';
import '../models/notification.dart';
import './interfaces/notification_channel.dart';
import '../utils/console_logger.dart';

class NotificationService {
  static const int MAX_RETRIES = 3;
  static const Duration RETRY_INTERVAL = Duration(minutes: 1);
  
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
    if (!_channels.containsKey(type)) {
      throw ArgumentError('No channel registered for type: $type');
    }

    final notification = Notification(
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
        final success = await channel.send(item.notification);
        if (!success && item.retryCount < MAX_RETRIES) {
          _scheduleRetry(item);
        }
      } catch (e) {
        ConsoleLogger.error('Delivery failed', e);
        if (item.retryCount < MAX_RETRIES) {
          _scheduleRetry(item);
        }
      }
    }
  }

  void _scheduleRetry(NotificationItem item) {
    item.retryCount++;
    Future.delayed(
      RETRY_INTERVAL * item.retryCount,
      () => _queue.add(item)
    );
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