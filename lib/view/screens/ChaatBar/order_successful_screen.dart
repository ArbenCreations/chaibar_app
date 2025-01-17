import 'dart:async';
import 'dart:io';

import 'package:ChaatBar/theme/AppColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../model/response/rf_bite/createOrderResponse.dart';
import '../../../model/response/rf_bite/successCallbackResponse.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final SuccessCallbackResponse? data;

  OrderSuccessfulScreen({Key? key, this.data}) : super(key: key);
  @override
  _OrderSuccessfulScreenState createState() =>
      _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  bool isInternetConnected = true;
  bool isDarkMode = false;
  late double screenWidth;
  late double screenHeight;
  static const maxDuration = Duration(seconds: 2);
  bool isDataLoading = false;
  final TextEditingController documentNumberController =
  TextEditingController();
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
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
    _timer = Timer(Duration(seconds: 4), () {
      Navigator.pushNamed(context, "/BottomNav");
    });
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
    screenWidth = MediaQuery.of(context).size.width;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(

      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: AppColor.PRIMARY,
          statusBarIconBrightness: Brightness.light,
        ),
        child: GestureDetector(
          onTap: (){
            //Navigator.pushNamed(context, "/OrderOverviewScreen",arguments: widget.data);
          },
          child: Container(
            width: screenWidth,
            height: screenHeight,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 210,),
                   //Icon(Icons.check_circle, color: AppColor.PRIMARY,size: 70,),
                    Image(
                      height: 100,
                      image: AssetImage("assets/order_success.png" ),
                      fit: BoxFit.fill,
                    ),
                    SizedBox(height: 24,),
                    Text("THANK YOU!",style: TextStyle(fontSize: 32,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                    SizedBox(height: 26,),
                    Text("Order Number : #${widget.data?.order?.orderNumber}",style: TextStyle(fontSize: 16),textAlign: TextAlign.center,),
                    SizedBox(height: 12,),
                    Text("Your order is placed successfully, please go to order page to check status.",style: TextStyle(fontSize: 12),textAlign: TextAlign.center,),
                    Spacer(),
                    GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, "/BottomNav");
                      },
                      child: Container(
                        width: screenWidth*0.68,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                          color: AppColor.PRIMARY
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 25,vertical: 12),
                        child: Center(child: Text("Go To Home Screen",style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold),)),
                      ),
                    ),
                    SizedBox(height: 35,)
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
