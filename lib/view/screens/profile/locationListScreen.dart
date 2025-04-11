import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '/language/Languages.dart';
import '/model/response/locationListResponse.dart';
import '/utils/Helper.dart';
import '/utils/Util.dart';
import '../../../model/response/vendorListResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../theme/CustomAppColor.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/BezierContainer.dart';
import '../../component/connectivity_service.dart';
import '../../component/toastMessage.dart';

class LocationListScreen extends StatefulWidget {
  final String? data; // Define the 'data' parameter here

  LocationListScreen({Key? key, this.data}) : super(key: key);

  @override
  _LocationListScreenState createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  int franchiseId = 1;

  //int franchiseId = 38;

  late double mediaWidth;
  late double screenHeight;
  bool isLoading = false;
  bool isDarkMode = false;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  List<LocationData> locationList = [];
  List<VendorData> vendorList = [
    VendorData(
        businessName: "",
        id: 0,
        createdAt: "",
        updatedAt: "",
        uniqueId: "",
        status: "",
        apiKey: "",
        appId: "",
        description: "",
        detailType: "",
        domainUrl: "",
        gst: 0,
        gstNumber: "",
        hst: 0,
        isDeliver: false,
        isPickup: false,
        isStoreOrderStatusOnline: false,
        localityId: "",
        localityName: "",
        pauseTime: "",
        pickupNumber: "",
        pst: 0,
        selectedCategoryId: 0,
        slug: "",
        storeImage: "",
        theme: "",
        vendorImage: "")
  ];
  String selectedLocality = "";
  VendorData selectedLocalityData = VendorData();
  var placeholderImage =
      'https://upload.wikimedia.org/wikipedia/commons/c/cd/Portrait_Placeholder_Square.png';
  String? selectedItem;
  List<String> items = List<String>.generate(10, (index) => "Item $index");
  var currentSelectedItem = VendorData();

  @override
  void initState() {
    super.initState();
    getStoresList();
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    DateTime? lastBackPressed;
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light
        ),
        leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: Colors.white,)),
        title: Text("Our Locations", style: TextStyle(color: Colors.white),),
      ),
      body: SafeArea(
        child: Container(
          height: screenHeight,
          width: mediaWidth,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 20),
                isLoading
                    ? Column(
                  children: List.generate(2, (index) => _buildShimmerCard()), // Show 5 shimmer placeholders
                )
                    : Column(
                  children: vendorList.map((item) {
                    return _buildVendorCard(item);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  /// Shimmer Placeholder Card
  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        height: screenHeight * 0.1,
        width: mediaWidth * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
             // height: screenHeight * 0.17,
              width: mediaWidth * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Store Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: item.storeImage?.isNotEmpty == true
                          ? Image.network(
                        item.storeImage!,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (_, __, ___) => Container(color: Colors.black54),
                      )
                          : Image.asset("assets/vendorLoc.png", fit: BoxFit.cover),
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
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            capitalizeFirstLetter(item.description ?? ""),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Status Badge
                  _buildStatusBadge(
                    item.status?.contains("online") == true ? "Open" : "Close",
                    item.status?.contains("online") == true ? Colors.green : Colors.red,
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
      alignment: Alignment.bottomRight,
      child: Container(
        margin: EdgeInsets.only(bottom: 10, right: 10),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), color: color),
        padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
        child: Row(
          children: [
            Icon(Icons.store_mall_directory, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(status, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void getStoresList() async {
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
      await Provider.of<MainViewModel>(context, listen: false)
          .fetchVendors("/api/v1/vendors/${franchiseId}/get_stores");
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getStoreList(context, apiResponse);
    }
  }

  Widget getStoreList(BuildContext context, ApiResponse apiResponse) {
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
        });
        //CustomAlert.showToast(context: context, message: "$token");
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
}
