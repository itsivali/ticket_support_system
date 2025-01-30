class NotificationService {
  final Map<String, NotificationChannel> _channels = {};
  final Queue<Notification> _queue = Queue();
  Timer? _processTimer;

  NotificationService() {
    _channels['email'] = EmailChannel();
    _channels['in_app'] = InAppChannel();
    _channels['push'] = PushChannel();
    _startQueueProcessing();
  }

  Future<void> notify(String agentId, String message, {
    String? title,
    String type = 'in_app'
  }) async {
    final notification = Notification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipientId: agentId,
      title: title ?? 'New Notification',
      message: message,
      type: type,
    );
    
    _queue.add(notification);
  }

  void _startQueueProcessing() {
    _processTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _processQueue()
    );
  }

  Future<void> _processQueue() async {
    while (_queue.isNotEmpty) {
      final notification = _queue.removeFirst();
      final channel = _channels[notification.type];
      
      if (channel != null) {
        try {
          await channel.send(notification);
          notification.isDelivered = true;
        } catch (e) {
          ConsoleLogger.error('Notification delivery failed', e);
          _queue.addLast(notification); // Retry later
        }
      }
    }
  }

  void dispose() {
    _processTimer?.cancel();
  }
}