import 'dart:async';

import '/utils/Helper.dart';
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
  int? vendorId;

  // NotificationOtpResponse? notificationOtpResponse;

  @override
  void initState() {
    super.initState();
    _fetchToken();
    //notificationOtpResponse = widget.data;
    Helper.getVendorDetails().then((onValue) {
      if (onValue != null) {
        vendorId = onValue.id;
      } else {
        print("Error: Vendor details are null");
      }
    }).catchError((error) {
      print("Error fetching vendor details: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double screenHeight = MediaQuery.of(context).size.height;
    double mediaWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () {},
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Center(
              child: Image(
            height: screenHeight * 0.1,
            width: mediaWidth * 0.55,
            image: AssetImage(
                isDarkMode ? "assets/app_logo.png" : "assets/app_logo.png"),
            fit: BoxFit.fill,
          )),
        ),
      ),
    );
  }

  Future<void>  _fetchToken() async {
    Helper.getUserToken().then((deviceToken) {
      setState(() {
        token = deviceToken;
      });
    });
    print("Token${token}");
    Timer(Duration(seconds: 2), () {
      _navigation();
    });
  }

  void _navigation() {
    if (token == null || token?.isEmpty == true) {
      Navigator.pushReplacementNamed(context, "/GetStartedScreen");
    } else {
      if (vendorId != null && vendorId != 0) {
        Navigator.pushReplacementNamed(context, "/BottomNavigation", arguments: 1);
      } else {
        Navigator.pushReplacementNamed(context, "/VendorsListScreen",
            arguments: "");
      }
    }
  }
}
