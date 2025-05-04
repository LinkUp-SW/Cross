

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:developer';


Future<void> handleBackgroundNotifications(RemoteMessage message) async {
  log('Background Notification - Title: ${message.notification?.title}');
  log('Background Notification - Body: ${message.notification?.body}');
  log('Background Notification - Data: ${message.data}');
}

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications(BuildContext context) async {
    // Request notification permissions
    await firebaseMessaging.requestPermission();

    // Get the FCM token
     final String? fcmToken = await firebaseMessaging.getToken();
    
    log('FCM Token: $fcmToken'); 

  

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(handleBackgroundNotifications);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground Notification - Title: ${message.notification?.title}');
      log('Foreground Notification - Body: ${message.notification?.body}');
      log('Foreground Notification - Data: ${message.data}');

      // Show an AlertDialog with the notification details
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(message.notification!.title ?? 'No Title'),
              content: Text(message.notification!.body ?? 'No Body'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      }
    });
  }
}

