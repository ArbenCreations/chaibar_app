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

class _VendorsListScreenState extends State<VendorsListScreen>
    with WidgetsBindingObserver {
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
  late MainViewModel _mainViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainViewModel = Provider.of<MainViewModel>(context, listen: false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed!');
      _fetchData();
      searchController.addListener(_filterVendors);
    } else if (state == AppLifecycleState.paused) {
      print('App paused');
    }
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
          resizeToAvoidBottomInset: false,
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
                  Positioned.fill(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 100, top: 10),
                        // Space for keyboard
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            vendorList.isNotEmpty
                                ? _buildVendorSection()
                                : ShimmerList(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                  isLoading ? CustomCircularProgress() : SizedBox(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildVendorCard(item) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Store Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 65,
                  width: 65,
                  child: item.storeImage?.isNotEmpty == true
                      ? Image.network(
                          item.storeImage!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: ShimmerCard());
                          },
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[400]),
                        )
                      : Image.asset("assets/vendorLoc.png", fit: BoxFit.cover),
                ),
              ),

              const SizedBox(width: 14),

              // Business Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Business Name
                    Text(
                      capitalizeFirstLetter(item.businessName ?? "N/A"),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: Colors.brown),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            capitalizeFirstLetter(
                                item.localityName ?? "Unknown"),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Description
                   /* Text(
                      capitalizeFirstLetter(item.description ?? ""),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),*/
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                capitalizeFirstLetter(item.description ?? ""),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            /*  const SizedBox(width: 8),

              // Status Badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  StatusBadgeWidget(
                    status: item.status?.contains("online") == true
                        ? "Open"
                        : "Closed",
                    color: item.status?.contains("online") == true
                        ? Colors.green
                        : Colors.redAccent,
                  )
                ],
              ),*/
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVendorSection() {
    return Column(
      children: [
        Container(
          width: mediaWidth * 0.85,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search location...",
              prefixIcon:
                  Icon(Icons.location_on, color: CustomAppColor.Primary),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Colors.white, width: 0.1)),
            ),
          ),
        ),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.center,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: filteredVendorList.isNotEmpty
                  ? filteredVendorList.map((item) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            isLoading == true;
                            selectedLocality = selectedLocality.isEmpty
                                ? "${item.localityName}"
                                : "";
                            selectedLocalityData = item;
                          });

                          if ((selectedLocality.isNotEmpty &&
                        selectedLocalityData.status
                            ?.contains("online") ==
                            true) ||
                        selectedLocalityData.status
                            ?.contains("offline") ==
                            true) {
                      setState(() {
                        isLoading = false;
                      });
                      Helper.saveVendorData(selectedLocalityData);
                      print(
                          "selectedLocalityData::: ${selectedLocalityData
                              .paymentSetting?.merchantId}");
                      Helper.saveApiKey(
                          selectedLocalityData.paymentSetting?.apiKey);
                      Helper.saveMerchantId(selectedLocalityData
                          .paymentSetting?.merchantId);
                      Helper.saveAppId(
                          selectedLocalityData.paymentSetting?.appId);
                      _getStoreSettingData(selectedLocalityData);
                    } else if (selectedLocalityData.status
                        ?.contains("offline") ==
                        true) {
                      setState(() {
                        isLoading = false;
                      });
                      CustomAlert.showToast(
                          context: context,
                          message: "This store is closed at the moment.");
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                      CustomAlert.showToast(
                          context: context, message: "Select location.");
                    }
                  },
                  child: _buildVendorCard(item),
                );
              }).toList()
                  : [
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "No store available.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
    );
  }

  void _fetchData() async {
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
      await _mainViewModel
          .fetchVendors("/api/v1/vendors/${franchiseId}/get_stores");
      ApiResponse apiResponse = _mainViewModel.response;
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
          vendorList.clear();
          filteredVendorList.clear();
          vendorList = vendorListResponse!.vendors!;
          filteredVendorList = vendorList;
          currentSelectedItem = vendorList[0];
        });
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
      await _mainViewModel.fetchStoreSettingData(
          "/api/v1/vendors/${selectedLocalityData.id}/vendor_store_setting");
      ApiResponse apiResponse = _mainViewModel.response;
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
