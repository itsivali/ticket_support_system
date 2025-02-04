import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logger/logger.dart';


class NotificationService {
  final String connectionString;
  late Db db;

  NotificationService(this.connectionString);

  Future<void> connect() async {
  // late Db db; (removed this line)
  late Db db;
  var logger = Logger();

  try {
    db = Db(connectionString);
    await db.open();
    logger.i('Connected to the database');
  } catch (e) {
    logger.e('Error connecting to the database: $e');
  }
  }

  Future<List<AppNotification>> getNotifications(String recipientId) async {
    late DbCollection notificationsCollection;
    var logger = Logger();

    try {
      notificationsCollection = db.collection('notifications');
      final notifications = await notificationsCollection.find(where.eq('recipientId', recipientId)).toList();

      return notifications.map((notification) {
      return AppNotification(
        title: notification['title'] as String,
        message: notification['message'] as String,
      );
      }).toList();
    } catch (e) {
      logger.e('Error fetching notifications: $e');
    }
    return [];
  }

  Future<void> notify({
    required String recipientId,
    required String title,
    required String message,
    required String type,
  }) async {
  var logger = Logger();
  try {
    final notificationsCollection = db.collection('notifications');
    await notificationsCollection.insert({
    'recipientId': recipientId,
    'title': title,
    'message': message,
    'type': type,
    'timestamp': DateTime.now().toIso8601String(),
    });
    logger.i('Notification sent to $recipientId');
  } catch (e) {
    logger.e('Error sending notification: $e');
  }
  }
}

class AppNotification {
  final String title;
  final String message;

  AppNotification({required this.title, required this.message});
}

void main() async {
  final notificationService = NotificationService('mongodb://localhost:27017/ticket_support_system');
  await notificationService.connect();

  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NotificationService>.value(value: notificationService),
      ],
      child: const MaterialApp(
        home: NotificationScreen(),
      ),
    );
  }
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: FutureBuilder<List<AppNotification>>(
        future: notificationService.getNotifications('recipientId'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No notifications');
          } else {
            final appNotifications = snapshot.data!;
            return ListView.builder(
              itemCount: appNotifications.length,
              itemBuilder: (context, index) {
                final appNotification = appNotifications[index];
                return ListTile(
                  title: Text(appNotification.title),
                  subtitle: Text(appNotification.message),
                );
              },
            );
          }
        },
      ),
    );
  }
}