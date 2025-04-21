import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _setupInteractedMessage();
  }

  Future<void> _setupInteractedMessage() async {
    //  terminated state
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationNavigation(initialMessage);
    }

  // background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationNavigation);

  // foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message received: ${message.notification?.title}');

    
    });
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    Navigator.pushNamed(context, '/history');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Notification History App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
              child: const Text('View Notification History'),
            ),
          ],
        ),
      ),
    );
  }
}
