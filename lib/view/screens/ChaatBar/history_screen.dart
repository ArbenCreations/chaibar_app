import 'package:ChaatBar/model/request/getHistoryRequest.dart';
import 'package:ChaatBar/model/response/rf_bite/bannerListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/createOrderResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/getHistoryResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/vendorListResponse.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../languageSection/Languages.dart';
import '../../../model/apis/api_response.dart';
import '../../../theme/AppColor.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../view_model/main_view_model.dart';
import '../../component/ShimmerList.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  String token = "";
  late double screenWidth;
  late double screenHeight;
  late bool isActive;
  bool isInternetConnected = true;
  late bool isDarkMode;
  bool isLoading = true;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  List<VendorData> vendorList = [];
  List<BannerData> bannerList = [];
  final TextEditingController queryController = TextEditingController();
  late TabController _tabController;

  final _scrollController = ScrollController();
  Future<void>? _fetchDataFuture;
  bool _isLoadingMore = false;
  int _currentPage = 1;

  List<OrderDetails> historyOrders = [];

  String? theme = "";
  Color primaryColor = AppColor.PRIMARY;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];

  @override
  void initState() {
    super.initState();
    Helper.getVendorTheme().then((onValue) {
      print("theme : $onValue");
      setState(() {
        theme = onValue;
        //setThemeColor();
      });
    });

    historyOrders.clear();
    setState(() {
      isActive = true;
    });
    _tabController = TabController(length: 2, vsync: this);

    _scrollController.addListener(_LoadMore);
    _fetchDataFuture = _fetchData(_currentPage, false);
  }

  void _LoadMore() async {
    if (!_isLoadingMore &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      setState(() {
        _isLoadingMore = true;
      });
      _currentPage++;
      await _fetchData(_currentPage, true);
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, "/BottomNav");
      },
      child: Scaffold(
          body: Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: CustomScrollView(slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Orders History",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: isDarkMode ? Colors.white : AppColor.TEXT_COLOR),
            ),
            middle: Text(
              "Orders History",
              style: TextStyle(
                  fontSize: 22,
                  color: isDarkMode ? Colors.white : AppColor.TEXT_COLOR),
            ),
            backgroundColor:
                isDarkMode ? AppColor.DARK_BG_COLOR : AppColor.BG_COLOR,
            leading: SizedBox(),
            transitionBetweenRoutes: true,
            alwaysShowMiddle: false,

            border: Border.all(color: Colors.transparent),
          ),
          SliverToBoxAdapter(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                  statusBarColor: AppColor.PRIMARY,
                  statusBarIconBrightness: Brightness.light),
              child: Container(
                height: screenHeight * 0.85,
                child: LayoutBuilder(builder:
                    (BuildContext context, BoxConstraints viewportConstraints) {
                  return Stack(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: _buildHistory(),
                    ),
                    isActive
                        ? Container(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 80),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, "/ActiveOrUpcomingScreen");
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Container(
                                      width: screenWidth * 0.75,
                                      height: screenHeight * 0.06,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: AppColor.SECONDARY),
                                      child: Center(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text(
                                            "Active/Upcoming Orders",
                                            style: TextStyle(
                                                color: AppColor.WHITE,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Icon(
                                            Icons.fastfood,
                                            color: Colors.white,
                                            size: 26,
                                          )
                                        ],
                                      )),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ]);
                }),
              ),
            ),
          ),
        ]),
      )),
    );
  }

  Widget _buildHistory() {
    return Container(
      height: screenHeight * 0.85,
      child: isInternetConnected && !isLoading
          ? checkListEmpty(historyOrders)
              ? FutureBuilder(
                  future: _fetchDataFuture,
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading data'));
                    } else {
                      // Group transactions by date
                      Map<String, List<OrderDetails>> groupedOrders =
                          groupOrdersByDate(historyOrders);
                      List<String> dates = groupedOrders.keys.toList();

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: dates.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == dates.length) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: isDarkMode
                                  ? AppColor.WHITE
                                  : AppColor.PRIMARY,
                            ));
                          }
                          String date = dates[index];
                          List<OrderDetails> ordersForDate =
                              groupedOrders[date]!;

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    date,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ),
                                ...ordersForDate.asMap().entries.map((order) {
                                  return OrderCard(
                                    order: order.value,
                                  );
                                }).toList(),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                )
              : Center(
                  child: Text(
                    "No Past Orders",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              child: ShimmerList(),
            ),
    );
  }

  bool checkListEmpty(List<OrderDetails> list) {
    bool isListEmpty = false;

    isListEmpty = list.isNotEmpty;

    return isListEmpty;
  }

  Map<String, List<OrderDetails>> groupOrdersByDate(List<OrderDetails> orders) {
    Map<String, List<OrderDetails>> groupedData = {};

    for (var order in orders) {
      String date = convertDateFormat("${order.createdAt}");
      if (!groupedData.containsKey(date)) {
        groupedData[date] = [];
      }
      groupedData[date]!.add(order);
    }
    return groupedData;
  }

  Future<void> _fetchData(int pageKey, bool isScroll) async {
    try {
      setState(() {
        //isLoading = true;
      });
      bool isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        setState(() {
          isLoading = false;
          isInternetConnected = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('${Languages.of(context)?.labelNoInternetConnection}'),
              duration: maxDuration,
            ),
          );
        });
      } else {
        GetHistoryRequest request =
            GetHistoryRequest(pageNumber: pageKey, pageSize: 8, status: 2);
        await Provider.of<MainViewModel>(context, listen: false)
            .getHistoryData("/api/v1/app/orders/cust_order_history", request);
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        await getHistoryData(context, apiResponse, pageKey, isScroll);
      }
    } catch (error) {
      print("No Past Orders: $error");
    }
  }

  Future<void> getHistoryData(BuildContext context, ApiResponse apiResponse,
      int pageKey, bool isScroll) async {
    GetHistoryResponse? getHistoryResponse =
        apiResponse.data as GetHistoryResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return;
      case Status.COMPLETED:
        final newItems = getHistoryResponse?.orders ?? [];
        setState(() {
          print(
              "getHistoryResponse?.orders :: ${getHistoryResponse?.orders?.length}");
          historyOrders.addAll(newItems);
          print("historyOrders.length :: ${historyOrders.length}");
        });
        return;
      case Status.ERROR:
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        }
        return;
      case Status.INITIAL:
      default:
        return;
    }
  }
}

class OrderCard extends StatelessWidget {
  final OrderDetails order;

  const OrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/OrderDetailScreen', arguments: order);
      },
      child: Stack(
        children: [
          Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("#${order.orderNo}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                              SizedBox(width: 3),
                              Text(
                                  '${convertDateTimeFormat("${order.createdAt}")}',
                                  style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_pin,
                              color: AppColor.SECONDARY,
                              size: 18,
                            ),
                            Text(capitalizeFirstLetter("${order.locality}"),
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    order.rejectNote != null
                        ? Text("${order.rejectNote}",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]))
                        : SizedBox(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.66,
                              child: order.orderItems?.isNotEmpty == true &&
                                      order.orderItems != null
                                  ? Wrap(
                                      spacing: 10,
                                      // Horizontal space between items
                                      runSpacing: 5,
                                      // Vertical space between lines
                                      children: order.orderItems!
                                          .take(int.parse(
                                                      "${order.orderItems?.length}") <
                                                  3
                                              ? int.parse(
                                                  "${order.orderItems?.length}")
                                              : 3)
                                          .map((item) {
                                        return Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.64,
                                          child: Text(
                                              "${item.quantity} x ${item.product?.title}",
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[600])),
                                        );
                                      }).toList())
                                  : SizedBox(),
                            ),
                            int.parse("${order.orderItems?.length}") > 3
                                ? Text("...",
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[600]))
                                : SizedBox(),
                          ],
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              SizedBox(),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: Text('\$${order.payableAmount}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic,
                                        fontSize: 15)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: -3,
            child: CustomPaint(
              painter: TagPainter(text: '${order.status}'),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(5),
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5))),
                child: Text(
                  order.status == "pending_order"
                      ? "Upcoming Order"
                      : '${capitalizeFirstLetter("${order.status}")}',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TagPainter extends CustomPainter {
  final String text;

  const TagPainter({required this.text});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = text == "completed"
          ? Colors.green
          : text == "accepted"
              ? AppColor.SECONDARY
              : text == "new_order"
                  ? Colors.blue
                  : text == "pending_order"
                      ? Colors.black
                      : Colors.red;

    const borderRadius = 4.0;

    // Draw the main rounded rectangle shape with top-left, top-right, and bottom-right rounded corners
    final roundedRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
      bottomLeft: Radius.zero, // Keep the bottom-left corner sharp
    );

    // Draw the rounded rectangle part
    canvas.drawRRect(roundedRect, paint);

    final path = Path();
    /*path.moveTo(-3, 0); // Start at the top-left corner
    path.lineTo(size.width-3  , -3); // Top edge
    path.lineTo(size.width -3 , size.height); // Right edge*/
    path.moveTo(13, size.height); // Start for the bottom edge of the rectangle
    path.lineTo(
        13, size.height + 8); // Diagonal down to create the triangular tail
    path.lineTo(3, size.height);
    path.close(); // Close the path

    canvas.drawPath(path, paint);
  }

/*
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.green;

    const borderRadius = 5.0;

    // Draw the main rounded rectangle shape with top-left, top-right, and bottom-right rounded corners
    final roundedRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
      bottomLeft: Radius.zero, // Keep the bottom-left corner sharp
    );

    // Draw the rounded rectangle part
    canvas.drawRRect(roundedRect, paint);

    // Create a path for the tail
    final path = Path();
    path.moveTo(15, size.height);            // Start from bottom left of tail
    path.lineTo(15, size.height + 10);       // Diagonal for the triangular tail
    path.lineTo(5, size.height);             // Back up to create tail shape
    path.close();

    // Draw the tail path
    canvas.drawPath(path, paint);
  }*/

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
