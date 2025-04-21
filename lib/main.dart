import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:push_bung/home_screen.dart';
import 'package:push_bung/notification_history_screen.dart';
import 'package:push_bung/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notification History',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      routes: {'/history': (context) => const NotificationHistoryScreen()},
    );
  }
}
