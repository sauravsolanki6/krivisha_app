import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as lg;

class NotificationServices {
  String? callId;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterlocalnotificationplugin =
      FlutterLocalNotificationsPlugin();

  // Initialize local notifications (called once, preferably at app startup)
  Future<void> initLocalNotifications(BuildContext context) async {
    try {
      const androidInitialization =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInitialization = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: androidInitialization,
        iOS: iosInitialization,
      );

      await flutterlocalnotificationplugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          // Handle notification tap (e.g., navigate to a specific screen)
          lg.log("Notification tapped: ${response.payload}");
        },
      );
    } catch (e) {
      lg.log("Error initializing local notifications: $e");
    }
  }

  // Listen for foreground FCM messages and handle them
  void firebaseInit(BuildContext context) {
    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Print the entire message for debugging
        lg.log("FCM Message Received: ${message.toMap()}");
        lg.log(
            "Notification Title: ${message.notification?.title ?? message.data['title']}");
        lg.log(
            "Notification Body: ${message.notification?.body ?? message.data['body']}");
        lg.log("Data Payload: ${message.data}");

        // Show local notification
        showNotification(message);
      });
    } catch (e) {
      lg.log("Error in firebaseInit: $e");
    }
  }

  // Display a local notification for the received FCM message
  Future<void> showNotification(RemoteMessage message) async {
    try {
      final channel = AndroidNotificationChannel(
        Random().nextInt(100000).toString(), // Unique channel ID
        'Text Channel', // Channel name
        description: 'Your channel description',
        importance: Importance.high,
      );

      const darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          styleInformation: const BigTextStyleInformation(''),
          ticker: 'ticker',
        ),
        iOS: darwinNotificationDetails,
      );

      // Fetch title and body, prioritizing notification fields
      final String? title =
          message.notification?.title ?? message.data['title'];
      final String? body = message.notification?.body ?? message.data['body'];

      // Display the notification if title or body is not null
      if (title != null || body != null) {
        await flutterlocalnotificationplugin.show(
          Random().nextInt(100000), // Unique notification ID
          title ?? "No Title",
          body ?? "No Body",
          notificationDetails,
          payload:
              message.data['payload'], // Optional: pass data for tap handling
        );
        lg.log("Local notification displayed: Title=$title, Body=$body");
      } else {
        lg.log("No title or body found, skipping notification");
      }
    } catch (e) {
      lg.log("Error showing notification: $e");
    }
  }

  // Request notification permissions
  Future<void> requestNotificationPermission() async {
    try {
      NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        sound: true,
      );

      lg.log("Notification permission status: ${settings.authorizationStatus}");
    } catch (e) {
      lg.log("Error requesting notification permission: $e");
    }
  }

  // Get FCM device token
  Future<String> getDeviceToken() async {
    try {
      String? token = await firebaseMessaging.getToken();
      lg.log("FCM Token: $token");
      return token ?? "";
    } catch (e) {
      lg.log("Error getting device token: $e");
      return "";
    }
  }

  // Handle token refresh
  void isTokenRefresh() {
    try {
      firebaseMessaging.onTokenRefresh.listen((token) {
        lg.log("FCM Token Refreshed: $token");
      });
    } catch (e) {
      lg.log("Error in token refresh: $e");
    }
  }
}
