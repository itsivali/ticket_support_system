import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/notification.dart';
import 'base_channel.dart';

class PushChannel implements NotificationChannel {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Map<String, String> _tokenCache = {};

  @override
  String get channelType => 'push';

  Future<void> initialize() async {
    await Firebase.initializeApp();
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  @override
  Future<bool> send(Notification notification) async {
    try {
      final token = await _getDeviceToken(notification.recipientId);
      if (token == null) return false;

      await _fcm.send(RemoteMessage(
        token: token,
        notification: RemoteNotification(
          title: notification.title,
          body: notification.message,
        ),
        data: {
          'id': notification.id,
          'type': notification.type.toString(),
          ...notification.metadata ?? {},
        },
      ));
      
      return true;
    } catch (e) {
      ConsoleLogger.error('Push notification failed', e);
      return false;
    }
  }

  Future<String?> _getDeviceToken(String userId) async {
    if (_tokenCache.containsKey(userId)) {
      return _tokenCache[userId];
    }
    
    final token = await _fcm.getToken();
    if (token != null) {
      _tokenCache[userId] = token;
    }
    return token;
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background message
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Handle foreground message
  }

  @override
  Future<bool> isDelivered(String notificationId) async {
    // Implementation depends on FCM delivery receipts
    return true;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Update read status in backend
  }
}