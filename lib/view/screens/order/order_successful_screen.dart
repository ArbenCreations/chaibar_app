import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../model/response/successCallbackResponse.dart';
import '../../../model/response/createOrderResponse.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../component/GradientButton.dart';

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
  bool isDataLoading = false;
  final TextEditingController documentNumberController =
      TextEditingController();
  late AnimationController _controller;
  Timer? _timer;
  Uri _url = Uri.parse('https://thechaibar.ca/');
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    Helper.getVendorDetails().then((onValue) {
      setState(() {
        print("domainUrl${onValue?.domainUrl}");
        _url = Uri.parse(safeUrl(onValue?.domainUrl));
      });
    });
    Helper.getProfileDetails().then((profile) {
      setState(() {
        email = "${profile?.email}";
      });
    });

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Start from bottom
      end: Offset(0, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward(); // Start animation on screen load
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
    return PopScope(
      canPop: false, // Disable back navigation on this page
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        // Navigate to the home view when back navigation is attempted
        Navigator.pushReplacementNamed(context, "/BottomNavigation",
            arguments: 1);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            "Thank You",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          leading: IconButton(icon : Icon(Icons.arrow_back_ios, size: 18,),
          onPressed: (){
            Navigator.pushNamed(
                context, "/BottomNavigation",
                arguments: 1);
          },),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: SafeArea(
              top: true,
              child: SizedBox(
                width: mediaWidth,
                height: screenHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ClipOval(
                          child: Container(
                            color: Color(0xFFF18301).withOpacity(0.1),
                            child: Lottie.asset(
                              'assets/order_success.json',
                              height: 150,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    //if (widget.orderData?.order?.totalPrice != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "\$${widget.orderData?.order?.totalAmount ?? "0.0"}",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      ),
                    Text(
                      "Congratulations! 🎉",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Your order has been placed",
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    //if (widget.orderData?.order?.orderNo != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "Order ID: ${widget.orderData?.order?.orderNo}",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        "A confirmation email has been sent.",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (widget.pointsEarned != null)
                      Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade50,
                                Colors.green.shade100
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Icon container
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Icon(Icons.stars_rounded,
                                    size: 24, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              // Text section
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Earned Points!",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "You've earned ${widget.pointsEarned} reward points!",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.green.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 30),

                    GradientButton(
                      text: "Share Your Feedback",
                      onPressed: _launchUrl,
                      icon: Icons.feedback_outlined,
                      gradientColors: [
                        Color(0xFFF18301), // Your primary
                        Color(0xFFF18301), // Pink-red pop
                      ],
                    ),

                    const SizedBox(height: 16),

                    GradientButton(
                      text: "Track Your Order",
                      onPressed: () => Navigator.pushNamed(
                          context, "/BottomNavigation",
                          arguments: 0),
                      icon: Icons.art_track,
                      gradientColors: [
                        Color(0xFFF18301), // Your primary
                        Color(0xFFFF416C), // Pink-red pop
                      ],
                    ),

                    const SizedBox(height: 16),

                    GradientButton(
                      text: "Continue Shopping",
                      onPressed: () => Navigator.pushNamed(
                          context, "/BottomNavigation",
                          arguments: 1),
                      icon: Icons.shopping_bag_outlined,
                      gradientColors: [
                        Color(0xFFF18301), // Your primary
                        Color(0xFFFF416C), // Pink-red pop
                      ],
                    ),

                    const SizedBox(height: 35),
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
