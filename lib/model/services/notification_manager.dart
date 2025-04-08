/*
import 'dart:async';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'notification_entity.dart';

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  final StreamController<String?> selectNotificationSubject =
      StreamController<String?>();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: null,
    );

  */
/*  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
      debugPrint("payload ==> ${notificationResponse.payload.toString()}");

      NotificationEntity? notificationEntity = DbHelper()
          .convertStringToNotificationEntity(notificationResponse.payload);

      pushNextScreenFromForeground(notificationEntity!);

      if (notificationResponse.payload != null) {
        debugPrint('notification payload: ${notificationResponse.payload}');
      }
      selectNotificationSubject.add(notificationResponse.payload);
    });*//*


    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    String deviceToken = await FirebaseMessaging.instance.getToken() ?? "";
    debugPrint("fcm Token = $deviceToken");
    _configureSelectNotificationSubject();

    initFirebaseListeners();
  }

 */
/* void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      NotificationEntity? entity =
          DbHelper().convertStringToNotificationEntity(payload);
      debugPrint(
          "notification _configureSelectNotificationSubject ${entity.toString()}");
      if (entity != null) {
        pushNextScreenFromForeground(entity);
      }
    });
  }
*//*

*/
/*
  Future? onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    if (DbHelper.getToken() == null) {
      return null;
    }

    debugPrint(payload.toString());
    NotificationEntity? entity =
        DbHelper().convertStringToNotificationEntity(payload);
    print("NotificationEntity====>>>${entity?.toJson()}");
    debugPrint(
        "notification onDidReceiveLocalNotification ${entity.toString()}");
    if (entity != null) {
      pushNextScreenFromForeground(entity);
    }
    return null;
  }
*//*


  void initFirebaseListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint(
          "Foreground notification received  ${message.notification?.body}");
      debugPrint("Foreground message data ${message.notification?.body}");
      DbHelper.getUserType() == "0"
          ? Get.put(HomeController()).isReadNotification.value = true
          : Get.put(VendorHomeController()).isReadNotification.value = true;
      if (GetPlatform.isIOS || DbHelper.getToken() == null) {
        return;
      }

      NotificationEntity notificationEntity =
          NotificationEntity.fromJson(message.data);

      debugPrint(message.data.toString());
      notificationEntity.title = notificationEntity.title ?? "Party Plans";
      notificationEntity.body = notificationEntity.body;
      showNotifications(NotificationEntity.fromJson(message.data));
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      pushNextScreenFromForeground(NotificationEntity.fromJson(message.data));
    });
  }

  Future<void> showNotifications(NotificationEntity notificationEntity) async {
    Random random = Random();
    int id = random.nextInt(900) + 10;
    await flutterLocalNotificationsPlugin.show(
        id,
        notificationEntity.title,
        notificationEntity.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: "@mipmap/ic_launcher",
              channelShowBadge: true,
              color: AppColor.themeColor,
              playSound: true,
              priority: Priority.high,
              importance: Importance.high,
              styleInformation:
                  BigTextStyleInformation(notificationEntity.body ?? ""),
            ),
            iOS: const DarwinNotificationDetails(
              categoryIdentifier: 'plainCategory',
            )),
        payload:
            DbHelper().convertNotificationEntityToString(notificationEntity));
  }

  void pushNextScreenFromForeground(
      NotificationEntity notificationEntity) async {
    debugPrint(notificationEntity.toJson().toString());

    print("CHeck Push Type ========>${notificationEntity.type}");
    print("CHeck Push Type =user Type=======>${DbHelper.getUser()?.role}");
    print("CHeck Push Type =user Type====dddddd===>${DbHelper.getUserType()}");
    final String type = notificationEntity.type;

    switch (type) {
      case "1":
        _handleChatNotification(notificationEntity);
        break;
      case "2":
        _handleVendorIndexNotification(notificationEntity);
        break;
      case "3":
        _handleJobDetailNotification(notificationEntity);
        break;
      case "4":
        _handlePostedJobsNotification(notificationEntity);
        break;
      case "6":
        _handleSpecificNotification(notificationEntity);
        break;
      case "7":
        _handlePaymentNotification(notificationEntity);
        break;
      case "8":
        _handleSpecificNotification(notificationEntity);
        break;
      default:
        _navigateToNotificationView();
    }
  }

  void _handleChatNotification(NotificationEntity notificationEntity) {
    final Map<String, dynamic> userId = {
      "receiverId": int.parse(notificationEntity.senderId),
      "receiverName": notificationEntity.senderName,
      "receiverImage": notificationEntity.senderImage,
    };

    Get.put(ChatController()).destroyActiveChat(1);
    if (Get.currentRoute == AppRoutes.chatView) {
      Get.back();
    }
    Get.toNamed(AppRoutes.chatView, arguments: userId);
  }

  Future<void> _handleVendorIndexNotification(
      NotificationEntity notificationEntity) async {
    if (Get.currentRoute == AppRoutes.vendorPostedJobDetailView) {
      Get.back();
      Get.toNamed(AppRoutes.vendorPostedJobDetailView,
          arguments: {"from": 1, "id": notificationEntity.jobId.toString()});
    } else {
      Get.toNamed(AppRoutes.vendorPostedJobDetailView,
          arguments: {"from": 1, "id": notificationEntity.jobId.toString()});
    }
  }

  void _handleJobDetailNotification(NotificationEntity notificationEntity) {
    final Map<String, dynamic> dataId = {
      "id": int.parse(notificationEntity.jobId),
    };
    print("jobId=====${notificationEntity.jobId}");

    if (DbHelper.getUserType() == "0") {
      if (Get.currentRoute == AppRoutes.detailView) {
        Get.back();
      }
      Get.put(DetailController()).ownerHomeDetailApi(dataId["id"]);
      Get.toNamed(AppRoutes.detailView, arguments: dataId);
    } else {
      if (Get.currentRoute == AppRoutes.postedJobDetailView) {
        Get.back();
        Get.toNamed(AppRoutes.postedJobDetailView,
            arguments: {"from": 1, "id": notificationEntity.jobId});
      } else {
        Get.toNamed(AppRoutes.postedJobDetailView,
            arguments: {"from": 1, "id": notificationEntity.jobId});
      }
    }
  }

  void _handlePostedJobsNotification(NotificationEntity notificationEntity) {
    if (DbHelper.getUserType() == "1") {
      if (Get.currentRoute == AppRoutes.vendorPostedJobDetailView) {
        Get.back();
        Get.toNamed(AppRoutes.vendorPostedJobDetailView,
            arguments: {"from": 4, "id": notificationEntity.jobId.toString()});
      } else {
        Get.toNamed(AppRoutes.vendorPostedJobDetailView,
            arguments: {"from": 4, "id": notificationEntity.jobId.toString()});
      }
    }
  }

  void _handleSpecificNotification(NotificationEntity notificationEntity) {
    if (DbHelper.getUserType() == "0") {
      if (Get.currentRoute == AppRoutes.postedJobDetailView) {
        Get.back();
        Get.toNamed(AppRoutes.postedJobDetailView,
            arguments: {"from": 1, "id": notificationEntity.jobId});
      } else {
        Get.toNamed(AppRoutes.postedJobDetailView,
            arguments: {"from": 1, "id": notificationEntity.jobId});
      }
    } else {
      if (Get.currentRoute == AppRoutes.vendorPostedJobDetailView) {
        Get.back();
        Get.toNamed(AppRoutes.vendorPostedJobDetailView,
            arguments: {"from": 2, "id": notificationEntity.jobId.toString()});
      } else {
        Get.toNamed(AppRoutes.vendorPostedJobDetailView,
            arguments: {"from": 2, "id": notificationEntity.jobId.toString()});
      }
    }
  }

  void _handlePaymentNotification(NotificationEntity notificationEntity) {
    if (Get.currentRoute == AppRoutes.vendorPostedJobDetailView) {
      Get.back();
      Get.toNamed(AppRoutes.vendorPostedJobDetailView,
          arguments: {"from": 1, "id": notificationEntity.jobId});
    } else {
      Get.toNamed(AppRoutes.vendorPostedJobDetailView,
          arguments: {"from": 1, "id": notificationEntity.jobId});
    }
  }

  void _navigateToNotificationView() {
    Get.toNamed(AppRoutes.notificationView);
  }
}
*/
