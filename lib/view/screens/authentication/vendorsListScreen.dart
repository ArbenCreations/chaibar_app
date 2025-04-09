import 'package:ChaiBar/view/component/ShimmerList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/language/Languages.dart';
import '/utils/Helper.dart';
import '/utils/Util.dart';
import '../../../model/response/vendorListResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../theme/CustomAppColor.dart';
import '../../../utils/apis/api_response.dart';
import '../../component/connectivity_service.dart';
import '../../component/toastMessage.dart';

class VendorsListScreen extends StatefulWidget {
  final String? data; // Define the 'data' parameter here

  VendorsListScreen({Key? key, this.data}) : super(key: key);

  @override
  _VendorsListScreenState createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends State<VendorsListScreen> {
  int franchiseId = 1;

  //int franchiseId = 38;

  late double mediaWidth;
  late double screenHeight;
  bool isLoading = false;
  bool isDarkMode = false;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  List<VendorData> vendorList = [];
  String selectedLocality = "";
  VendorData selectedLocalityData = VendorData();
  var placeholderImage =
      'https://upload.wikimedia.org/wikipedia/commons/c/cd/Portrait_Placeholder_Square.png';
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
            CustomToast.showToast(
                message: "Press back again to exit", context: context);
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            height: screenHeight,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/chai_back.jpg"),
                    opacity: 0.7,
                    fit: BoxFit.cover)),
            child: SafeArea(
              child: Column(
                children: [
                  /*SafeArea(
                    child: Align(
                        alignment: Alignment.topCenter,
                        child: IntrinsicWidth(
                          child: Container(
                            //width: mediaWidth * 0.5,
                              margin: EdgeInsets.only(top: 30),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 5),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Select Location",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                        )),
                  ),*/
                  Container(
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
                                      borderRadius: BorderRadius.circular(20.0),
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

                                  // 📝 Filtered list display
                                  SizedBox(height: 20),
                                  Align(
                                    alignment: Alignment.center,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                        children:
                                            filteredVendorList.map((item) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedLocality =
                                                    selectedLocality.isEmpty
                                                        ? "${item.localityName}"
                                                        : "";
                                                selectedLocalityData = item;
                                              });

                                              if (selectedLocality.isNotEmpty &&
                                                      selectedLocalityData
                                                              .status
                                                              ?.contains(
                                                                  "online") ==
                                                          true ||
                                                  selectedLocalityData.status
                                                          ?.contains(
                                                              "offline") ==
                                                      true) {
                                                Helper.saveVendorData(
                                                    selectedLocalityData);
                                                Helper.saveApiKey(
                                                    selectedLocalityData
                                                        .paymentSetting
                                                        ?.apiKey);
                                                Navigator.pushReplacementNamed(
                                                    context,
                                                    "/BottomNavigation",
                                                    arguments: 1);
                                              } else if (selectedLocalityData
                                                      .status
                                                      ?.contains("offline") ==
                                                  true) {
                                                CustomToast.showToast(
                                                    context: context,
                                                    message:
                                                        "This store is closed at the moment.");
                                              } else {
                                                CustomToast.showToast(
                                                    context: context,
                                                    message:
                                                        "Select location.");
                                              }
                                            },
                                            child: _buildVendorCard(item),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
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
            ),
          ),
        ));
  }

  // Separate Widgets for readability

  /* /// Vendor Card
  Widget _buildVendorCard(item) {
    return Center(
      child: Container(
        width: mediaWidth * 0.8,
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: screenHeight * 0.1,
                  width: mediaWidth * 0.9,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                    child: item.storeImage!.isNotEmpty
                        ? Image.network(
                            item.storeImage ?? placeholderImage,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: Colors.black54);
                            },
                          )
                        : Image.asset("assets/vendorLoc.png",
                            fit: BoxFit.fitWidth),
                  ),
                ),
                item.status?.contains("online") == true
                    ? _buildStatusBadge("Open", Colors.green)
                    : _buildStatusBadge("Close", Colors.red),
              ],
            ),
            Container(
              height: screenHeight * 0.08,
              width: mediaWidth * 0.85,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
                gradient: LinearGradient(
                  colors: (item.localityName == selectedLocality)
                      ? [
                          CustomAppColor.Primary,
                          CustomAppColor.Primary.withOpacity(0.4)
                        ]
                      : [Colors.white, Colors.white, Colors.white],
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 200,
                          child: Text(
                            capitalizeFirstLetter("${item.businessName}"),
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              overflow: TextOverflow.fade,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
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
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          capitalizeFirstLetter("${item.description}"),
                          style: TextStyle(fontSize: 11, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }*/

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
                                return const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2));
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
                    item.status?.contains("online") == true ? "Open" : "Close",
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
          margin: EdgeInsets.only(top: 10, left: 10),
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

  Widget _buildHeaderText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/selectStore.png",
          height: 50,
        ),
      ],
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
        print("rwrwr ${vendorListResponse?.vendors?[0].businessName}");

        // countryList = countryListResponse!.countries!;
        //Helper.saveCountryList(vendorList);
        //selectedItem = "${countryListResponse?.countries?[0].flagImageUrl}";
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
}
