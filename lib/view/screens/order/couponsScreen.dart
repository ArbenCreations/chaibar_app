import 'package:ChaiBar/model/db/ChaiBarDB.dart';
import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../language/Languages.dart';
import '../../../model/request/getCouponListRequest.dart';
import '../../../model/response/couponListResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../theme/CustomAppColor.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/ShimmerList.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';

class CouponsScreen extends StatefulWidget {
  @override
  _CouponsScreenState createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  bool isLoading = false;
  bool isInternetConnected = true;
  bool isDarkMode = false;
  bool editProfile = false;
  late double mediaWidth;
  late double screenHeight;

  int? customerId = 0;

  static const maxDuration = Duration(seconds: 2);
  bool isDataLoading = false;
  late ChaiBarDB database;
  var _connectivityService = ConnectivityService();

  String? theme = "";
  String? vendorId = "";
  Color primaryColor = CustomAppColor.PrimaryAccent;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];
  List<PrivateCouponDetailsResponse>? couponsResponse;
  final GlobalKey _buttonKey = GlobalKey();
  bool mExpanded = false;
  String mSelectedText = "";
  final List<String> themeType = ["Light", "Dark", "Default"];
  final List<PrivateCouponDetailsResponse> couponsList = [];
  String selectedValue = "";

  @override
  void initState() {
    super.initState();
    Helper.getProfileDetails().then((onValue) {
      setState(() {
        customerId = int.parse("${onValue?.id ?? 0}"); //?? VendorData();
      });
    });

    Helper.getVendorDetails().then((onValue) {
      setState(() {
        vendorId = "${onValue?.id}";
      });
    });

    isDataLoading = true;
    _getCouponDetails();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    mediaWidth = MediaQuery.of(context).size.width;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 50,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          )),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
          title: Text(
            "Coupons",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          leading: SizedBox(),
        ),
        body: SafeArea(
          minimum: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Container(
            width: mediaWidth,
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  !isDataLoading && couponsList.length != 0
                      ? ListView.builder(
                          itemCount: couponsList.length ?? 0,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 10),
                          itemBuilder: (context, index) {
                            return newCouponWidget(couponsList[index]);
                          },
                        )
                      : !isDataLoading && couponsList.length == 0
                          ? Container(
                              height: screenHeight / 2,
                              child: Text(
                                "No Coupons Found",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              alignment: Alignment.center,
                            )
                          : ShimmerList(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget newCouponWidget(PrivateCouponDetailsResponse couponsResponse) {
    return CouponCard(
      height: 130,
      backgroundColor: CustomAppColor.PrimaryAccent.withOpacity(0.2),
      curvePosition: 80,
      curveRadius: 30,
      curveAxis: Axis.vertical,
      clockwise: true,
      borderRadius: 10,
      firstChild: Container(
        alignment: Alignment.center,
        color: CustomAppColor.ButtonBackColor.withOpacity(0.8),
        child: Text(
          "${couponsResponse.discount}% OFF",
          style: TextStyle(
              fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      secondChild: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 5),
          Text("Use code: ${couponsResponse.couponCode}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(
              "Valid until: ${convertDateTimeFormat("${couponsResponse.expireAt}")}",
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Min. Amount: ${couponsResponse.minCartAmt}",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
              Text("Max. Amount: ${couponsResponse.maxDiscountAmt}",
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Future<void> _getCouponDetails() async {
    if (!mounted) return;

    BuildContext currentContext = context; // Store context early

    bool isConnected = await _connectivityService.isConnected();
    print("isConnected - $isConnected");

    if (!isConnected) {
      if (mounted) {
        setState(() {
          isDataLoading = false;
          isInternetConnected = false;
        });

        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(
            content:
                Text(Languages.of(currentContext)!.labelNoInternetConnection),
            duration: maxDuration,
          ),
        );
      }
    } else {
      GetCouponListRequest request = GetCouponListRequest(
        vendorId: int.parse("$vendorId"),
        customerId: customerId,
      );

      await Provider.of<MainViewModel>(currentContext, listen: false)
          .fetchCouponList(
              "api/v1/app/customers/get_customer_coupons", request);

      if (mounted) {
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(currentContext, listen: false).response;
        getCouponResponse(currentContext, apiResponse);
      }
    }
  }

  Future<Widget> getCouponResponse(
      BuildContext context, ApiResponse apiResponse) async {
    CouponListResponse? coupons = apiResponse.data as CouponListResponse?;
    print("apiResponse${apiResponse.status}");
    setState(() {
      isDataLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        setState(() {
          coupons?.couponsResponse?.forEach((value) {
            couponsList.add(value);
          });
        });
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("Message : ${apiResponse.message}");
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong.'),
              duration: maxDuration,
            ),
          );
        }
        print(apiResponse.message);
        return Center(
          child: Text('Please try again later!!!'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }
}
