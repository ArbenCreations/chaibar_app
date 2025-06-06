import 'package:ChaiBar/view/screens/history/activeOrdersScreen.dart';
import 'package:ChaiBar/view/screens/history/pastOrdersScreen.dart';
import 'package:ChaiBar/view/screens/history/upcomingOrdersScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../language/Languages.dart';
import '../../../model/request/getHistoryRequest.dart';
import '../../../model/response/createOrderResponse.dart';
import '../../../model/response/getHistoryResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../theme/CustomAppColor.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';

class OrderHistoryScreen extends StatefulWidget {
  @override
  _OrderHistoryScreenState createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with SingleTickerProviderStateMixin {
  String token = "";
  late double mediaWidth;
  late double screenHeight;
  late bool isActive;
  bool isInternetConnected = true;
  late bool isDarkMode;
  bool isLoading = true;
  var _connectivityService = ConnectivityService();
  final TextEditingController queryController = TextEditingController();
  late TabController _tabController;
  int? activeOrderCount = 0;
  Color primaryColor = CustomAppColor.Primary;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];

  @override
  void initState() {
    super.initState();
    Helper.getActiveOrderCounts().then((count) {
      setState(() {
        activeOrderCount = count;
      });
    });
    setState(() {
      isActive = true;
    });
    _tabController = TabController(length: 2, vsync: this);
    //_scrollController.addListener(_LoadMore);
    //_fetchDataFuture = _fetchData(_currentPage, false);
  }

 /* void _LoadMore() async {
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
  }*/

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, "/BottomNavigation",
            arguments: 1);
      },
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
            )),
            systemOverlayStyle:
                SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
            toolbarHeight: 50,
            title: Text(
              "Orders",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white),
            ),
            leading: SizedBox(),
          ),
          body: DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  color: CustomAppColor.Background,
                  child: TabBar(
                    labelColor: Colors.black,
                    dividerColor: Colors.white,
                    indicatorColor: CustomAppColor.PrimaryAccent,
                    tabs: [
                      Tab(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.ac_unit_sharp,
                            size: 12,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Active",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                          if (activeOrderCount! > 0)
                            Container(
                              padding: const EdgeInsets.all(4),
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 10,
                                minHeight: 10,
                              ),
                              child: Text(
                                '$activeOrderCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      )),
                      Tab(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.table_chart,
                            size: 12,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Past",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      )),
                      Tab(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flutter_dash,
                            size: 11,
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Upcoming",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ActiveOrdersScreen(),
                      PastOrdersScreen(),
                      UpcomingOrdersScreen(),
                    ],
                  ),
                ),
              ],
            ),
          )),
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
          CustomSnackBar.showSnackbar(
              context: context,
              message: '${Languages.of(context)?.labelNoInternetConnection}');
        });
      } else {
        GetHistoryRequest request =
            GetHistoryRequest(pageNumber: pageKey, pageSize: 20, status: 0);
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
      int pageKey, bool isScroll) async
  {
    GetHistoryResponse? getHistoryResponse =
        apiResponse.data as GetHistoryResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return;
      case Status.COMPLETED:
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
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: CustomAppColor.PrimaryAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.store_mall_directory,
                          color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Transaction ID",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "#${order.orderNo}",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${order.totalAmount}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: getStatusColor("${order.status}",
                                isBackground: true),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            " ${capitalizeFirstLetter("${order.status}")}",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: getStatusColor("${order.status}",
                                  isBackground: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "From ${capitalizeFirstLetter("${order.locality}")}",
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: order.orderItems?.isNotEmpty == true
                                  ? order.orderItems!
                                      .take(3)
                                      .map((item) {
                                      return Text(
                                        "${item.quantity} x ${capitalizeFirstLetter("${item.product?.title}")}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    }).toList()
                                  : [SizedBox()],
                            ),
                            if (order.orderItems!.length > 3)
                              Text(
                                "...",
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[600]),
                              ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${convertDateFormat("${order.createdAt}")}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '${convertTimeFormat("${order.createdAt}")}',
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
                order.rejectNote != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          "${order.rejectNote}",
                          style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              fontStyle: FontStyle.italic),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ),
        )
        );
  }

  Color getStatusColor(String text, {bool isBackground = false}) {
    if (text == "completed") {
      return isBackground ? Colors.green.shade100 : Colors.green;
    } else if (text == "accepted") {
      return isBackground ? Colors.blue.shade100 : Colors.blue;
    } else if (text == "new_order") {
      return isBackground ? Colors.blue.shade100 : Colors.blue;
    } else if (text == "pending_order" || text == "upcoming order") {
      return isBackground ? Colors.purple.shade100 : Colors.purple;
    } else {
      return isBackground ? Colors.red.shade100 : Colors.red;
    }
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
              ? Colors.blue
              : text == "new_order"
                  ? Colors.blue
                  : text == "pending_order" || text == "upcoming order"
                      ? Colors.purple
                      : Colors.red;

    const borderRadius = 4.0;

    final roundedRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, size.width, size.height),
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
      bottomLeft: Radius.zero,
    );

    canvas.drawRRect(roundedRect, paint);

    final path = Path();
    path.moveTo(13, size.height);
    path.lineTo(
        13, size.height + 8);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
