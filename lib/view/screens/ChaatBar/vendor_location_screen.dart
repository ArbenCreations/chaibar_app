import 'package:ChaatBar/languageSection/Languages.dart';
import 'package:ChaatBar/model/response/rf_bite/locationListResponse.dart';
import 'package:ChaatBar/utils/Helper.dart';
import 'package:ChaatBar/utils/Util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../model/apis/api_response.dart';
import '../../../model/response/rf_bite/vendorListResponse.dart';
import '../../../theme/AppColor.dart';
import '../../../view_model/main_view_model.dart';
import '../../component/connectivity_service.dart';
import '../../component/toastMessage.dart';

class VendorLocationScreen extends StatefulWidget {
  final String? data; // Define the 'data' parameter here

  VendorLocationScreen({Key? key, this.data}) : super(key: key);

  @override
  _VendorLocationScreenState createState() => _VendorLocationScreenState();
}

class _VendorLocationScreenState extends State<VendorLocationScreen> {
  int franchiseId = 1;
  //int franchiseId = 38;

  late double screenWidth;
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

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColor.PRIMARY,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
          body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  width: screenWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        _buildHeaderText(),
                        SizedBox(height: 20),
                        _buildVendorList(),
                        SizedBox(height: 18),
                        _buildFooter(context: context, text: "Proceed"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (isLoading) _buildLoadingIndicator(),
          ],
        ),
      )),
    );
  }

  // Separate Widgets for readability

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          "Choose your",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        Text(
          "Location",
          style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: AppColor.PRIMARY),
        ),
        SizedBox(height: 4,),
        Text(
          "Select your location and click on proceed",
          style: TextStyle(
              fontSize: 11, ),
        ),
      ],
    );
  }

  Widget _buildVendorList() {
    return Container(
      constraints: BoxConstraints(
          maxHeight: screenHeight * 0.6, minHeight: screenHeight * 0.5),
      child: ListView.builder(
        /*gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 2.0,
          mainAxisSpacing: 10.0,
        ),*/
        padding: EdgeInsets.symmetric(vertical:5),
        itemCount: vendorList.length,
        itemBuilder: (context, index) {
          final item = vendorList[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                print("selectedLocality : ${item.localityName} ${item.status}");
                //selectedLocality = "${item.localityName}";
                selectedLocality.isEmpty
                    ? selectedLocality = "${item.localityName}"
                    : selectedLocality = "";
                selectedLocalityData = item;
                print("selectedLocalitySelected : $selectedLocality");
              });
            },
            child: Center(
              child: Card(
                child: Stack(
                  children: [
                    Container(
                      height: screenHeight * 0.16,
                      width: screenWidth * 0.85,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.5),),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.5),
                        child: Image.network((item.storeImage ?? placeholderImage),fit: BoxFit.cover),
                      ),
                    ),
                    Container(
                      height: screenHeight * 0.16,
                      width: screenWidth * 0.82,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(11),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors:(item.localityName == selectedLocality) ?  [
                            AppColor.PRIMARY,
                            Colors.transparent
                          ]   :[
                            Colors.black,
                            Colors.black54,
                            Colors.black54,
                            Colors.transparent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  child: Text(
                                    capitalizeFirstLetter("${item.localityName}"),
                                    style: TextStyle(
                                      fontSize: 22,
                                      color: AppColor.WHITE,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                item.status?.contains("online") == true
                                    ? SizedBox()
                                    : Center(
                                    child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(3),
                                            color: Colors.red),
                                        padding: EdgeInsets.symmetric(vertical: 2,horizontal:3),
                                        child: Text(
                                          "Store is Closed",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold),
                                        )))
                              ],
                            ),
                          ),
                          /*selectedLocality.isNotEmpty ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Icon(Icons.check_circle_sharp,color: AppColor.PRIMARY,),
                          ) : SizedBox()*/
                          /*Spacer(),
                          Card(
                            shape: CircleBorder(),
                            color: (item.localityName == selectedLocality)
                                ? AppColor.WHITE
                                : AppColor.PRIMARY,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: Icon(Icons.arrow_forward_ios,
                                  size: 16,
                                  color: (item.localityName == selectedLocality)
                                      ? AppColor.PRIMARY
                                      : AppColor.WHITE),
                            ),
                          ),
                          SizedBox(width: 5,),*/
                          /*item.status == "online"
                              ? SizedBox()
                              : SizedBox(
                            height: 5,
                          ),
                          */
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.transparent),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildFooter({
    required BuildContext context,
    required String text,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Column(
        children: [
          SizedBox(
            width: screenWidth * 0.55,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                print("selectedLocalityData ${selectedLocalityData.status}");
                if (selectedLocality.isNotEmpty &&
                    selectedLocalityData.status?.contains("online") == true) {
                  Helper.saveVendorData(selectedLocalityData);
                  Helper.saveVendorTheme(selectedLocalityData.theme);
                  print("${selectedLocalityData.localityName}");
                  Navigator.pushReplacementNamed(context, "/BottomNav");
                } else if (selectedLocalityData.status?.contains("online") == true) {
                  ToastComponent.showToast(
                      context: context, message: "This store is closed at the moment.");
                } else {
                  ToastComponent.showToast(
                      context: context, message: "Select location.");
                }
              },
              child: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  backgroundColor: selectedLocality.isNotEmpty &&
                      selectedLocalityData.status?.contains("online") == true ? AppColor.SECONDARY  : Colors.grey ,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18))),
            ),
          ),
        ],
      ),
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
