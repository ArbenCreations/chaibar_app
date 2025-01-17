import 'dart:async';

import 'package:ChaatBar/utils/Helper.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../model/response/notificationOtpResponse.dart';

class SplashScreen extends StatefulWidget {
  final NotificationOtpResponse? data; // Define the 'data' parameter here

  SplashScreen({Key? key, this.data}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? token = "";
  final LocalAuthentication auth = LocalAuthentication();
  bool? isUserAuthenticated = false;
  int? vendorId ;
  // NotificationOtpResponse? notificationOtpResponse;

  @override
  void initState() {
    super.initState();
    _fetchToken();
    //notificationOtpResponse = widget.data;
    Helper.getUserAuthenticated().then((onValue) {
      isUserAuthenticated = onValue;
    });
    Helper.getVendorDetails().then((onValue) {
      vendorId = onValue?.id;
    });

  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Center(
              child: Image(
            height: screenHeight * 0.17,
            width: screenWidth * 0.75,
            image: AssetImage(
                isDarkMode ? "assets/app_logo.png" : "assets/app_logo.png"),
            fit: BoxFit.fill,
          )
              ),
        ),
      ),
    );
  }

  Future<void> _fetchToken() async {
    await Helper.saveUserAuthenticated(false);
    await Future.delayed(Duration(milliseconds: 2));
    token = await Helper.getUserToken();
    print(token);
    Timer(Duration(seconds: 2), () {
      _navigation();
    });
  }

  void _navigation() {
    if (token == null || token?.isEmpty == true) {
      Navigator.pushReplacementNamed(context, "/SignInScreen");
    } else {
      if(vendorId != null && vendorId != 0 ) {
        Navigator.pushReplacementNamed(context, "/BottomNav");
      }else{
        Navigator.pushReplacementNamed(context, "/VendorLocationScreen",arguments: "");
      }
    }
  }
}
