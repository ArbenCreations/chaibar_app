import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../model/services/PushNotificationService.dart';
import '../../../utils/Helper.dart';

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
    _initializeWithTimeout();
  }

  Future<void> _initializeWithTimeout() async {
    try {
      final initFuture = _initializeApp();
      await initFuture.timeout(const Duration(seconds: 10));
    } catch (e) {
      print("Initialization timeout or error: $e");
      _navigate(); // fallback
    }
  }

  Future<void> _initializeApp() async {
    await PushNotificationService().setupInteractedMessage();

    final permissionStatus = await Permission.notification.status;
    if (permissionStatus.isDenied || permissionStatus.isRestricted) {
      await Permission.notification.request();
    }

    token = await Helper.getUserToken();
    final vendor = await Helper.getVendorDetails();
    vendorId = vendor?.id;

    await Future.delayed(const Duration(seconds: 3));
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
    var screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
            height: screenHeight,
            alignment: Alignment.center,
            child: Lottie.asset('assets/splash_anim.json')),
      ),
    );
  }
}
