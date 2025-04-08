import 'package:ChaiBar/view/component/ShimmerList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/language/Languages.dart';
import '/model/response/locationListResponse.dart';
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
  List<LocationData> locationList = [];
  List<VendorData> vendorList = [];
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
    _fetchData();
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
          body: SafeArea(
            child: Container(
              height: screenHeight,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/vendorListBack.png"),
                      fit: BoxFit.cover)),
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: IntrinsicWidth(
                        child: Container(
                            //width: mediaWidth * 0.5,
                            margin: EdgeInsets.only(top: 50),
                            padding: EdgeInsets.symmetric(
                                horizontal: 40, vertical: 10),
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
                                  "Select Store",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                      )),
                  /*vendorList.length == 0 ?
                  Center(
                    child: Image.asset(
                      "assets/search.gif",
                      height: 200,
                      width: 200,
                      fit: BoxFit.fill,
                    ),
                  ): SizedBox(),*/
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /*    Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 18.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final now = DateTime.now();
                                  const maxDuration = Duration(seconds: 2);
                                  final isWarning = lastBackPressed == null ||
                                      now.difference(lastBackPressed!) >
                                          maxDuration;

                                  if (isWarning) {
                                    lastBackPressed = DateTime.now();
                                    CustomToast.showToast(
                                        message: "Press back again to exit",
                                        context: context);
                                  } else {
                                    SystemNavigator.pop();
                                  }
                                },
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.black,
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                        ),*/
                        vendorList.length > 0
                            ? Align(
                                alignment: Alignment.center,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    children: vendorList.map((item) {
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
                                                  selectedLocalityData.status
                                                          ?.contains(
                                                              "online") ==
                                                      true ||
                                              selectedLocalityData.status
                                                      ?.contains("offline") ==
                                                  true) {
                                            Helper.saveVendorData(
                                                selectedLocalityData);
                                            Helper.saveApiKey(
                                                selectedLocalityData
                                                    .paymentSetting?.apiKey);
                                            Navigator.pushReplacementNamed(
                                                context, "/BottomNavigation",
                                                arguments: 1);
                                          } else if (selectedLocalityData.status
                                                  ?.contains("offline") ==
                                              true) {
                                            CustomToast.showToast(
                                                context: context,
                                                message:
                                                    "This store is closed at the moment.");
                                          } else {
                                            CustomToast.showToast(
                                                context: context,
                                                message: "Select location.");
                                          }
                                        },
                                        child: _buildVendorCard(
                                            item), // Your vendor card widget
                                      );
                                    }).toList(),
                                  ),
                                ),
                              )
                            : ShimmerList(),
                        SizedBox(
                          height: 50,
                        )
                        /*    currentSelectedItem.localityName != null
                            ? Column(
                                children: [
                                  Text(
                                    "Selected Location",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Please click here to enter the Restaurant",
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey),
                                  ),
                                  SizedBox(height: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedLocality = selectedLocality
                                                .isEmpty
                                            ? "${currentSelectedItem.localityName}"
                                            : "";
                                        selectedLocalityData =
                                            currentSelectedItem;
                                      });

                                      if (selectedLocality.isNotEmpty &&
                                          selectedLocalityData.status
                                                  ?.contains("online") ==
                                              true) {
                                        Helper.saveVendorData(
                                            selectedLocalityData);
                                        Helper.saveApiKey(selectedLocalityData
                                            .paymentSetting?.apiKey);
                                        Navigator.pushReplacementNamed(
                                            context, "/BottomNavigation");
                                      } else {
                                        CustomToast.showToast(
                                            context: context,
                                            message: selectedLocalityData
                                                        .status
                                                        ?.contains(
                                                            "online") ==
                                                    true
                                                ? "This store is closed at the moment."
                                                : "Select location.");
                                      }
                                    },
                                    child: Container(
                                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(20),
                                          bottom: Radius.circular(0)),
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 5,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(20),
                                              child: Image.network(
                                                "${currentSelectedItem.storeImage}",
                                                width: double.infinity,
                                                height: 240,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 10,
                                              left: 10,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: "${currentSelectedItem.status}" == "online" ? Colors.green : Colors.red,
                                                  borderRadius: BorderRadius.circular(5),
                                                ),
                                                child: Text(
                                                  capitalizeFirstLetter("${currentSelectedItem.status}"),
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 0,
                                              left: 0,
                                              right: 0,
                                              child: Container(
                                                padding: EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                                                  color: Colors.white,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${currentSelectedItem.businessName}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "${currentSelectedItem.description}",
                                                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                                        SizedBox(width: 4),
                                                        Text(
                                                          "${currentSelectedItem.localityName}",
                                                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),)
                                  ),
                                ],
                              )
                            : SizedBox(),*/
                        /* Column(
                          children: vendorList.map((item) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedLocality = selectedLocality.isEmpty
                                      ? "${item.localityName}"
                                      : "";
                                  selectedLocalityData = item;
                                });

                                if (selectedLocality.isNotEmpty &&
                                    selectedLocalityData.status
                                            ?.contains("online") ==
                                        true) {
                                  Helper.saveVendorData(selectedLocalityData);
                                  Helper.saveApiKey(
                                      selectedLocalityData.paymentSetting?.apiKey);
                                  Navigator.pushReplacementNamed(
                                      context, "/BottomNavigation");
                                } else {
                                  CustomToast.showToast(
                                      context: context,
                                      message: selectedLocalityData.status
                                                  ?.contains("online") ==
                                              true
                                          ? "This store is closed at the moment."
                                          : "Select location.");
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white,
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: item.storeImage!.isNotEmpty
                                          ? Image.network(
                                              item.storeImage ?? placeholderImage,
                                              fit: BoxFit.cover,
                                              width: mediaWidth * 0.85,
                                              height: screenHeight * 0.17,
                                            )
                                          : Image.asset(
                                              "assets/vendorLoc.png",
                                              fit: BoxFit.fitWidth,
                                              height: screenHeight * 0.25,
                                            ),
                                    ),
                                    Container(
                                      height: screenHeight * 0.17,
                                      width: mediaWidth * 0.85,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: (item.localityName ==
                                                  selectedLocality)
                                              ? [
                                                  CustomAppColor.Primary,
                                                  CustomAppColor.Primary
                                                      .withOpacity(0.4)
                                                ]
                                              : [
                                                  Colors.black54,
                                                  Colors.black54,
                                                  Colors.black54
                                                ],
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Container(
                                                  width: 200,
                                                  child: Text(
                                                    capitalizeFirstLetter(
                                                        "${item.businessName}"),
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  capitalizeFirstLetter(
                                                      "${item.description}"),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  bottom: 10, right: 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                color: item.status
                                                            ?.contains("online") ==
                                                        true
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2, horizontal: 5),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.store_mall_directory,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    item.status?.contains(
                                                                "online") ==
                                                            true
                                                        ? "Open"
                                                        : "Closed",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),*/
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

  /// Vendor Card
  Widget _buildVendorCard(item) {
    return Center(
      child: Container(
        width: mediaWidth / 1.5,
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
                  height: screenHeight * 0.12,
                  width: mediaWidth * 0.85,
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
                              size: 14,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              capitalizeFirstLetter("${item.localityName}"),
                              style:
                                  TextStyle(fontSize: 12, color: Colors.black),
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
  }

  /// Status Badge Widget
  Widget _buildStatusBadge(String status, Color color) {
    return Align(
      alignment: Alignment.topLeft,
      child: IntrinsicWidth(
        child: Container(
          margin: EdgeInsets.only(top: 10, left: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: color),
          padding: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
          child: Row(
            children: [
              Icon(Icons.store_mall_directory, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(status,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
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
