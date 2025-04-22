import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  // This function is triggered when the app is in the background or terminated
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    // Handle notification when the app is in the background or terminated
    print("Received a background message: ${message.notification?.title}");
    
    // You can show a local notification or handle the message accordingly here
  }

  // This function is triggered when the app is in the foreground
  static void init(BuildContext context) {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Foreground message handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a message in the foreground: ${message.notification?.title}");

      // Show a dialog or snackbar when receiving a message in the foreground
      if (message.notification != null) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(message.notification?.title ?? 'No Title'),
            content: Text(message.notification?.body ?? 'No Body'),
          ),
        );
      }
    });

    // Background message handler (when the app is terminated or in the background)
    FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

    // Get and handle the FCM token
    messaging.getToken().then((String? token) {
      print("FCM Token: $token");
      // You can save this token or send it to your backend for targeting specific users
    });
  }
}
