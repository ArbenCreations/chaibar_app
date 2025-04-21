import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../model/services/PushNotificationService.dart';
import '../../../utils/Helper.dart';

late AndroidNotificationChannel channel;
late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isFlutterLocalNotificationsInitialized = false;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await setupFlutterNotifications();
  print('Handling a background message ${message.messageId}');
}

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) return;

  channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  isFlutterLocalNotificationsInitialized = true;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? token;
  int? vendorId;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await FirebaseMessaging.instance.getInitialMessage();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await setupFlutterNotifications();
    await PushNotificationService().setupInteractedMessage();

    final permissionStatus = await Permission.notification.status;
    if (permissionStatus.isDenied) {
      await Permission.notification.request();
    }

    token = await Helper.getUserToken();
    final vendor = await Helper.getVendorDetails();
    vendorId = vendor?.id;

    await Future.delayed(const Duration(seconds: 1));
    _navigate();
  }

  void _navigate() {
    if (token == null || token!.isEmpty) {
      Navigator.pushReplacementNamed(context, "/GetStartedScreen");
    } else if (vendorId != null && vendorId != 0) {
      Navigator.pushReplacementNamed(context, "/BottomNavigation",
          arguments: 1);
    } else {
      Navigator.pushReplacementNamed(context, "/VendorsListScreen",
          arguments: "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage("assets/app_logo.png"),
          width: 200,
        ),
      ),
    );
  }
}
