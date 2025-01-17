import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../languageSection/Languages.dart';
import '../../../model/apis/api_response.dart';
import '../../../model/request/getHistoryRequest.dart';
import '../../../model/response/rf_bite/createOrderResponse.dart';
import '../../../model/response/rf_bite/getHistoryResponse.dart';
import '../../../theme/AppColor.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../view_model/main_view_model.dart';
import '../../component/ShimmerList.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';
import 'history_screen.dart';

class ActiveOrUpcomingScreen extends StatefulWidget {

  @override
  _ActiveOrUpcomingScreenState createState() => _ActiveOrUpcomingScreenState();
}

class _ActiveOrUpcomingScreenState extends State<ActiveOrUpcomingScreen>
    with SingleTickerProviderStateMixin {
  String token = "";
  late double screenWidth;
  bool isInternetConnected = true;
  late bool isDarkMode;
  late double screenHeight;
  bool isLoading = true;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  Future<void>? _fetchDataFuture;
  bool _isLoadingMore = false;
  int _currentPage = 1;

  List<OrderDetails> activeOrders = [];
  List<OrderDetails> upcomingOrders = [];

  int activeType = 0;
  int upcomingType = 5;
  int selectedOrderType = 0;


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
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_activeLoadMore);
    _fetchDataFuture =
        _fetchData(_currentPage, false,selectedOrderType);
  }

  runApi(int? index) {
    setState(() {
      isLoading = true;});
    if (index == 0) {
      setState(() {
        selectedOrderType = activeType;
        activeOrders.clear();
      });
      _currentPage = 1;
      _scrollController.addListener(_activeLoadMore);
      _fetchDataFuture = _fetchData(_currentPage, false,selectedOrderType);
    } else {
      setState(() {
        selectedOrderType = upcomingType;
        upcomingOrders.clear();
      });
      _currentPage = 1;
      _scrollController.addListener(_upcomingLoadMore);
      _fetchDataFuture = _fetchData(_currentPage, false,selectedOrderType);
      //_fetchData(_currentPage, false,selectedOrderType);
      // _fetchDataFuture = _fetchData(_currentPage, false);
    }
  }

  void _activeLoadMore() async {
    if (!_isLoadingMore &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      setState(() {
        _isLoadingMore = true;
      });
      _currentPage++;
      await _fetchData(_currentPage, true,selectedOrderType);
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _upcomingLoadMore() async {
    if (!_isLoadingMore &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      setState(() {
        _isLoadingMore = true;
      });
      _currentPage++;
      await _fetchData(_currentPage, true,selectedOrderType);
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
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back)),
        title: Text(
          "Orders",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Stack(children: [
          SafeArea(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: isDarkMode
                  ? SystemUiOverlayStyle.light
                  : SystemUiOverlayStyle.dark,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TabBar below heading
                    TabBar(
                      controller: _tabController,
                      onTap: (index) {
                        runApi(index);
                      },
                      tabs: [
                        Tab(text: 'Active Orders'),
                        Tab(text: 'Upcoming Orders'),
                      ],
                      dividerColor: Colors.transparent,
                      indicatorColor: Colors.blue,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                    ),

                    // TabBarView to display the list content below the TabBar
                    Container(
                      height: screenHeight * 0.85,
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          _buildActive(),
                          _buildUpcoming(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          /* isLoading
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
              : SizedBox()*/
        ]),
      ),
    );
  }

  Widget _buildUpcoming(){
    return  Container(
      height: screenHeight,
      margin: EdgeInsets.only(top: 4),
      child: isInternetConnected && !isLoading
          ? checkListEmpty(upcomingOrders)
          ? FutureBuilder(
        future: _fetchDataFuture,
        builder:
            (BuildContext context, AsyncSnapshot<void> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading data'));
          } else {
            // Group transactions by date
            Map<String, List<OrderDetails>>
            groupedOrders =
            groupOrdersByDate(upcomingOrders);
            List<String> dates = groupedOrders.keys.toList();

            return ListView.builder(
              controller: _scrollController,
              itemCount: dates.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index == dates.length) {
                  return Center(child: CircularProgressIndicator(color: isDarkMode ? AppColor.WHITE : AppColor.PRIMARY,));
                }
                String date = dates[index];
                List<OrderDetails> ordersForDate =
                groupedOrders[date]!;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
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
                        return OrderCard( order: order.value,);
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
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        child: ShimmerList(),
      ),
    );;
  }

  Widget _buildActive() {
    return Container(
      height: screenHeight,
      margin: EdgeInsets.only(top: 4),
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
            Map<String, List<OrderDetails>>
            groupedOrders =
            groupOrdersByDate(activeOrders);
            List<String> dates = groupedOrders.keys.toList();

            return ListView.builder(
              controller: _scrollController,
              itemCount: dates.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (BuildContext context, int index) {
                if (index == dates.length) {
                  return Center(child: CircularProgressIndicator(color: isDarkMode ? AppColor.WHITE : AppColor.PRIMARY,));
                }
                String date = dates[index];
                List<OrderDetails> ordersForDate =
                groupedOrders[date]!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 4 ),
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
                        return OrderCard( order: order.value,);
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

  Map<String, List<OrderDetails>> groupOrdersByDate(
      List<OrderDetails> orders) {
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

  Future<void> _fetchData(int pageKey, bool isScroll,int selectionType) async {
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

        GetHistoryRequest request = GetHistoryRequest(pageNumber: pageKey, pageSize: 8, status: selectionType);
        await Provider.of<MainViewModel>(context, listen: false)
            .getHistoryData(
            "/api/v1/app/orders/cust_order_history", request);
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        await getHistoryData(context, apiResponse, pageKey, selectionType,);
      }
    } catch (error) {
      print("No Past Orders: $error");
    }
  }


  Future<void> getHistoryData(BuildContext context, ApiResponse apiResponse,
      int pageKey,int selectionType) async {
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
        if(selectionType == activeType) {
          setState(() {
            //activeOrders.clear();
            activeOrders.addAll(newItems);
            print("${activeOrders.length}");
          });
        }else if(selectionType == upcomingType){
          setState(() {
            //upcomingOrders.clear();
            upcomingOrders.addAll(newItems);
            print("${upcomingOrders.length}");
          });
        }
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
