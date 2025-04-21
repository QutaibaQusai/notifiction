import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap when app is in foreground
      },
    );

    // Request permission (not strictly required on Android but good to keep)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
      _saveNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  static Future<void> _saveNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = prefs.getStringList('notifications') ?? [];

    final notificationData = {
      'title': message.notification?.title ?? 'No title',
      'body': message.notification?.body ?? 'No body',
      'image': message.notification?.android?.imageUrl ?? '',
      'timestamp': DateTime.now().toIso8601String(),
      'data': message.data.toString(),
    };

    notifications.add(notificationData.toString());
    await prefs.setStringList('notifications', notifications);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService._saveNotification(message);
}
