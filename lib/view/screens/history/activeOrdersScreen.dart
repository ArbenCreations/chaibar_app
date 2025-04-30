import 'package:flutter/material.dart';
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
import '../../component/ShimmerList.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';
import 'orderHistoryScreen.dart';

class ActiveOrdersScreen extends StatefulWidget {
  @override
  _ActiveOrdersScreenState createState() => _ActiveOrdersScreenState();
}

class _ActiveOrdersScreenState extends State<ActiveOrdersScreen>
    with SingleTickerProviderStateMixin {
  String token = "";
  late double mediaWidth;
  bool isInternetConnected = true;
  late bool isDarkMode;
  late double screenHeight;
  bool isLoading = true;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  final ScrollController _scrollController = ScrollController();

  Future<void>? _fetchDataFuture;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int? _totalRows = 0;

  List<OrderDetails> activeOrders = [];
  List<OrderDetails> upcomingOrders = [];

  int activeType = 0;
  int upcomingType = 5;
  int selectedOrderType = 0;

  String? theme = "";
  Color primaryColor = CustomAppColor.Primary;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    Helper.getVendorTheme().then((onValue) {
      setState(() {
        theme = onValue;
      });
    });
    runApi();
    _scrollController.addListener(_activeLoadMore);
    _fetchDataFuture = _fetchData(_currentPage, false, selectedOrderType);
  }

  runApi() {
    setState(() {
      isLoading = true;
    });
    setState(() {
      selectedOrderType = activeType;
      activeOrders.clear();
    });
    _currentPage = 1;
    _scrollController.addListener(_activeLoadMore);
    _fetchDataFuture = _fetchData(_currentPage, false, selectedOrderType);
  }

  void _activeLoadMore() async {
    final currentList =
        selectedOrderType == activeType ? activeOrders : upcomingOrders;

    if (!_isLoadingMore &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        currentList.length < _totalRows!) {
      setState(() {
        _isLoadingMore = true;
      });

      _currentPage++;
      await _fetchData(_currentPage, true, selectedOrderType);

      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  void dispose() {
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
    // Call API when tab changes
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PageView to handle content switching
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  _buildActive(), // Active Orders
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActive() {
    return Container(
      height: screenHeight,
      child: isInternetConnected && !isLoading
          ? checkListEmpty(activeOrders)
              ? FutureBuilder(
                  future: _fetchDataFuture,
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading data'));
                    } else {
                      // Group transactions by date
                      Map<String, List<OrderDetails>> groupedOrders =
                          groupOrdersByDate(activeOrders);
                      List<String> dates = groupedOrders.keys.toList();

                      return ListView.builder(
                        controller: _scrollController,
                        itemCount: dates.length + (_isLoadingMore ? 1 : 0),
                        itemBuilder: (BuildContext context, int index) {
                          if (index == dates.length) {
                            return Center(
                                child: CircularProgressIndicator(
                              color: isDarkMode
                                  ? Colors.white
                                  : CustomAppColor.Primary,
                            ));
                          }
                          String date = dates[index];
                          List<OrderDetails> ordersForDate =
                              groupedOrders[date]!;

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
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
                    "No Active Orders",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
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

  Future<void> _fetchData(int pageKey, bool isScroll, int selectionType) async {
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
        GetHistoryRequest request = GetHistoryRequest(
            pageNumber: pageKey, pageSize: 10, status: selectionType);
        await Provider.of<MainViewModel>(context, listen: false)
            .getHistoryData("/api/v1/app/orders/cust_order_history", request);
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        await getHistoryData(
          context,
          apiResponse,
          pageKey,
          selectionType,
        );
      }
    } catch (error) {
      print("No Past Orders: $error");
    }
  }

  Future<void> getHistoryData(BuildContext context, ApiResponse apiResponse,
      int pageKey, int selectionType) async {
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
          _totalRows = getHistoryResponse?.totalRows ?? 0;

          if (selectionType == activeType) {
            if (pageKey == 1) {
              activeOrders.clear();
            }
            activeOrders.addAll(newItems);
          } else if (selectionType == upcomingType) {
            if (pageKey == 1) {
              upcomingOrders.clear();
            }
            upcomingOrders.addAll(newItems);
          }
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
