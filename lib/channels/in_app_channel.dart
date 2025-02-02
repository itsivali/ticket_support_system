import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification.dart';
import '../utils/console_logger.dart';
import 'base_channel.dart';

class InAppChannel implements NotificationChannel {
  static const String storageKeyPrefix = 'notifications_';
  final Future<SharedPreferences> _storage;
  final StreamController<Notification> _controller;

  InAppChannel() : 
    _storage = SharedPreferences.getInstance(),
    _controller = StreamController<Notification>.broadcast();

  @override
  String get channelType => 'in_app';

  Stream<Notification> get notificationStream => _controller.stream;

  @override
  Future<bool> send(Notification notification) async {
    try {
      final prefs = await _storage;
      final notifications = await _getStoredNotifications(notification.recipientId);
      notifications.add(notification);
      
      final success = await prefs.setString(
        '$storageKeyPrefix${notification.recipientId}',
        jsonEncode(notifications.map((n) => n.toJson()).toList()),
      );

      if (success) {
        _controller.add(notification);
      }
      
      return success;
    } catch (e) {
      ConsoleLogger.error('Error getting all notifications', e.toString());
      return false;
    }
  }

  @override
  Future<bool> isDelivered(String notificationId) async {
    try {
      final notifications = await _getAllStoredNotifications();
      return notifications.any((n) => n.id == notificationId);
    } catch (e) {
      ConsoleLogger.error('Error getting all notifications', e.toString());
      return false;
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      final notifications = await _getAllStoredNotifications();
      final index = notifications.indexWhere((n) => n.id == notificationId);
      
      if (index != -1) {
        notifications[index].isRead = true;
        await _saveNotifications(notifications);
      }
    } catch (e) {
      ConsoleLogger.error('Error getting all notifications', e.toString());
    }
  }

  Future<List<Notification>> _getStoredNotifications(String userId) async {
    try {
      final prefs = await _storage;
      final data = prefs.getString('$storageKeyPrefix$userId');
      if (data == null) return [];
      
      return (jsonDecode(data) as List)
          .map((item) => Notification.fromJson(item))
          .toList();
    } catch (e) {
      ConsoleLogger.error('Error getting all stored notifications', e.toString());
      return [];
    }
  }

  Future<List<Notification>> _getAllStoredNotifications() async {
    try {
      final prefs = await _storage;
      final allNotifications = <Notification>[];
      
      for (final key in prefs.getKeys()) {
        if (key.startsWith(storageKeyPrefix)) {
          final userNotifications = await _getStoredNotifications(
            key.replaceFirst(storageKeyPrefix, '')
          );
          allNotifications.addAll(userNotifications);
        }
      }
      
      return allNotifications;
    } catch (e) {
      ConsoleLogger.error('Error getting all stored notifications', e.toString());
      return [];
    }
  }

  Future<void> _saveNotifications(List<Notification> notifications) async {
    try {
      final prefs = await _storage;
      final grouped = <String, List<Notification>>{};
      
      // Group notifications by recipient
      for (final notification in notifications) {
        grouped.putIfAbsent(notification.recipientId, () => [])
          .add(notification);
      }
      
      // Save each group
      for (final entry in grouped.entries) {
        await prefs.setString(
          '$storageKeyPrefix${entry.key}',
          jsonEncode(entry.value.map((n) => n.toJson()).toList()),
        );
      }
    } catch (e) {
      ConsoleLogger.error('Error getting all notifications', e.toString());
    }
  }

  void dispose() {
    _controller.close();
  }
}