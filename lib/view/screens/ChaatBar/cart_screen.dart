import 'dart:convert';

import 'package:ChaatBar/model/request/CreateOrderRequest.dart';
import 'package:ChaatBar/model/request/getCouponDetailsRequest.dart';
import 'package:ChaatBar/model/response/rf_bite/createOrderResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/getCouponDetailsResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/productListResponse.dart';
import 'package:ChaatBar/theme/AppColor.dart';
import 'package:ChaatBar/utils/Util.dart';
import 'package:ChaatBar/view/component/cart_product_component.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../languageSection/Languages.dart';
import '../../../model/apis/api_response.dart';
import '../../../model/db/ChaatBarDatabase.dart';
import '../../../model/db/dao.dart';
import '../../../model/response/rf_bite/getApiAccessKeyResponse.dart';
import '../../../model/response/rf_bite/productDataDB.dart';
import '../../../model/response/rf_bite/storeStatusResponse.dart';
import '../../../utils/Helper.dart';
import '../../../view_model/main_view_model.dart';
import '../../component/connectivity_service.dart';
import '../../component/toastMessage.dart';

class CartScreen extends StatefulWidget {
  final String theme;

  CartScreen({required this.theme});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late double screenWidth;
  late double screenHeight;
  bool isDarkMode = false;
  late ChaatBarDatabase database;
  late CartDataDao cartDataDao;
  List<ProductData?> cartList = [];
  int? discountPercent = 0;
  late int vendorId;
  int gst = 0;
  int hst = 0;
  int pst = 0;
  double grandTotal = 0;
  double totalPrice = 0;
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
  CouponDetailsResponse? couponDetails = CouponDetailsResponse();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  final TextEditingController _couponController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Color primaryColor = AppColor.PRIMARY;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];

  @override
  void initState() {
    super.initState();
    setState(() {
      pickupDate = "${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
      pickupTime =
          "${DateFormat('hh:mm a').format(DateTime.now().add(Duration(minutes: 20)))}";
    });
    Helper.getAddress().then((value){
      setState(() {
        if(value != null)
        _addressController.text = "$value";
      });
    });
    Helper.getVendorTheme().then((onValue) {
      print("theme : $onValue");
      setState(() {
        theme = onValue;
      });
    });
    Helper.getVendorDetails().then((data) {
      setState(() {
        vendorId = int.parse("${data?.id}");
        gst = int.parse("${data?.gst}");
        pst = int.parse("${data?.pst}");
        hst = int.parse("${data?.hst}");
        appId = "${data?.appId}";
        apiKey = "${data?.apiKey}";
        print("apiKey:$apiKey");
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

  Widget getCreateOrderResponse(BuildContext context, ApiResponse apiResponse,
      GetApiAccessKeyResponse? getApiAccessKeyResponse) {
    CreateOrderResponse? createOrderResponse =
        apiResponse.data as CreateOrderResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("rwrwr ${createOrderResponse?.order?.orderItems?[0].productId}");
        cartDataDao.clearAllCartProduct();

        setState(() {
          //menuItems = createOrderResponse!.products!;
        });
        //getCartData();
        Navigator.pushNamed(
          context,
          "/AddCardScreen",
          arguments: {
            "data": getApiAccessKeyResponse?.apiAccessKey.toString(),
            'orderData': createOrderResponse
          },
        );

        //Navigator.pushNamed(context, "/OrderSuccessfulScreen", arguments: createOrderResponse);

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
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushNamed(context, "/BottomNav");
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Text(
            'My Cart',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, "/BottomNav");
              },
              child: Icon(
                Icons.arrow_back_sharp,
                color: Colors.white,
              )),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    /* cartList.isNotEmpty ?
                    Container(
                      decoration: BoxDecoration(
                        color: lightColor
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ordering from:", style: TextStyle(fontSize: 14),),
                            Text("${cartList[0]?.vendorName}", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ): SizedBox(),*/
                    SizedBox(
                      height: 4,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("User details"),
                          GestureDetector(
                              onTap: () {
                                _showUserDetailDialog();
                              },
                              child: Icon(
                                Icons.info,
                                size: 20,
                              ))
                        ],
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                          minHeight: screenHeight * 0.29,
                          maxHeight: screenHeight * 0.55),
                      child: Container(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 5,
                            children: cartList.map(
                              (item) {
                                List<ProductSize> productSize = [];
                                if (item?.productSizesList != "[]") {
                                  productSize =
                                      item?.getProductSizeList() ?? [];
                                }
                                double itemTotalPrice = 0;
                                double addOnTotalPrice = 0;
                                // if (item?.productSizesList == "[]" || item?.productSizesList?.isEmpty == true) {
                                if (item?.isBuy1Get1 == true) {
                                  itemTotalPrice =
                                      (double.parse("${item?.quantity}") / 2) *
                                          double.parse("${item?.price}");
                                  item?.getAddOnList().forEach((addOnCategory) {
                                    addOnCategory.addOns?.forEach((addOn) {
                                      addOnTotalPrice = addOnTotalPrice +
                                          int.parse("${addOn.price}");
                                    });
                                  });
                                  addOnTotalPrice = addOnTotalPrice *
                                      (double.parse("${item?.quantity}") / 2);
                                } else {
                                  itemTotalPrice =
                                      double.parse("${item?.quantity}") *
                                          double.parse("${item?.price}");
                                  item?.getAddOnList().forEach((addOnCategory) {
                                    addOnCategory.addOns?.forEach((addOn) {
                                      addOnTotalPrice = addOnTotalPrice +
                                          int.parse("${addOn.price}");
                                    });
                                  });
                                  addOnTotalPrice = addOnTotalPrice *
                                      double.parse("${item?.quantity}");
                                }
                                // }
                                return CartProductComponent(
                                    item: item ?? ProductData(quantity: 0),
                                    screenWidth: screenWidth,
                                    isDarkMode: isDarkMode,
                                    itemTotalPrice: itemTotalPrice,
                                    addOnTotalPrice: addOnTotalPrice,
                                    screenHeight: screenHeight,
                                    onAddTap: () {
                                      setState(() {
                                        if (item?.addOn?.isEmpty == true ||
                                            item?.addOn == "[]" ||
                                            item?.addOn == null) {
                                          if (item?.isBuy1Get1 == false) {
                                            if (int.parse("${item?.quantity}") <
                                                int.parse(
                                                    "${item?.qtyLimit}")) {
                                              item?.quantity++;
                                              addProductInDb(
                                                  item as ProductData);
                                            }
                                          } else {
                                            if (int.parse("${item?.quantity}") <
                                                2 *
                                                    int.parse(
                                                        "${item?.qtyLimit}")) {
                                              item?.quantity = int.parse(
                                                      "${item.quantity}") +
                                                  2;
                                              addProductInDb(
                                                  item as ProductData);
                                            }
                                          }
                                        } else {
                                          Navigator.pushNamed(
                                              context, "/ProductDetailScreen",
                                              arguments: item);
                                        }
                                      });
                                    },
                                    onMinusTap: () {
                                      setState(() {
                                        if (item?.addOn?.isEmpty == true ||
                                            item?.addOn == "[]" ||
                                            item?.addOn == null) {
                                          if (item?.isBuy1Get1 == false) {
                                            if (int.parse(
                                                        "${item?.quantity}") <=
                                                    int.parse(
                                                        "${item?.qtyLimit}") &&
                                                int.parse("${item?.quantity}") >
                                                    0) {
                                              item?.quantity--;
                                              itemTotalPrice = double.parse(
                                                      "${item?.quantity}") *
                                                  double.parse(
                                                      "${item?.price}");

                                              //_updateCart(item,context);
                                              deleteProductInDb(item);
                                            }
                                          } else {
                                            if (int.parse(
                                                        "${item?.quantity}") <=
                                                    2 *
                                                        int.parse(
                                                            "${item?.qtyLimit}") &&
                                                int.parse("${item?.quantity}") >
                                                    1) {
                                              item?.quantity = int.parse(
                                                      "${item.quantity}") -
                                                  2;
                                              itemTotalPrice = (double.parse(
                                                          "${item?.quantity}") /
                                                      2) *
                                                  double.parse(
                                                      "${item?.price}");
                                              //_updateCart(item,context);
                                              deleteProductInDb(item);
                                            }
                                          }
                                        } else {
                                          Navigator.pushNamed(
                                              context, "/ProductDetailScreen",
                                              arguments: item);
                                        }
                                      });
                                    },
                                    onRemoveTap: () {
                                      if (int.parse("${item?.quantity}") > 0) {
                                        setState(() {
                                          item?.quantity = 0;
                                          if (productSize.isNotEmpty) {
                                            productSize.forEach((size) {
                                              size.quantity = 0;
                                            });
                                            item?.productSizesList =
                                                jsonEncode(productSize);
                                          }
                                        });
                                        deleteProductInDb(item);
                                      }
                                    },
                                    primaryColor: primaryColor);
                              },
                            ).toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 18, vertical: 1),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Order Notes:",
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          )),
                    ),
                    Container(
                        width: screenWidth,
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Center(
                          child: TextField(
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                            obscureText: false,
                            obscuringCharacter: "*",
                            controller: _notesController,
                            onChanged: (value) {
                              // _isValidInput();
                            },
                            onSubmitted: (value) {},
                            maxLines: 2,
                            scrollPhysics: AlwaysScrollableScrollPhysics(),
                            maxLength: 100,
                            keyboardType: TextInputType.visiblePassword,
                            textAlignVertical: TextAlignVertical.bottom,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                counterStyle: TextStyle(fontSize: 8),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 4),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 0.4)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Colors.grey, width: 0.2)),
                                hintText:
                                    "Enter order instructions if any (optional).",
                                hintStyle:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                prefixIcon: Icon(
                                  Icons.content_paste,
                                  size: 20,
                                ),
                                prefixIconColor: primaryColor),
                          ),
                        )),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            bottom: 4.0, left: 16, right: 16),
                        child: isCouponApplied
                            ? appliedCouponWidget()
                            : GestureDetector(
                                onTap: () {
                                  _showCouponDialog();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    //borderRadius: BorderRadius.circular(8),
                                    border: Border(
                                        bottom: BorderSide(
                                            color: AppColor.SECONDARY,
                                            width: 0.5)),
                                    //color: Colors.red[100]
                                  ),
                                  margin: EdgeInsets.only(
                                      left: 10, top: 4, right: 10, bottom: 2),
                                  child: Text(
                                    "Apply Coupon",
                                    style: TextStyle(
                                        color: AppColor.SECONDARY,
                                        fontSize: 12),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    IsUpcomingAllowed
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 2),
                                child: Text(
                                  "Select Pickup date & Time",
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )),
                          )
                        : SizedBox(),
                    IsUpcomingAllowed
                        ? GestureDetector(
                            onTap: () {
                              _selectDateTime(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.grey, width: 0.4)),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 2),
                              width: screenWidth,
                              height: 36,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12.0),
                                    child: Icon(Icons.calendar_month),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 36,
                                      decoration: BoxDecoration(
                                          color: AppColor.PRIMARY,
                                          border: Border(
                                              left: BorderSide(
                                                  color: Colors.grey,
                                                  width: 1)),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.zero,
                                              bottomLeft: Radius.zero,
                                              topRight: Radius.circular(8),
                                              bottomRight: Radius.circular(8))),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      child: Center(
                                        child: Text(
                                          "$pickupDate $pickupTime ",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        : SizedBox(),
                    // Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4),
                      child: Container(
                        padding: EdgeInsets.only(bottom: 8),
                        margin:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDetailCard(
                                'Subtotal: ', totalPrice.toStringAsFixed(2)),
                            _buildDetailCard('Discount($discountPercent%): ',
                                "${discountAmount.toStringAsFixed(2)}"),
                            /*_buildDetailCard(
                                'Tax (10%): ', taxAmount.toStringAsFixed(2)),*/
                            _buildDetailCard('gst ($gst%): ',
                                gstTaxAmount.toStringAsFixed(2)),
                            _buildDetailCard('pst ($pst%): ',
                                pstTaxAmount.toStringAsFixed(2)),
                            _buildDetailCard('hst ($hst%): ',
                                hstTaxAmount.toStringAsFixed(2)),
                            /* _buildDetailCard(
                                'Platform Fee: ', platformFee.toStringAsFixed(2)),*/
                            //Divider(),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Grand Total: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.black87),
                                  ),
                                  Text(
                                    '\$${grandTotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.black87),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4),
                      child: isStoreOnline &&
                              apiKey.isNotEmpty &&
                              apiKey != "null"
                          ? GestureDetector(
                              onTap: () {
                                _getApiAccessKey();
                                //_fetchStoreStatus(true);
                              },
                              child: Card(
                                margin: EdgeInsets.only(top: 5, bottom: 15),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.black),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.0),
                                      child: Center(
                                          child: Text('Check Out',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold))),
                                    )),
                              ),
                            )
                          :!isStoreOnline ? Container(
                              margin: EdgeInsets.only(top: 5, bottom: 30),
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                "Store is closed at the moment.\nTry again later!!",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ) : SizedBox(),
                    ),
                  ],
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
                          child: CircularProgressIndicator(),
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
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 0.1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title',
            style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.white60 : Colors.black87),
          ),
          Text(
            title.contains("Discount") && detail != "0.00"
                ? '-\$$detail'
                : '\$$detail',
            style: TextStyle(
                fontSize: 11,
                color: isDarkMode ? Colors.white60 : Colors.black87),
          ),
        ],
      ),
    );
  }

  double getTaxAmount(double totalPrice) {
    setState(() {
      gstTaxAmount = (totalPrice * gst) / 100;
      pstTaxAmount = (totalPrice * pst) / 100;
      hstTaxAmount = (totalPrice * hst) / 100;
      taxAmount = gstTaxAmount + hstTaxAmount + pstTaxAmount;
    });
    return taxAmount;
  }

  void getGrandTotal(
      double totalPrice, double taxAmount, double discountAmount) {
    setState(() {
      grandTotal = totalPrice +
          getTaxAmount(totalPrice) /*+ platformFee*/ - getDiscountAmt();
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
            setState(() {
              theme == cartList[0]?.theme;
              //setThemeColor();
            });
          } else {
            //widget.theme == list[0].theme;
            cartList = list;
          }
        });
      } else {
        cartList = [];
        Navigator.pushNamed(context, "/BottomNav");
      }
    });
    getCartTotal();
  }

  Future<void> initializeDatabase() async {
    database = await $FloorChaatBarDatabase
        .databaseBuilder('basic_structure_database.db')
        .build();

    cartDataDao = database.cartDao;
    getCartData();
    getCartTotal();
  }

  Future<void> addProductInDb(ProductData item) async {
    ProductDataDB data = ProductDataDB(
        description: item.description,
        imageUrl: item.imageUrl,
        //addOnIds: [],
        categoryName: item.categoryName,
        //addOnType: item.addOnType,
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
    //print("getCartData");
    setState(() {
      double totalAmount = 0;
      productsList.forEach((item) {
        if (item != null) {
          double itemTotal = 0;
          //if (item.productSizesList == "[]") {
          if (item.isBuy1Get1 == true) {
            double addonTotal = 0;
            item.getAddOnList().forEach((addOnCategory) {
              addOnCategory.addOns?.forEach((addOn) {
                addonTotal = addonTotal + int.parse("${addOn.price}");
              });
            });
            addonTotal = ((item.quantity ?? 0.00) / 2) * addonTotal;

            itemTotal = (((item.quantity ?? 0.00) / 2) * (item.price ?? 0)) +
                addonTotal;
          } else {
            if (item.getAddOnList().isEmpty) {
              itemTotal = (item.quantity ?? 0.00) * (item.price ?? 0);
            } else {
              double addonTotal = 0;
              item.getAddOnList().forEach((addOnCategory) {
                addOnCategory.addOns?.forEach((addOn) {
                  addonTotal = addonTotal + int.parse("${addOn.price}");
                });
              });
              addonTotal = (item.quantity ?? 0.00) * addonTotal;

              itemTotal =
                  ((item.quantity ?? 0.00) * (item.price ?? 0)) + addonTotal;
            }
          }
          /* } else {
            List<ProductSize> productSizes = item.getProductSizeList();
            productSizes.forEach((size) {
              itemTotal = itemTotal +
                  double.parse("${size.quantity}") *
                      double.parse("${size.price}");
            });
          }*/

          totalAmount = totalAmount + itemTotal;
        }
      });
      totalPrice = totalAmount;
    });
    getTaxAmount(totalPrice);
    getDiscountAmt();
    getGrandTotal(totalPrice, taxAmount, discountAmount);
  }

  void _createOrder(GetApiAccessKeyResponse? getApiAccessKeyResponse) async {
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
            totalAmount: totalPrice,
            discountAmount: discountAmount,
            payableAmount: grandTotal,
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
      getCreateOrderResponse(context, apiResponse, getApiAccessKeyResponse);
    }
  }

  Widget getCouponDetails(BuildContext context, ApiResponse apiResponse) {
    var message = apiResponse.message.toString();
    CouponDetailsResponse? couponDetailsResponse =
        apiResponse.data as CouponDetailsResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("rwrwr ${couponDetailsResponse?.discount}");

        setState(() {
          if ((double.tryParse("${couponDetails?.minCartAmt}") ?? 0) <=
              totalPrice) {
            setState(() {
              couponDetails = couponDetailsResponse;
              discountPercent = couponDetailsResponse?.discount;
              isCouponApplied = true;
              calculateDiscount();

            });
          } else {}
        });
        //getDiscountAmt();
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${message}")));
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

  void _fetchCouponData() async {
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
      GetCouponDetailsRequest request = GetCouponDetailsRequest(
          couponCode: _couponController.text, vendorId: cartList[0]?.vendorId);
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .fetchCouponDetails("api/v1/app/customers/get_coupon_detail", request);
      ApiResponse apiResponse =
          Provider.of <MainViewModel>(context, listen: false).response;
      getCouponDetails(context, apiResponse);
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
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false).fetchStoreStatus(
          "/api/v1/vendors/get_store_status?vendor_id=$vendorId");
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getStoreStatusResponse(context, apiResponse, isOrder);
    }
  }

  Widget getStoreStatusResponse(
      BuildContext context, ApiResponse apiResponse, bool isOrder) {
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
            ToastComponent.showToast(
                context: context, message: "Store is Closed!");
          } else if (storeStatusResponse?.storeStatus == "online") {
            isStoreOnline = true;
            if (isOrder) {
              _getApiAccessKey();
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
    setState(() {
      if ((double.tryParse("${couponDetails?.minCartAmt}") ?? 0) <=
              totalPrice &&
          discountVal <=
              (double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0)) {
        setState(() {
          discountAmount = (totalPrice * (discountPercent ?? 0)) / 100;
        });
      } else if ((double.tryParse("${couponDetails?.minCartAmt}") ?? 0) <=
          totalPrice) {
        discountAmount =
            double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0;
      } else {
        discountAmount = 0;
      }
    });
    return discountAmount;
  }

  void _showCouponDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Enter Coupon Code",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            style: TextStyle(
              fontSize: 12.0,
            ),
            obscureText: false,
            obscuringCharacter: "*",
            controller: _couponController,
            onChanged: (value) {
              // _isValidInput();
            },
            onSubmitted: (value) {},
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 0.8)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryColor, width: 0.7)),
                hintText: "Enter Coupon Code",
                prefixIcon: Icon(Icons.card_giftcard),
                prefixIconColor: primaryColor),
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  if (_couponController.text.isNotEmpty) {
                    hideKeyBoard();

                    await Future.delayed(Duration(milliseconds: 2));
                    _fetchCouponData();
                    Navigator.pop(context);
                    hideKeyBoard();
                  } else {
                    print('Enter a coupon code');
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Text(
                    "Apply",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUserDetailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.center,
          title: Center(child: Text("User Details")),
          titleTextStyle: TextStyle(
              fontSize: 18, color: isDarkMode ? Colors.white : Colors.black),
          actionsPadding: EdgeInsets.only(bottom: 18),
          titlePadding: EdgeInsets.only(top: 18, left: 20, right: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 25),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoWidget("First Name", "$firstName",
                          Icons.person_outline_outlined),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoWidget("Last Name", "$lastName",
                          Icons.person_outline_outlined),
                    ],
                  )
                ],
              ),
              _infoWidget(
                  "Email Address", "$email", Icons.alternate_email_outlined),
              _infoWidget("Phone Number", "$phoneNo", Icons.call),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Address",
                      style: TextStyle(fontSize: 11.5, color: Colors.black87)),
                  Text(
                    "(optional)",
                    style: TextStyle(fontSize: 10, color: Colors.black87),
                  ),
                ],
              ),
              SizedBox(
                height: 1,
              ),
              Container(
                height: 35,
                child: TextField(
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                  obscureText: false,
                  obscuringCharacter: "*",
                  controller: _addressController,
                  onChanged: (value) {
                    // _isValidInput();
                  },
                  onSubmitted: (value) {},
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 0.4)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey, width: 0.3)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: GestureDetector(
                onTap: () {
                  /*if (_couponController.text.isNotEmpty) {
                    hideKeyBoard();
                    _fetchCouponData();
                    Navigator.pop(context);
                  } else {
                    // Show validation message if needed
                    print('Enter a coupon code');
                  }*/
                  Helper.saveAddress("${_addressController.text}");
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoWidget(String heading, String detail, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
          ),
          SizedBox(
            width: 5,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(heading,
                  style: TextStyle(fontSize: 11.5, color: Colors.black)),
              SizedBox(
                height: 1,
              ),
              Text(detail,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
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
        firstDate: DateTime.now(),
        //DateTime.now() - not to allow to choose before today.
        lastDate: DateTime.now().add(Duration(days: 1)),
        helpText: "Select Pickup Date",
        confirmText: "${Languages.of(context)?.labelConfirm}",
        errorFormatText: '${Languages.of(context)?.labelEnterValidDate}',
        errorInvalidText:
            '${Languages.of(context)?.labelEnterDateInValidRange}',
        builder: (context, child) {
          return Theme(
            data: isDarkMode
                ? ThemeData.dark()
                : ThemeData.light(), // This will change to light theme.
            child: child!,
          );
        });
    final newTime = DateTime.now().add(Duration(minutes: 20));
    final initialTime = TimeOfDay(hour: newTime.hour, minute: newTime.minute);

    if (selectedDate != null) {
      final TimeOfDay? time = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return Theme(
              data: isDarkMode
                  ? ThemeData.dark()
                  : ThemeData.light(), // This will change to light theme.
              child: child!,
            );
          });

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
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey, width: 0.4),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppColor.SECONDARY),
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.discount,
                color: Colors.white,
                size: 18,
              )),
          SizedBox(
            width: 15,
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
                  getGrandTotal(totalPrice, taxAmount, discountAmount);
                });
              },
              child: Text("Remove",
                  style: TextStyle(fontSize: 11, color: AppColor.PRIMARY)))
        ],
      ),
    );
  }

  void calculateDiscount() {
    setState(() async {
      double discountValue =
          totalPrice * ((couponDetails?.discount ?? 0) / 100);
      if ((double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0) >=
          discountValue) {
        print(
            "${(double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0) >= discountValue}");
        discountAmount = discountValue;

        await Future.delayed(Duration(milliseconds: 2));
        getGrandTotal(totalPrice, taxAmount, discountAmount);
      } else {
        discountAmount =
            double.tryParse("${couponDetails?.maxDiscountAmt}") ?? 0;

        await Future.delayed(Duration(milliseconds: 2));
        getGrandTotal(totalPrice, taxAmount, discountAmount);
      }
    });
  }

  String convertTo24HrFormat(String time) {
    DateFormat inputFormat = DateFormat("hh:mm a");
    DateFormat outputFormat = DateFormat("HH:mm");
    DateTime dateTime = inputFormat.parse(time);

    // Convert the DateTime object to a 24-hour format string
    String time24Hour = outputFormat.format(dateTime);

    return time24Hour;
  }

  //Api Call
  Future<void> _getApiAccessKey() async {
    hideKeyBoard();
    const maxDuration = Duration(seconds: 2);
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
      await Provider.of<MainViewModel>(context, listen: false)
         // .getApiAccessKey("https://api.clover.com/pakms/apikey", "3238f7d7-bbc4-9b71-314e-1b2e1bd76a9d");
    .getApiAccessKey("https://scl-sandbox.dev.clover.com/pakms/apikey", "f2240939-d0fa-ccfd-88ff-2f14e160dc6a");
   // .getApiAccessKey("https://api.clover.com/pakms/apikey", "$apiKey");
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getApiAccessKeyResponse(context, apiResponse);
    }
  }

  Future<Widget> getApiAccessKeyResponse(
      BuildContext context, ApiResponse apiResponse) async {
    GetApiAccessKeyResponse? getApiAccessKeyResponse =
        apiResponse.data as GetApiAccessKeyResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("GetSignInResponse : ${getApiAccessKeyResponse}");
        //_getApiToken(getApiAccessKeyResponse?.apiAccessKey);
        _createOrder(getApiAccessKeyResponse);

        // Check if the token was saved successfully
        if (getApiAccessKeyResponse?.active == true) {
          print('Token saved successfully.');
        } else {
          print('Failed to save token.');
        }

        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("message : ${apiResponse.message}");
        ToastComponent.showToast(
            context: context, message: apiResponse.message);
        return Center();
      case Status.INITIAL:
      default:
        return Center();
    }
  }

}
