import 'dart:async';

import 'package:ChaiBar/theme/CustomAppColor.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../model/response/successCallbackResponse.dart';
import '../../../model/response/createOrderResponse.dart';
import '../../../utils/Helper.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final SuccessCallbackResponse? data;
  final CreateOrderResponse? orderData;
  final String? pointsEarned;

  OrderSuccessfulScreen(
      {Key? key, this.data, this.orderData, this.pointsEarned})
      : super(key: key);

  @override
  _OrderSuccessfulScreenState createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool isInternetConnected = true;
  String email = "";
  bool isDarkMode = false;
  late double mediaWidth;
  late double screenHeight;
  static const maxDuration = Duration(seconds: 2);
  bool isDataLoading = false;
  final TextEditingController documentNumberController =
      TextEditingController();
  late AnimationController _controller;
  Timer? _timer;
  Uri _url = Uri.parse('');

  @override
  void initState() {
    super.initState();

    Helper.getVendorDetails().then((onValue) {
      setState(() {
        print("domainUrl${onValue?.domainUrl}");
        _url = Uri.parse("${onValue?.domainUrl ?? "https://thechaibar.ca/"}");
        //setThemeColor();
      });
    });
    Helper.getProfileDetails().then((profile) {
      setState(() {
        email = "${profile?.email}";
        //setThemeColor();
      });
    });

    /* _controller = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );*/

/*    _slideAnimation = Tween<Offset>(begin: Offset(0, 1.0), end: Offset(0, 0)).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Define the opacity animation for fade effect
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();*/
    /*_timer = Timer(Duration(seconds: 4), () {
      Navigator.pushNamed(context, "/BottomNavigation");
    });*/
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    mediaWidth = MediaQuery.of(context).size.width;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          //Navigator.pushNamed(context, "/OrderOverviewScreen",arguments: widget.data);
        },
        child: SingleChildScrollView(
          child: Container(
            width: mediaWidth,
            height: screenHeight,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 100,
                    ),
                    Text(
                      "Order Placed",
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Image(
                      height: screenHeight * 0.25,
                      image: AssetImage("assets/payment_done.gif"),
                      fit: BoxFit.fill,
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Text(
                      "Thank you for your Order",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    widget.orderData?.order?.orderNo != null
                        ? Text(
                            "Order Number : ${widget.orderData?.order?.orderNo}",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54),
                            textAlign: TextAlign.center,
                          )
                        : SizedBox(),
                    widget.pointsEarned != null
                        ? IntrinsicWidth(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 14),
                              margin: EdgeInsets.symmetric(vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  border: Border.all(
                                      width: 0.1, color: Colors.green.shade100,),
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.control_point_duplicate_sharp,
                                    color: Colors.green,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6,),
                                  Text(
                                    "You have earned ${widget.pointsEarned} reward points",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 12,
                    ),
                    SizedBox(
                      width: mediaWidth * 0.8,
                      child: Text(
                        "Your order has now been placed and you will shortly receive email confirmation to $email. You can check the status of your order at any time by going to 'Orders'",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    GestureDetector(
                      onTap: () {
                        _launchUrl();
                      },
                      child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4)),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(
                            "Please Share your feedback",
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            textAlign: TextAlign.center,
                          )),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/BottomNavigation", arguments: 0);
                      },
                      child: Container(
                        width: mediaWidth * 0.5,
                        decoration: BoxDecoration(
                            color: CustomAppColor.PrimaryAccent,
                            borderRadius: BorderRadius.circular(6)),
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        child: Center(
                            child: Column(
                          children: [
                            Text(
                              "Track your order",
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            )
                          ],
                        )),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, "/BottomNavigation", arguments: 1);
                      },
                      child: Container(
                        width: mediaWidth * 0.68,
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        child: Center(
                            child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  size: 18,
                                ),
                                SizedBox(
                                  width: 4,
                                ),
                                Text(
                                  "Go To Home Screen",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                            Container(
                              width: mediaWidth / 2.9,
                              height: 0.5,
                              decoration: BoxDecoration(
                                color: Colors.black,
                              ),
                            )
                          ],
                        )),
                      ),
                    ),
                    SizedBox(
                      height: 35,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
