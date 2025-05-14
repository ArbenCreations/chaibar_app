import 'dart:convert';

import 'package:coupon_uikit/coupon_uikit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '/model/request/CreateOrderRequest.dart';
import '/model/request/getCouponDetailsRequest.dart';
import '/model/response/createOrderResponse.dart';
import '/model/response/getCouponDetailsResponse.dart';
import '/model/response/productListResponse.dart';
import '/theme/CustomAppColor.dart';
import '/utils/Util.dart';
import '/view/component/cart_product_component.dart';
import '../../../language/Languages.dart';
import '../../../model/db/dataBaseDao.dart';
import '../../../model/db/db_service.dart';
import '../../../model/request/getCouponListRequest.dart';
import '../../../model/request/getRewardPointsRequest.dart';
import '../../../model/response/couponListResponse.dart';
import '../../../model/response/getRewardPointsResponse.dart';
import '../../../model/response/getViewRewardPointsResponse.dart';
import '../../../model/response/productDataDB.dart';
import '../../../model/response/storeStatusResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../utils/Helper.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomAlert.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/DashedLine.dart';
import '../../component/connectivity_service.dart';
import '../../component/custom_circular_progress.dart';
import '../../component/session_expired_dialog.dart';

class MyCartScreen extends StatefulWidget {
  MyCartScreen();

  @override
  _MyCartScreenState createState() => _MyCartScreenState();
}

class _MyCartScreenState extends State<MyCartScreen> {
  late double mediaWidth;
  late double screenHeight;
  bool isDarkMode = false;
  late CartDataDao cartDataDao;
  late FavoritesDataDao favoritesDataDao;
  late CategoryDataDao categoryDataDao;
  late ProductsDataDao productsDataDao;
  late DashboardDao dashboardDao;
  List<ProductData?> cartList = [];
  int? discountPercent = 0;
  late int vendorId;
  int gst = 0;
  double redeemAmount = 0;
  int hst = 0;
  int pst = 0;
  double grandTotal = 0;
  double totalPrice = 0;
  double afterDiscountAmount = 0;
  double taxAmount = 0;
  double gstTaxAmount = 0;
  double pstTaxAmount = 0;
  double hstTaxAmount = 0;
  double discountAmount = 0;
  bool isB1G1 = false;
  bool isLoading = false;
  bool isCouponApplied = false;
  bool isStoreOnline = true;
  bool IsUpcomingAllowed = true;

  String appId = "";
  String apiKey = "";
  String? theme = "";
  String? userId = "";
  String? firstName = "";
  String? lastName = "";
  String? phoneNo = "";
  String? email = "";
  String? pickupDate = "";
  String? pickupTime = "";
  String? storeStatus = "online";
  CouponDetailsResponse? couponDetails = CouponDetailsResponse();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final List<PrivateCouponDetailsResponse> couponsList = [];
  Color primaryColor = CustomAppColor.Primary;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];
  bool isDataLoading = false;
  int? customerId = 0;
  int rewardPoints = 0;
  int actualRewardPoints = 0;
  bool isInternetConnected = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isStoreOnline= true;
      pickupDate = "${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
      pickupTime =
          "${DateFormat('hh:mm a').format(DateTime.now().add(Duration(minutes: 20)))}";
    });
    Helper.getVendorDetails().then((data) {
      setState(() {
        vendorId = int.parse("${data?.id}");
        storeStatus = data?.status ?? "online";
        isStoreOnline = true;
      });
    });
    Helper.getAddress().then((value) {
      setState(() {
        if (value != null) _addressController.text = "$value";
      });
    });

    Helper.getProfileDetails().then((onValue) {
      setState(() {
        customerId = int.parse("${onValue?.id ?? 0}");
        rewardPoints = int.parse("${onValue?.totalPoints ?? 0}");
        actualRewardPoints = int.parse("${onValue?.totalPoints ?? 0}");
      });
    });
    _getCouponDetails();
    _getRedeemPointsData();

    Helper.getStoreSettingDetails().then((data) {
      setState(() {
        gst = int.parse("${data?.gst ?? 5}");
        pst = int.parse("${data?.pst ?? 0}");
        hst = int.parse("${data?.hst ?? 0}");
        IsUpcomingAllowed = data?.upcomingOrReserveDay ?? false;
      });
    });
    Helper.getApiKey().then((data) {
      setState(() {
        apiKey = "12c12489-fc5f-253d-af89-270d4b68b87e"; //"${data ?? ""}";
      });
    });
    Helper.getProfileDetails().then((profileDetails) {
      setState(() {
        firstName = profileDetails?.firstName;
        userId = "${profileDetails?.id}";
        lastName = profileDetails?.lastName;
        phoneNo = profileDetails?.phoneNumber;
        email = profileDetails?.email;
      });
    });
    initializeDatabase();
    _fetchStoreStatus(false);
  }

  Widget getCreateOrderResponse(BuildContext context, ApiResponse apiResponse) {
    CreateOrderResponse? createOrderResponse =
        apiResponse.data as CreateOrderResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("redeemAmount ${redeemAmount}");
        print("actualRewardPoints ${actualRewardPoints}");
        createOrderResponse?.order?.redeemPoints = "${rewardPoints}";
        Navigator.pushNamed(
          context,
          "/PaymentCardScreen",
          arguments: {
            "data": "",
            'rewardPoints': "${redeemAmount > 0 ? actualRewardPoints : 0.0}",
            'orderData': createOrderResponse
          },
        );
        return Container();
      case Status.ERROR:
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

  @override
  Widget build(BuildContext context) {
    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, "/BottomNavigation",
            arguments: 1);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          forceMaterialTransparency: false,
          centerTitle: false,
          backgroundColor: CustomAppColor.PrimaryAccent,
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
          title: Text(
            firstName == null && firstName?.isEmpty == true
                ? 'Check out'
                : "${firstName?.toUpperCase()} ${lastName?.toUpperCase()}",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          leading: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/BottomNavigation", arguments: 1);
              },
              child: Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
              )),
          actions: [
            GestureDetector(
              onTap: () {
                cartDataDao.clearAllCartProduct();
                getCartData();
                getCartTotal();
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                margin: EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.remove_shopping_cart_outlined,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Clear Cart",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: cartList.length > 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: screenHeight * 0.2,
                                maxHeight: cartList.length > 3
                                    ? screenHeight * 0.4
                                    : screenHeight * 0.3),
                            child: Container(
                              child: SingleChildScrollView(
                                child: cartList.length > 0
                                    ? SizedBox(
                                        height: cartList.length > 3
                                            ? screenHeight * 0.4
                                            : screenHeight * 0.3,
                                        // Set an appropriate height
                                        child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: cartList.length,
                                          itemBuilder: (context, index) {
                                            final item = cartList[index];

                                            // Calculate item prices
                                            List<ProductSize> productSize = [];
                                            if (item?.productSizesList !=
                                                "[]") {
                                              productSize =
                                                  item?.getProductSizeList() ??
                                                      [];
                                            }

                                            double itemTotalPrice = 0;
                                            double addOnTotalPrice = 0;

                                            if (item?.isBuy1Get1 == true) {
                                              itemTotalPrice = (double.parse(
                                                          "${item?.quantity}") /
                                                      2) *
                                                  double.parse(
                                                      "${item?.price}");
                                              item
                                                  ?.getAddOnList()
                                                  .forEach((addOnCategory) {
                                                addOnCategory.addOns
                                                    ?.forEach((addOn) {
                                                  addOnTotalPrice +=
                                                      double.parse(
                                                          "${addOn.price}");
                                                });
                                              });
                                              addOnTotalPrice *= (double.parse(
                                                      "${item?.quantity}") /
                                                  2);
                                            } else {
                                              itemTotalPrice = double.parse(
                                                      "${item?.quantity}") *
                                                  double.parse(
                                                      "${item?.price}");
                                              item
                                                  ?.getAddOnList()
                                                  .forEach((addOnCategory) {
                                                addOnCategory.addOns
                                                    ?.forEach((addOn) {
                                                  addOnTotalPrice +=
                                                      double.parse(
                                                          "${addOn.price}");
                                                });
                                              });
                                              addOnTotalPrice *= double.parse(
                                                  "${item?.quantity}");
                                            }

                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6.0,
                                                      vertical: 4),
                                              child: CartProductComponent(
                                                item: item ??
                                                    ProductData(quantity: 0),
                                                mediaWidth: mediaWidth,
                                                isDarkMode: isDarkMode,
                                                itemTotalPrice: itemTotalPrice,
                                                addOnTotalPrice:
                                                    addOnTotalPrice,
                                                screenHeight: screenHeight,
                                                primaryColor: primaryColor,
                                                onAddTap: () {
                                                  setState(() {
                                                    /*if (item?.addOn?.isEmpty ==
                                                            true ||
                                                        item?.addOn == "[]" ||
                                                        item?.addOn == null) {*/
                                                    if (item?.isBuy1Get1 ==
                                                        false) {
                                                      if (int.parse(
                                                                "${item?.quantity}") <
                                                            int.parse(
                                                                "${item?.qtyLimit}")) {
                                                          item?.quantity++;
                                                          addProductInDb(item
                                                              as ProductData);
                                                        }
                                                      } else {
                                                        if (int.parse(
                                                                "${item?.quantity}") <
                                                            2 *
                                                                int.parse(
                                                                    "${item?.qtyLimit}")) {
                                                          item?.quantity =
                                                              int.parse(
                                                                      "${item.quantity}") +
                                                                  2;
                                                          addProductInDb(item
                                                              as ProductData);
                                                        }
                                                      }
                                                    //}
                                                    /*else {
                                                      Navigator.pushNamed(
                                                          context,
                                                          "/ProductDetailScreen",
                                                          arguments: item);
                                                    }*/
                                                  });
                                                },
                                                onMinusTap: () {
                                                  setState(() {
                                                    /* if (item?.addOn?.isEmpty ==
                                                            true ||
                                                        item?.addOn == "[]" ||
                                                        item?.addOn == null) {*/
                                                    if (item?.isBuy1Get1 ==
                                                        false) {
                                                      if (int.parse(
                                                                    "${item?.quantity}") <=
                                                                int.parse(
                                                                    "${item?.qtyLimit}") &&
                                                            int.parse(
                                                                    "${item?.quantity}") >
                                                                0) {
                                                          item?.quantity--;
                                                          deleteProductInDb(
                                                              item);
                                                        }
                                                      } else {
                                                        if (int.parse(
                                                                    "${item?.quantity}") <=
                                                                2 *
                                                                    int.parse(
                                                                        "${item?.qtyLimit}") &&
                                                            int.parse(
                                                                    "${item?.quantity}") >
                                                                1) {
                                                          item?.quantity =
                                                              int.parse(
                                                                      "${item.quantity}") -
                                                                  2;
                                                          deleteProductInDb(
                                                              item);
                                                        }
                                                      }
                                                    /*  } else {
                                                      Navigator.pushNamed(
                                                          context,
                                                          "/ProductDetailScreen",
                                                          arguments: item);
                                                    }*/
                                                  });
                                                },
                                                onRemoveTap: () {
                                                  if (int.parse(
                                                          "${item?.quantity}") >
                                                      0) {
                                                    setState(() {
                                                      cartList.remove(
                                                          item); // Remove the item from the list
                                                      item?.quantity = 0;
                                                      if (productSize
                                                          .isNotEmpty) {
                                                        for (var size
                                                            in productSize) {
                                                          size.quantity = 0;
                                                        }
                                                        item?.productSizesList =
                                                            jsonEncode(
                                                                productSize);
                                                      }
                                                    });
                                                    deleteProductInDb(item);
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        height: screenHeight * 0.29,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Add item to cart",
                                          style: TextStyle(color: Colors.grey),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, "/BottomNavigation",
                                    arguments: 1);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 4),
                                margin: EdgeInsets.only(right: 15, bottom: 10),
                                width: mediaWidth * 0.26,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 14,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      "Add items",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          cartList.length > 0
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 2.0),
                                  child: isCouponApplied
                                      ? appliedCouponWidget()
                                      : GestureDetector(
                                          onTap: () async => {
                                            if (_couponController
                                                .text.isNotEmpty)
                                              {
                                                _fetchCouponData(
                                                    "${_couponController.text}",
                                                    false)
                                              }
                                            else
                                              {
                                                /*  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(SnackBar(
                                      content: Text(
                                        "Please Enter Promo Code",
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                      duration: Duration(seconds: 2),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Colors.black87,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      action: SnackBarAction(
                                        label: 'OK',
                                        textColor: Colors.white,
                                        onPressed: () {
                                          // Optional: Add logic here if needed
                                        },
                                      ),
                                    ))*/
                                                CustomSnackBar.showSnackbar(
                                                    context: context,
                                                    message:
                                                        "Please Enter Promo Code",
                                                    duration: maxDuration)
                                              }
                                          },
                                          child: Container(
                                            height: 45,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(30)),
                                            width: mediaWidth * 0.9,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: mediaWidth / 1.65,
                                                  height: 40,
                                                  padding:
                                                      EdgeInsets.only(left: 10),
                                                  decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              30)),
                                                  child: TextField(
                                                    style: TextStyle(
                                                      fontSize: 12.0,
                                                    ),
                                                    obscureText: false,
                                                    obscuringCharacter: "*",
                                                    controller:
                                                        _couponController,
                                                    onChanged: (value) {
                                                      // _isValidInput();
                                                    },
                                                    onSubmitted: (value) {},
                                                    keyboardType: TextInputType
                                                        .visiblePassword,
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    decoration: InputDecoration(
                                                        prefixIcon: Icon(
                                                          Icons.card_giftcard,
                                                          color: Colors.black54,
                                                          size: 22,
                                                        ),
                                                        focusedBorder:
                                                            InputBorder.none,
                                                        border:
                                                            InputBorder.none,
                                                        hintText: "Promo Code",
                                                        hintStyle: TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 13)),
                                                  ),
                                                ),
                                                Container(
                                                  height: 40,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: CustomAppColor
                                                        .PrimaryAccent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    //color: Colors.red[100]
                                                  ),
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 30),
                                                  child: Text(
                                                    "Apply",
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 11),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                )
                              : SizedBox(),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            alignment: Alignment.bottomCenter,
                            decoration: BoxDecoration(
                                color: CustomAppColor.Background,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(20),
                                    topLeft: Radius.circular(20))),
                            child: Column(
                              children: [
                                DashedLine(width: mediaWidth, height: 1.0),
                                Container(
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      if (IsUpcomingAllowed)
                                        GestureDetector(
                                          onTap: () => _selectDateTime(context),
                                          child: Card(
                                            elevation: 0,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 0, horizontal: 0),
                                            shape: Border(
                                                bottom:
                                                    BorderSide(width: 0.01)),
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 4),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 5),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 15),
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .access_time_rounded,
                                                              color: CustomAppColor
                                                                  .PrimaryAccent,
                                                              size: 14,
                                                            ),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              "Pickup Time",
                                                              maxLines: 2,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500),
                                                            ),
                                                          ],
                                                        )),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 5),
                                                    child: Center(
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            "$pickupDate $pickupTime ",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13),
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .arrow_drop_down_sharp,
                                                            color: CustomAppColor
                                                                .PrimaryAccent,
                                                            size: 22,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        SizedBox(),
                                      GestureDetector(
                                        onTap: () => _showNotesDialog(),
                                        child: Card(
                                          elevation: 0,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                          shape: Border(
                                              bottom: BorderSide(width: 0.01)),
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(bottom: 4),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                      padding: EdgeInsets.only(
                                                          left: 15),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .note_alt_rounded,
                                                            color: CustomAppColor
                                                                .PrimaryAccent,
                                                            size: 14,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            "Add Notes (Optional)",
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 6),
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: CustomAppColor
                                                        .PrimaryAccent,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showCouponBottomSheet(context);
                                        },
                                        child: Card(
                                          elevation: 0,
                                          shape: Border(
                                              bottom: BorderSide(width: 0.01)),
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.local_offer,
                                                            color: CustomAppColor
                                                                .PrimaryAccent,
                                                            size: 14,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            "Available Coupons",
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 6),
                                                  child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: CustomAppColor
                                                        .PrimaryAccent,
                                                    size: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          rewardPoints! > 100 &&
                                                  redeemAmount == 0
                                              ? _fetchRedeemPointsData()
                                              : CustomSnackBar.showSnackbar(
                                                  context: context,
                                                  message:
                                                      "Min. 100 points required to redeem points.");
                                        },
                                        child: Card(
                                          elevation: 0,
                                          shape: Border(
                                              bottom: BorderSide(width: 0.01)),
                                          child: Container(
                                            alignment: Alignment.center,
                                            margin: EdgeInsets.only(bottom: 2),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .energy_savings_leaf_rounded,
                                                            color: CustomAppColor
                                                                .PrimaryAccent,
                                                            size: 14,
                                                          ),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            "Reward Points (${rewardPoints ?? 0})",
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 6),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 6,
                                                            vertical: 4),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                        color: rewardPoints! >
                                                                    99 &&
                                                                redeemAmount ==
                                                                    0
                                                            ? CustomAppColor
                                                                .PrimaryAccent
                                                            : Colors.grey),
                                                    child: Text(
                                                      "Redeem",
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DashedLine(width: mediaWidth, height: 1.0),
                                Container(
                                  color: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding:
                                            EdgeInsets.only(left: 15, right: 5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Order Summary",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(height: 5),
                                            _buildDetailCard('Sub Total ',
                                                totalPrice.toStringAsFixed(2)),
                                            discountPercent != null &&
                                                    discountPercent! > 0
                                                ? _buildDetailCard(
                                                    'Discount ($discountPercent%) ',
                                                    "${discountAmount.toStringAsFixed(2)}")
                                                : SizedBox(),
                                            redeemAmount != 0
                                                ? _buildDetailCard(
                                                    'Points Redeemed',
                                                    redeemAmount
                                                        .toStringAsFixed(2))
                                                : SizedBox(),
                                            gst != 0
                                                ? _buildDetailCard(
                                                    'GST ($gst%) ',
                                                    gstTaxAmount
                                                        .toStringAsFixed(2))
                                                : SizedBox(),
                                            pst != 0
                                                ? _buildDetailCard(
                                                    'PST ($pst%) ',
                                                    pstTaxAmount
                                                        .toStringAsFixed(2))
                                                : SizedBox(),
                                            hst != 0
                                                ? _buildDetailCard(
                                                    'HST ($hst%) ',
                                                    hstTaxAmount
                                                        .toStringAsFixed(2))
                                                : SizedBox(),
                                            /* _buildDetailCard(
                                    'Platform Fee: ', platformFee.toStringAsFixed(2)),*/
                                            //Divider(),
                                            SizedBox(
                                              height: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0),
                                        child: DashedLine(
                                            width: mediaWidth, height: 1.0),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 15,
                                            top: 8,
                                            right: 8,
                                            bottom: 5),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              'Total Payment',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black87),
                                            ),
                                            SizedBox(width: 40),
                                            Text(
                                              '\$${grandTotal.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDarkMode
                                                      ? Colors.white60
                                                      : Colors.black87),
                                            ),
                                          ],
                                        ),
                                      ),
                                      /*     Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child:
                                DashedLine(width: mediaWidth * 0.9, height: 1.0),
                          ),*/
                                      discountPercent != null &&
                                              discountPercent! > 0
                                          ? Container(
                                              width: mediaWidth * 0.95,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 20),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.local_offer_outlined,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    "Saving \$${discountAmount.toStringAsFixed(2)} with promotions",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : SizedBox(),
                                      /* ElevatedButton(
                                        child: Text('Call payment'),
                                        onPressed: () => makePayment(),
                                      ),*/
                                      cartList.length > 0
                                          ? Align(
                                              alignment: Alignment.bottomCenter,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 4),
                                                child: isStoreOnline &&
                                                        apiKey.isNotEmpty &&
                                                        apiKey != "null"
                                                    ? GestureDetector(
                                                        onTap: () {
                                                          email ==
                                                                  "guest@chaibar.com"
                                                              ? showGuestUserAlert(
                                                                  context)
                                                              : isLoading == false && firstName?.isNotEmpty == true
                                                                  ? _fetchStoreStatus(true)
                                                                  : CustomSnackBar.showSnackbar(context: context, message: "Please complete your profile first.", isClick: true);
                                                          //_createOrder(null);
                                                        },
                                                        child: Container(
                                                          height: 45,
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          30),
                                                              color: CustomAppColor
                                                                  .PrimaryAccent),
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 12,
                                                                  bottom: 15),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 2,
                                                                  horizontal:
                                                                      4),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              30),
                                                                      color: CustomAppColor
                                                                          .PrimaryAccent),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        vertical:
                                                                            4.0),
                                                                    child: Center(
                                                                        child: Text(
                                                                            'Process Order',
                                                                            style: TextStyle(
                                                                                fontSize: 14,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold))),
                                                                  )),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : !isStoreOnline &&
                                                            !isLoading
                                                        ? Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10,
                                                                    bottom: 30),
                                                            width: mediaWidth *
                                                                0.8,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        12,
                                                                    horizontal:
                                                                        16),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .red.shade50,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red
                                                                      .shade200),
                                                            ),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Icon(
                                                                  Icons
                                                                      .store_mall_directory,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 20,
                                                                ),
                                                                SizedBox(
                                                                    width: 8),
                                                                Flexible(
                                                                  child: Text(
                                                                    "Store is closed at the moment!",
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      color: Colors
                                                                          .red
                                                                          .shade800,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : SizedBox(),
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(
                        height: screenHeight * 0.7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: ClipRRect(
                                child: Image(
                                  width: mediaWidth * 0.7,
                                  image: AssetImage("assets/empty_cart.png"),
                                ),
                              ),
                            ),
                            Text(
                              "Cart is Empty",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
              ),
              isLoading
                  ? Stack(
                      children: [
                        // Block interaction
                        ModalBarrier(
                            dismissible: false, color: Colors.transparent),
                        // Loader indicator
                        Center(
                          child: CustomCircularProgress(),
                        ),
                      ],
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String detail) {
    return Container(
      padding: EdgeInsets.only(bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white60 : Colors.black54),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
                color: title.contains("Discount") ||
                        title.contains("Points Redeemed")
                    ? Colors.yellow
                    : Colors.transparent),
            child: Text(
              title.contains("Discount") ||
                      title.contains("Points Redeemed") && detail != "0.00"
                  ? '-\$$detail'
                  : '\$$detail',
              style: TextStyle(
                  fontSize: 13,
                  color: isDarkMode ? Colors.white60 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  double getTaxAmount(double totalPrice) {
    print("totalPrice $totalPrice");
    print("afterDiscountAmount $afterDiscountAmount");
    setState(() {
      //totalPrice > 0 ? afterDiscountAmount = 0 : SizedBox();
      afterDiscountAmount =
          afterDiscountAmount == 0 ? totalPrice : afterDiscountAmount;
      gstTaxAmount = roundToTwoDecimal((afterDiscountAmount * gst) / 100);
      pstTaxAmount = roundToTwoDecimal((afterDiscountAmount * pst) / 100);
      hstTaxAmount = roundToTwoDecimal((afterDiscountAmount * hst) / 100);
      print(
          "gstTaxAmount ${roundToTwoDecimal((afterDiscountAmount * gst) / 100)}");
      taxAmount = roundToTwoDecimal(gstTaxAmount + pstTaxAmount + hstTaxAmount);
    });
    return taxAmount;
  }

  double roundToTwoDecimal(double value) {
    return double.parse(value.toStringAsFixed(2));
  }

  void getGrandTotal(
      double totalPrice, double taxAmount, double discountAmount) {
    setState(() {
      grandTotal = totalPrice +
          getTaxAmount(totalPrice) /*+ platformFee*/ -
          getDiscountAmt() -
          redeemAmount;
    });
  }

  Future<void> getCartData() async {
    List<ProductDataDB?> productsList = await cartDataDao.findAllCartProducts();
    // print("getCartData");
    setState(() {
      List<ProductData> list = [];
      if (productsList.isNotEmpty) {
        productsList.forEach((item) {
          if (item != null) {
            print("item.vendorName : ${item.vendorName}");
            list.add(ProductData(
                quantity: int.parse("${item.quantity}"),
                vendorId: vendorId,
                franchiseId: item.franchiseId,
                title: item.title,
                status: item.status,
                shortDescription: item.shortDescription,
                salePrice: item.salePrice,
                qtyLimit: item.qtyLimit,
                isBuy1Get1: item.isBuy1Get1,
                productCategoryId: item.productCategoryId,
                price: item.price,
                deposit: item.deposit,
                // addOnType: [],
                categoryName: item.categoryName,
                // addOnIds: [],
                addOn: item.addOn,
                imageUrl: item.imageUrl,
                description: item.description,
                createdAt: "",
                environmentalFee: "",
                featured: false,
                gst: null,
                id: item.productId,
                pst: null,
                updatedAt: "",
                theme: item.theme,
                vendorName: item.vendorName,
                vpt: null,
                productSizesList: item.productSizesList));

            cartList = list;
          } else {
            //widget.theme == list[0].theme;
            cartList = list;
          }
        });
      } else {
        cartList = [];
        //Navigator.pushNamed(context, "/BottomNavigation");
      }
    });
    getCartTotal();
  }

  Future<void> initializeDatabase() async {
    productsDataDao = DBService.instance.productDao;
    cartDataDao = DBService.instance.cartDao;
    favoritesDataDao = DBService.instance.favoritesDao;
    categoryDataDao = DBService.instance.categoryDao;
    dashboardDao = DBService.instance.dashboardDao;

    getCartData();
    getCartTotal();
  }

  Future<void> addProductInDb(ProductData item) async {
    ProductDataDB data = ProductDataDB(
        description: item.description,
        imageUrl: item.imageUrl,
        //addOnIds: [],
        categoryName: item.categoryName,
        addOnType: item.addOnType,
        deposit: item.deposit,
        addOn: item.addOn,
        price: item.price,
        productCategoryId: item.productCategoryId,
        productId: item.id,
        qtyLimit: item.qtyLimit,
        isBuy1Get1: item.isBuy1Get1,
        salePrice: "",
        shortDescription: item.shortDescription,
        status: item.status,
        title: item.title,
        vendorId: vendorId,
        franchiseId: item.franchiseId,
        quantity: item.quantity,
        addedToCartAt: "${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
        productSizesList: item.productSizesList);
    print(
        "vendorId ${item.vendorId}  :: productCategoryId  ${item.productCategoryId}  :: id   ${item.id}");
    print("quantity ${item.quantity}");

    getSpecificCartProduct("${vendorId}", "${item.productCategoryId}",
        "${item.id}", cartDataDao, data);
  }

  Future<ProductDataDB?> getSpecificCartProduct(
      String vendorId,
      String categoryId,
      String productId,
      CartDataDao cartDataDao,
      ProductDataDB data) async {
    final product = await cartDataDao.getSpecificCartProduct(
        vendorId, categoryId, productId);

    if (product == null) {
      print("Product is null $product");
      List<ProductDataDB?> productsList =
          await cartDataDao.findAllCartProducts();
      print("productsList length: ${productsList.length}");
      productsList.add(data);
      if (mounted) {
        if (productsList.isNotEmpty) {
          // Use forEach instead of map to perform an action
          productsList.forEach((item) {
            if (item != null) {
              print("Inserting item: $item");
              cartDataDao.insertCartProduct(item);
            }
          });
        } else {
          print("Inserting single product: $data");
          await cartDataDao.insertCartProduct(data);
        }
      }

      return null;
    } else {
      print("Product exists: $product");
      await cartDataDao.updateCartProduct(data); // Update the existing product
    }
    getCartData();

    return product;
  }

  void deleteProductInDb(ProductData? item) {
    ProductDataDB data = ProductDataDB(
        description: item?.description,
        imageUrl: item?.imageUrl,
        /*addOnIds: item?.addOnIds*/
        categoryName: item?.categoryName,
        /*addOnType: item?.addOnType,*/
        deposit: item?.deposit,
        addOn: item?.addOn,
        price: item?.price,
        productCategoryId: item?.productCategoryId,
        productId: item?.id,
        qtyLimit: item?.qtyLimit,
        isBuy1Get1: item?.isBuy1Get1,
        salePrice: item?.salePrice,
        shortDescription: item?.shortDescription,
        status: item?.status,
        title: item?.title,
        vendorId: vendorId,
        franchiseId: item?.franchiseId,
        quantity: item?.quantity,
        addedToCartAt: "${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
        productSizesList: item?.productSizesList);
    if (item?.quantity == 0) {
      cartDataDao.deleteCartProduct(data);
    } else {
      cartDataDao.updateCartProduct(data);
    }
    getCartData();
  }

  Future<void> getCartTotal() async {
    List<ProductDataDB?> productsList = await cartDataDao.findAllCartProducts();

    double totalAmount = 0;
    for (var item in productsList) {
      if (item != null) {
        double itemTotal = 0;
        double addonTotal = 0;

        item.getAddOnList().forEach((addOnCategory) {
          addOnCategory.addOns?.forEach((addOn) {
            addonTotal += double.tryParse('${addOn.price}') ?? 0.0;
          });
        });

        if (item.isBuy1Get1 == true) {
          addonTotal = ((item.quantity ?? 0.0) / 2) * addonTotal;
          itemTotal = (((item.quantity ?? 0.0) / 2) * (item.price ?? 0)) + addonTotal;
        } else {
          addonTotal = (item.quantity ?? 0.0) * addonTotal;
          itemTotal = ((item.quantity ?? 0.0) * (item.price ?? 0)) + addonTotal;
        }

        totalAmount += itemTotal;
      }
    }

    setState(() {
      totalPrice = totalAmount;
      print("Total price $totalAmount");
      print("Total price $discountAmount");
      print("RedeemAmount $redeemAmount");
      // afterDiscountAmount = totalPrice - discountAmount;
    });

    getDiscountAmt();
    getTaxAmount(totalPrice);

    getGrandTotal(totalPrice, taxAmount, discountAmount);
  }


  void _createOrder() async {
    setState(() {
      isLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      getCartData();
      List<int> addOnIdList = [];

      List<Product> productRequest = [];
      cartList.forEach((item) {
        item?.getAddOnList().forEach((addOnCategory) {
          if (addOnCategory.addOnCategoryType == "multiple") {
            addOnCategory.addOns?.forEach((addOn) {
              addOnIdList.add(int.parse("${addOn.id}"));
            });
          } else {
            addOnCategory.addOns?.forEach((addOn) {
              addOnIdList.add(int.parse("${addOn.id}"));
            });
          }
        });
        productRequest.add(Product(
            productId: int.parse("${item?.id}"),
            quantity: int.parse("${item?.quantity}"),
            addOnIds: addOnIdList,
            price: item?.price));
      });
      CreateOrderRequest request = CreateOrderRequest(
          vendorId: int.parse("$vendorId"),
          order: Order(
            customerName: "$firstName $lastName",
            customerEmail: "$email",
            phoneNumber: "$phoneNo",
            pickupDate: "${pickupDate}",
            pickupTime: "${convertTo24HrFormat("${pickupTime}")}",
            userId: 0,
            customerId: int.parse("$userId"),
            deliveryStatus: 0,
            status: 0,
            couponId: int.parse("${couponDetails?.id ?? 0}"),
            couponCode: "${couponDetails?.couponCode ?? ""}",
            totalAmount: double.parse("${grandTotal.toStringAsFixed(2)}"),
            discountAmount: discountAmount,
            payableAmount: totalPrice,
            deliveryCharges: 0,
            orderNotes: "${_notesController.text}",
            tip: 0,
            products: productRequest,
            isPaymentSuccessTrue: false,
          ));
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .placeOrder("/api/v1/app/orders", request);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getCreateOrderResponse(context, apiResponse);
    }
  }

  Widget getCouponDetails(
      BuildContext context, ApiResponse apiResponse, bool isSheet) {
    var message = apiResponse.message.toString();
    CouponDetailsResponse? couponDetailsResponse =
        apiResponse.data as CouponDetailsResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CustomCircularProgress());
      case Status.COMPLETED:
        if (isSheet) {
          Navigator.pop(context);
        }
        double minCartAmt =
            double.tryParse("${couponDetailsResponse?.minCartAmt}") ?? 0;
        double maxDiscountAmt =
            double.tryParse("${couponDetailsResponse?.maxDiscountAmt}") ?? 0;

        print('Total Price: $totalPrice');
        print('Min Cart Amount: $minCartAmt');
        print('Max Discount Amount: $maxDiscountAmt');

        if (totalPrice >= minCartAmt && totalPrice <= 200) {
          setState(() {
            couponDetails = couponDetailsResponse;
            discountPercent = couponDetailsResponse?.discount;
            //discountAmount = double.parse("${couponDetailsResponse?.discount ?? 0}");
            isCouponApplied = true;
            _couponController.text = "";
          });
          calculateDiscount();
        } else {
          print(
              'Condition failed: Total Price: $totalPrice, Min Cart Amt: ${couponDetailsResponse?.minCartAmt}');
          CustomAlert.showToast(
              context: context,
              message:
                  "Min cart amount should be ${couponDetailsResponse?.minCartAmt}",
              duration: maxDuration);
        }

        //getDiscountAmt();
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        if (isSheet) {
          Navigator.pop(context);
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${message}")));
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

  void _fetchCouponData(String couponCode, bool isSheet) async {
    setState(() {
      isLoading = true;
    });
    hideKeyBoard();

    await Future.delayed(Duration(milliseconds: 2));
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${Languages.of(context)?.labelNoInternetConnection}'),
            duration: maxDuration,
          ),
        );
      });
    } else {
      GetCouponDetailsRequest request = GetCouponDetailsRequest(
          couponCode: couponCode.isEmpty ? _couponController.text : couponCode,
          vendorId: cartList[0]?.vendorId,
          customerId: int.parse("$userId"));
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .fetchCouponDetails("api/v1/coupons/get_coupon_detail", request);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getCouponDetails(context, apiResponse, isSheet);
    }
  }

  void _fetchRedeemPointsData() async {
    setState(() {
      isLoading = true;
    });
    hideKeyBoard();
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${Languages.of(context)?.labelNoInternetConnection}'),
            duration: maxDuration,
          ),
        );
      });
    } else {
      GetRewardPointsRequest request = GetRewardPointsRequest(
          pointsToRedeem: double.parse("$rewardPoints"),
          orderId: int.parse("0"));

      await Provider.of<MainViewModel>(context, listen: false)
          .fetchRewardPointsDetails(
              "api/v1/app/rewards/calculate_discount", request);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getRedeemPointsDetails(context, apiResponse);
    }
  }

  Widget getRedeemPointsDetails(BuildContext context, ApiResponse apiResponse) {
    var message = apiResponse.message.toString();
    GetRewardPointsResponse? response =
        apiResponse.data as GetRewardPointsResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        setState(() {
          int pointsToRedeem = int.parse("${response?.pointsRedeemed}");
          double redeemedAmount = double.parse("${response?.discountAmount}");
          double newGrandTotal = grandTotal - redeemedAmount;
          if (newGrandTotal <= 0) {
            CustomAlert.showToast(
                context: context,
                message: "Insufficient total amount to redeem points.");
          } else {
            redeemAmount = double.parse("${response?.discountAmount}");
            rewardPoints -= pointsToRedeem;
            grandTotal = grandTotal - redeemAmount;
            afterDiscountAmount = totalPrice - discountAmount - (redeemAmount);
            //totalPrice > 0 ? afterDiscountAmount = 0 : SizedBox();
            afterDiscountAmount =
                afterDiscountAmount == 0 ? totalPrice : afterDiscountAmount;
            gstTaxAmount = roundToTwoDecimal((afterDiscountAmount * gst) / 100);
            pstTaxAmount = roundToTwoDecimal((afterDiscountAmount * pst) / 100);
            hstTaxAmount = roundToTwoDecimal((afterDiscountAmount * hst) / 100);
            print(
                "gstTaxAmount ${roundToTwoDecimal((afterDiscountAmount * gst) / 100)}");
            taxAmount =
                roundToTwoDecimal(gstTaxAmount + pstTaxAmount + hstTaxAmount);
            CustomAlert.showToast(
                context: context, message: "Points Redeemed Successfully");
          }
        });
        //getTaxAmount(totalPrice - discountAmount - redeemAmount);
        return Container();
      case Status.ERROR:
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${message}")));
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

  void _fetchStoreStatus(bool isOrder) async {
    setState(() {
      isLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${Languages.of(context)?.labelNoInternetConnection}'),
            duration: maxDuration,
          ),
        );
      });
    } else {
      await Provider.of<MainViewModel>(context, listen: false).fetchStoreStatus(
          "api/v1/app/orders/get_store_status?vendor_id=$vendorId");
      if (mounted) {
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getStoreStatusResponse(context, apiResponse, isOrder);
      }
    }
  }

  Widget getStoreStatusResponse(
      BuildContext context, ApiResponse apiResponse, bool isOrder)
  {
    StoreStatusResponse? storeStatusResponse =
        apiResponse.data as StoreStatusResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        setState(() {
          if (storeStatusResponse?.storeStatus == "offline") {
            isStoreOnline = false;
            CustomSnackBar.showSnackbar(
                context: context, message: "Store is Closed!");
          } else if (storeStatusResponse?.storeStatus == "online") {
            isStoreOnline = true;
            if (isOrder) {
              _createOrder();
            }
          }

          IsUpcomingAllowed = storeStatusResponse?.IsUpcomingAllowed ?? false;
        });
        return Container();
      case Status.ERROR:
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

  double getDiscountAmt() {
    double discountVal = (totalPrice * (discountPercent ?? 0)) / 100;
    if ((double.tryParse("${couponDetails?.minCartAmt}") ?? 0) <= totalPrice &&
        discountVal <=
            (double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0)) {
      setState(() {
        discountAmount = (totalPrice * (discountPercent ?? 0)) / 100;
      });
    } else if ((double.tryParse("${couponDetails?.minCartAmt}") ?? 0) <=
        totalPrice) {
      discountAmount = double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0;
    } else {
      discountAmount = 0;
    }
    setState(() {
      afterDiscountAmount = totalPrice - discountAmount - redeemAmount;
    });
    return discountAmount;
  }

  void setThemeColor() {
    if (theme == "blue") {
      setState(() {
        primaryColor = Colors.blue.shade900;
        secondaryColor = Colors.blue[100];
        lightColor = Colors.blue[50];
      });
    }
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(
              DateTime.now().year, DateTime.now().month, DateTime.now().day)
          .toLocal(),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      barrierColor: Colors.black54,
      // Background overlay color
      helpText: "Select Pickup Date",
      confirmText: "${Languages.of(context)?.labelConfirm}",
      errorFormatText: '${Languages.of(context)?.labelEnterValidDate}',
      errorInvalidText: '${Languages.of(context)?.labelEnterDateInValidRange}',
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            primaryColor: Colors.orange, // Change primary color
            colorScheme: ColorScheme.light(
              primary: Colors.orange, // Header and button color
              onPrimary: Colors.white, // Text color on header
              onSurface: Colors.black, // Text color for dates
            ),
            dialogBackgroundColor:
                isDarkMode ? Colors.grey[900] : Colors.white, // Dialog color
          ),
          child: child!,
        );
      },
    );

    final newTime = DateTime.now().add(const Duration(minutes: 20));
    final initialTime = TimeOfDay(hour: newTime.hour, minute: newTime.minute);

    if (selectedDate != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return Theme(
            data: ThemeData(
              primaryColor: Colors.orange,
              colorScheme: ColorScheme.light(
                primary: Colors.orange, // Header & button color
                onPrimary: Colors.white, // Text color on header
                onSurface: Colors.black, // Text color for time
              ),
              dialogBackgroundColor:
                  isDarkMode ? Colors.grey[900] : Colors.white, // Dialog color
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          pickupDate = convertDateFormat("${DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            time.hour,
            time.minute,
          )}");
          pickupTime = convertTime("${DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            time.hour,
            time.minute,
          )}");
        });
      }
    }
  }

  Widget appliedCouponWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 0.4),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: CustomAppColor.PrimaryAccent),
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.discount,
                color: Colors.white,
                size: 16,
              )),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Applied Coupon*",
                style: TextStyle(fontSize: 9, color: Colors.grey),
              ),
              Text("${couponDetails?.couponCode?.toUpperCase()}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
            ],
          ),
          Spacer(),
          GestureDetector(
              onTap: () {
                setState(() {
                  isCouponApplied = false;
                  couponDetails = CouponDetailsResponse();
                  discountPercent = 0;
                  discountAmount = 0;
                  afterDiscountAmount = 0;
                });
                if (redeemAmount > 0) {
                  getTaxAmount(totalPrice - redeemAmount);
                } else {
                  getTaxAmount(totalPrice);
                }
                getGrandTotal(totalPrice, taxAmount, discountAmount);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: CustomAppColor.PrimaryAccent,
                    borderRadius: BorderRadius.circular(4)),
                child: Text("Remove",
                    style: TextStyle(fontSize: 11, color: Colors.white)),
              ))
        ],
      ),
    );
  }

  Future<void> calculateDiscount() async {
    double discountValue = totalPrice * ((couponDetails?.discount ?? 0) / 100);
    if ((double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0) >=
        discountValue) {
      print(
          "Value ${(double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0) >= discountValue}");
      setState(() {
        discountAmount = discountValue;
        afterDiscountAmount = totalPrice - discountAmount - redeemAmount;
      });
      print("afterDiscountAmount ${afterDiscountAmount.toStringAsFixed(2)}");
      await Future.delayed(Duration(milliseconds: 2));
      getGrandTotal(totalPrice, taxAmount, discountAmount);
    } else {
      setState(() {
        discountAmount =
            double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0;
      });
      await Future.delayed(Duration(milliseconds: 2));
      getGrandTotal(totalPrice, taxAmount, discountAmount);
    }
  }

  String convertTo24HrFormat(String time) {
    DateFormat inputFormat = DateFormat("hh:mm a");
    DateFormat outputFormat = DateFormat("HH:mm");
    DateTime dateTime = inputFormat.parse(time);
    String time24Hour = outputFormat.format(dateTime);

    return time24Hour;
  }

  void showCouponBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Available Coupons",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: couponsList.isNotEmpty
                        ? ListView.builder(
                            itemCount: couponsList.length,
                            shrinkWrap: true,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(bottom: 10),
                            itemBuilder: (context, index) {
                              return newCouponWidget(couponsList[index]);
                            },
                          )
                        : Center(
                            child: Text(
                              "No Coupons Found",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget newCouponWidget(PrivateCouponDetailsResponse couponsResponse) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: CouponCard(
        height: 140,
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
            style: const TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        secondChild: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 5),
            Text(
              "Use code: ${couponsResponse.couponCode}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              "Valid until: ${convertDateTimeFormat("${couponsResponse.expireAt}")}",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 5),
            Text(
              "Min. Amount: \$${couponsResponse.minCartAmt}",
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                _fetchCouponData("${couponsResponse.couponCode}", true);
              },
              child: const Text(
                "Redeem",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Text(
          "Order Instructions",
          style: TextStyle(fontSize: 18),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            style: const TextStyle(fontSize: 14.0),
            controller: _notesController,
            maxLines: 3,
            maxLength: 100,
            textAlign: TextAlign.justify,
            decoration: InputDecoration(
              counterText: "",
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 4,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.black54, width: 0.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
                borderSide: const BorderSide(color: Colors.black54, width: 0.2),
              ),
              hintText: "Order instructions (optional).",
              hintStyle: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.black),
            ),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Handle submit action
              print("Notes: ${_notesController.text}");
              Navigator.pop(context);
            },
            style: ButtonStyle(
              backgroundColor:
                  WidgetStatePropertyAll(CustomAppColor.PrimaryAccent),
            ),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _getCouponDetails() async {
    bool isConnected = await _connectivityService.isConnected();
    print(("isConnected - ${isConnected}"));
    if (!isConnected) {
      setState(() {
        isDataLoading = false;
        isInternetConnected = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Languages.of(context)!.labelNoInternetConnection),
            duration: maxDuration,
          ),
        );
      });
    } else {
      GetCouponListRequest request = GetCouponListRequest(
          vendorId: int.parse("${vendorId}"), customerId: customerId);

      await Provider.of<MainViewModel>(context, listen: false).fetchCouponList(
          "api/v1/app/customers/get_customer_coupons", request);
      if (mounted) {
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getCouponResponse(context, apiResponse);
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

  Future<void> _getRedeemPointsData() async {
    bool isConnected = await _connectivityService.isConnected();
    print(("isConnected - ${isConnected}"));
    if (!isConnected) {
      setState(() {
        isLoading = false;
        isInternetConnected = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Languages.of(context)!.labelNoInternetConnection),
            duration: maxDuration,
          ),
        );
      });
    } else {
      hideKeyBoard();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        await Future.delayed(Duration(milliseconds: 2));
        await Provider.of<MainViewModel>(context, listen: false)
            .fetchRedeemPointsApi("api/v1/app/rewards/view_points");
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getRedeemPointResponse(context, apiResponse);
      }
    }
  }

  Future<Widget> getRedeemPointResponse(
      BuildContext context, ApiResponse apiResponse) async {
    GetViewRewardPointsResponse? response =
        apiResponse.data as GetViewRewardPointsResponse?;
    print("apiResponse${apiResponse.status}");
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        rewardPoints = int.parse("${response?.totalPoints}");
        actualRewardPoints = int.parse("${response?.totalPoints}");
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        // _fetchDataFromPref();
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

  void showGuestUserAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Guest Account"),
          content: const Text(
            "You're currently using a guest account. Please create an account to place your order.",
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            ElevatedButton(
              child: const Text("Create Account"),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                Helper.clearAllSharedPreferences();
                favoritesDataDao.clearAllFavoritesProduct();
                cartDataDao.clearAllCartProduct();
                categoryDataDao.clearAllCategories();
                productsDataDao.clearAllProducts();
                dashboardDao.clearAllData();
                Navigator.pushNamed(
                    context, '/RegisterScreen'); // Change route as needed
              },
            ),
          ],
        );
      },
    );
  }
}
