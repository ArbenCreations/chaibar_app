import 'package:ChaiBar/view/component/ShimmerList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/language/Languages.dart';
import '/utils/Helper.dart';
import '/utils/Util.dart';
import '../../../model/response/StoreSettingResponse.dart';
import '../../../model/response/vendorListResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../theme/CustomAppColor.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomAlert.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/connectivity_service.dart';
import '../../component/custom_circular_progress.dart';
import '../../component/shimmer_card.dart';

class VendorsListScreen extends StatefulWidget {
  final String? data;

  VendorsListScreen({Key? key, this.data}) : super(key: key);

  @override
  _VendorsListScreenState createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends State<VendorsListScreen> {
  int franchiseId = 1;
  late double mediaWidth;
  late double screenHeight;
  bool isLoading = false;
  bool isDarkMode = false;
  final ConnectivityService _connectivityService = ConnectivityService();
  List<VendorData> vendorList = [];
  String selectedLocality = "";
  VendorData selectedLocalityData = VendorData();
  String? selectedItem;
  List<String> items = List<String>.generate(10, (index) => "Item $index");
  var currentSelectedItem = VendorData();
  TextEditingController searchController = TextEditingController();
  List<VendorData> filteredVendorList = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    searchController.addListener(_filterVendors);
  }

  void _filterVendors() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredVendorList = vendorList.where((vendor) {
        return vendor.localityName?.toLowerCase().contains(query) ?? false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    DateTime? lastBackPressed;
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          print("DashBoard $didPop");
          if (didPop) return;

          final now = DateTime.now();
          const maxDuration = Duration(seconds: 2);
          final isWarning = lastBackPressed == null ||
              now.difference(lastBackPressed!) > maxDuration;

          if (isWarning) {
            lastBackPressed = DateTime.now();
            CustomAlert.showToast(
                message: "Press back again to exit", context: context);
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            height: screenHeight,
            width: mediaWidth,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/chai_back.png"),
                    opacity: 0.7,
                    fit: BoxFit.cover)),
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Container(
                        width: mediaWidth,
                        margin: EdgeInsets.only(top: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            vendorList.isNotEmpty
                                ? Column(
                                    children: [
                                      // 🔍 Add the search bar
                                      Container(
                                        width: mediaWidth * 0.85,
                                        height: 45,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                        ),
                                        child: TextField(
                                          controller: searchController,
                                          decoration: InputDecoration(
                                            hintText: "Search location...",
                                            prefixIcon: Icon(Icons.location_on,
                                                color: CustomAppColor.Primary),
                                            border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20.0),
                                                borderSide: BorderSide(
                                                    color: Colors.white,
                                                    width: 0.1)),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Align(
                                        alignment: Alignment.center,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                            children: filteredVendorList
                                                    .isNotEmpty
                                                ? filteredVendorList
                                                    .map((item) {
                                                    return GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          isLoading == true;
                                                          selectedLocality =
                                                              selectedLocality
                                                                      .isEmpty
                                                                  ? "${item.localityName}"
                                                                  : "";
                                                          selectedLocalityData =
                                                              item;
                                                        });

                                                        if ((selectedLocality
                                                      .isNotEmpty &&
                                                      selectedLocalityData
                                                          .status
                                                          ?.contains(
                                                          "online") ==
                                                          true) ||
                                                      selectedLocalityData
                                                                    .status
                                                                    ?.contains(
                                                                        "offline") ==
                                                                true) {
                                                    setState(() {
                                                      isLoading = false;
                                                    });
                                                          Helper.saveVendorData(
                                                              selectedLocalityData);
                                                          print("selectedLocalityData::: ${ selectedLocalityData
                                                              .paymentSetting
                                                              ?.merchantId}");
                                                          Helper.saveApiKey(
                                                              selectedLocalityData
                                                                  .paymentSetting
                                                                  ?.apiKey);
                                                          Helper.saveMerchantId(
                                                              selectedLocalityData
                                                                  .paymentSetting
                                                                  ?.merchantId);
                                                          Helper.saveAppId(
                                                              selectedLocalityData
                                                                  .paymentSetting
                                                                  ?.appId);
                                                          _getStoreSettingData(
                                                              selectedLocalityData);
                                                        } else if (selectedLocalityData
                                                                .status
                                                                ?.contains(
                                                                    "offline") ==
                                                            true) {
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                    CustomAlert.showToast(
                                                        context: context,
                                                              message:
                                                                  "This store is closed at the moment.");
                                                        } else {
                                                          setState(() {
                                                            isLoading = false;
                                                          });
                                                    CustomAlert.showToast(
                                                              context: context,
                                                              message:
                                                                  "Select location.");
                                                        }
                                                      },
                                                      child: _buildVendorCard(
                                                          item),
                                                    );
                                                  }).toList()
                                                : [
                                                    Center(
                                                      child: Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 24,
                                                                vertical: 12),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black
                                                              .withOpacity(0.5),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        child: Text(
                                                          "No store available.",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                : ShimmerList(),
                            SizedBox(
                              height: 50,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  isLoading
                      ? CustomCircularProgress()
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ));
  }

  /// Vendor Card
  Widget _buildVendorCard(item) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Container(
              width: mediaWidth * 0.9,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Store Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 55,
                      width: 55,
                      child: item.storeImage?.isNotEmpty == true
                          ? Image.network(
                              item.storeImage!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                    child: ShimmerCard());
                              },
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.black54),
                            )
                          : Image.asset("assets/vendorLoc.png",
                              fit: BoxFit.cover),
                    ),
                  ),

                  // Business Name & Description
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            capitalizeFirstLetter(item.businessName ?? "N/A"),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(
                                capitalizeFirstLetter("${item.localityName}"),
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            capitalizeFirstLetter(item.description ?? ""),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Status Badge
                  _buildStatusBadge(
                    item.status?.contains("online") == true ? "Open" : "Closed",
                    item.status?.contains("online") == true
                        ? Colors.brown
                        : Colors.red,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Status Badge Widget
  Widget _buildStatusBadge(String status, Color color) {
    return Align(
      alignment: Alignment.topLeft,
      child: IntrinsicWidth(
        child: Container(
          margin: EdgeInsets.only(top: 10, right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: color),
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Row(
            children: [
              Text(status,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _fetchData() async {
    setState(() {
      isLoading = false;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackbar(context: context, message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .fetchVendors("/api/v1/vendors/${franchiseId}/get_stores");
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getVendorList(context, apiResponse);
    }
  }

  Widget getVendorList(BuildContext context, ApiResponse apiResponse) {
    VendorListResponse? vendorListResponse =
        apiResponse.data as VendorListResponse?;
    var message = apiResponse.message.toString();
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        setState(() {
          vendorList = vendorListResponse!.vendors!;
          filteredVendorList = vendorList;
          currentSelectedItem = vendorList[0];
        });

        //_showPicker(context: context);

        return Container(); // Return an empty container as you'll navigate away
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

  void _getStoreSettingData(VendorData selectedLocalityData) async {
    setState(() {
      isLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackbar(context: context, message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .fetchStoreSettingData(
              "/api/v1/vendors/${selectedLocalityData.id}/vendor_store_setting");
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getVendorStoreSettingData(context, apiResponse);
    }
  }

  Widget getVendorStoreSettingData(
      BuildContext context, ApiResponse apiResponse) {
    StoreSettingResponse? storeSettingResponse =
        apiResponse.data as StoreSettingResponse?;
    var message = apiResponse.message.toString();
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        Helper.saveStoreSettingData(storeSettingResponse);
        if (mounted) {
          Navigator.pushReplacementNamed(context, "/BottomNavigation",
              arguments: 1);
        }

        return Container(); // Return an empty container as you'll navigate away
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
}
