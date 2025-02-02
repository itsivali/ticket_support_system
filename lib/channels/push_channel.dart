import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/notification.dart';
import '../utils/console_logger.dart';
import 'base_channel.dart';

class PushChannel implements NotificationChannel {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final Map<String, String> _tokenCache = {};
  bool _isInitialized = false;

  @override
  String get channelType => 'push';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Firebase.initializeApp();
      
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        _isInitialized = true;
      }
    } catch (e) {
      ConsoleLogger.error('Failed to initialize Firebase', e.toString());
      rethrow;
    }
  }

  @override
  Future<bool> send(Notification notification) async {
    if (!_isInitialized) await initialize();

    try {
      final token = await _getDeviceToken(notification.recipientId);
      if (token == null) {
        ConsoleLogger.error('No token found for recipient', notification.recipientId);
        return false;
      }

      // Note: This should be implemented on the server side using FCM HTTP v1 API
      // Client-side message sending is being deprecated
      throw UnimplementedError(
        'Direct device-to-device messaging is deprecated. Implement server-side FCM HTTP v1 API instead.'
      );
    } catch (e) {
      ConsoleLogger.error('Failed to send push notifications', e.toString());
      return false;
    }
  }

  Future<String?> _getDeviceToken(String userId) async {
    try {
      if (_tokenCache.containsKey(userId)) {
        return _tokenCache[userId];
      }
      
      final token = await _fcm.getToken();
      if (token != null) {
        _tokenCache[userId] = token;
        await _saveTokenToBackend(userId, token);
      }
      return token;
    } catch (e) {
  ConsoleLogger.error('Failed to get devoce tokens', e.toString());
      return null;
    }
  }

  Future<void> _saveTokenToBackend(String userId, String token) async {
    // Implement token storage in backend
  }

  @override
  Future<bool> isDelivered(String notificationId) async {
    // FCM doesn't provide reliable delivery tracking
    return true;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Not applicable for push notifications
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    ConsoleLogger.info(
      'Background message received',
      'MessageId: ${message.messageId}'
    );
  }

  void _handleForegroundMessage(RemoteMessage message) {
    ConsoleLogger.info(
      'Foreground message received',
      'MessageId: ${message.messageId}'
    );
  }

  void clearTokenCache() {
    _tokenCache.clear();
  }

  Future<void> refreshToken(String userId) async {
    _tokenCache.remove(userId);
    await _getDeviceToken(userId);
  }
}