import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '/utils/Helper.dart';
import '../response/notificationOtpResponse.dart';

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> setupInteractedMessage() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // App opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print("PushNotificationService:: ${message.data}");
      _handleMessage(message.data);
    });

    // iOS-specific settings
    await _requestPermission();
    await _enableIOSNotifications();
    await _registerNotificationListeners();
    await getToken();
  }

  Future<void> getToken() async {
    try {
      String? token = await _messaging.getToken();
      print("FCM Token: $token");

      bool isSaved = await Helper.saveDeviceToken(token);
      print(isSaved ? 'Token saved successfully.' : 'Failed to save token.');
    } catch (e) {
      print('Error fetching token: $e');
    }
  }

  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Notification permission status: ${settings.authorizationStatus}');
  }

  Future<void> _enableIOSNotifications() async {
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerNotificationListeners() async {
    // Setup local notification initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings("notification");

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings();

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationClick(response.payload);
      },
    );

    // Create Android channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    print("Foreground message: ${message.data}");

    if (message.notification != null && message.notification!.android != null) {
      await _showNotification(message);
    }

    _handleMessage(message.data);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = notification?.android;

    if (notification != null && android != null) {
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title ?? "Notification",
        notification.body ?? "",
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android.smallIcon ?? "notification",
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  void _handleMessage(Map<String, dynamic> data) {
    try {
      final notificationResponse = NotificationOtpResponse.fromJson(data);
      print("_handleMessage :: ${notificationResponse.otp}");
      // You can add navigation or handling logic here
    } catch (e) {
      print("Error parsing message data: $e");
    }
  }

  void _handleNotificationClick(String? payload) {
    if (payload == null) return;

    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      final notificationResponse = NotificationOtpResponse.fromJson(data);
      print("_handleNotificationClick :: ${notificationResponse.otp}");
      // Handle user tapping notification
    } catch (e) {
      print("Error decoding payload: $e");
    }
  }
}
