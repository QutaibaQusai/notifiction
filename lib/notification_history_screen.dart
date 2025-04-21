import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class NotificationHistoryScreen extends StatefulWidget {
  const NotificationHistoryScreen({super.key});

  @override
  State<NotificationHistoryScreen> createState() =>
      _NotificationHistoryScreenState();
}

class _NotificationHistoryScreenState extends State<NotificationHistoryScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationStrings = prefs.getStringList('notifications') ?? [];

    setState(() {
      notifications = notificationStrings.map((str) {
        // Simple parsing (in a real app, use proper JSON serialization)
        final cleanedStr = str
            .replaceAll('{', '')
            .replaceAll('}', '')
            .replaceAll("'", "")
            .replaceAll('"', '');
        final parts = cleanedStr.split(', ');
        final Map<String, dynamic> map = {};
        for (var part in parts) {
          final keyValue = part.split(': ');
          if (keyValue.length == 2) {
            map[keyValue[0].trim()] = keyValue[1].trim();
          }
        }
        return map;
      }).toList();
      notifications = notifications.reversed.toList(); // Show newest first
    });
  }

  void _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $urlString')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('notifications');
              setState(() {
                notifications = [];
              });
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications received yet'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final timestamp = notification['timestamp'] != null
                    ? DateTime.parse(notification['timestamp'])
                    : DateTime.now();
                final formattedTime =
                    DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp);

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['title'] ?? 'No title',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(notification['body'] ?? 'No body'),
                        if (notification['image']?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          CachedNetworkImage(
                            imageUrl: notification['image']!,
                            placeholder: (context, url) =>
                                const CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          formattedTime,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (notification['data']?.contains('http') ?? false) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              // Extract URL from data (simplified)
                              final data = notification['data'] ?? '';
                              final uriMatch = RegExp(
                                      r'(https?:\/\/[^\s,]+)')
                                  .firstMatch(data);
                              if (uriMatch != null) {
                                _launchUrl(uriMatch.group(1)!);
                              }
                            },
                            child: Text(
                              'Open Link',
                              style: TextStyle(
                                color: Colors.blue[600],
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}