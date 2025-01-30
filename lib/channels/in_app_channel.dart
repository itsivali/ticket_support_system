import 'package:shared_preferences.dart';
import '../models/notification.dart';
import 'base_channel.dart';

class InAppChannel implements NotificationChannel {
  final _storage = SharedPreferences.getInstance();
  final StreamController<Notification> _controller = 
      StreamController<Notification>.broadcast();

  @override
  String get channelType => 'in_app';

  Stream<Notification> get notificationStream => _controller.stream;

  @override
  Future<bool> send(Notification notification) async {
    try {
      final prefs = await _storage;
      
      // Store notification
      final notifications = await _getStoredNotifications(notification.recipientId);
      notifications.add(notification);
      
      await prefs.setString(
        'notifications_${notification.recipientId}',
        jsonEncode(notifications.map((n) => n.toJson()).toList()),
      );

      // Broadcast to stream
      _controller.add(notification);
      
      return true;
    } catch (e) {
      ConsoleLogger.error('In-app notification failed', e);
      return false;
    }
  }

  @override
  Future<bool> isDelivered(String notificationId) async {
    final prefs = await _storage;
    final allNotifications = await _getAllStoredNotifications();
    return allNotifications.any((n) => n.id == notificationId);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final prefs = await _storage;
    final allNotifications = await _getAllStoredNotifications();
    
    final index = allNotifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      allNotifications[index].isRead = true;
      await _saveNotifications(allNotifications);
    }
  }

  Future<List<Notification>> _getStoredNotifications(String userId) async {
    final prefs = await _storage;
    final data = prefs.getString('notifications_$userId');
    if (data == null) return [];
    
    return (jsonDecode(data) as List)
        .map((item) => Notification.fromJson(item))
        .toList();
  }

  Future<void> _saveNotifications(List<Notification> notifications) async {
    final prefs = await _storage;
    await prefs.setString(
      'notifications',
      jsonEncode(notifications.map((n) => n.toJson()).toList()),
    );
  }

  void dispose() {
    _controller.close();
  }
}