import 'package:ChaiBar/model/db/ChaiBarDB.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../component/CustomAlert.dart';
import '../../../language/Languages.dart';
import '../../../model/request/editProfileRequest.dart';
import '../../../model/response/couponListResponse.dart';
import '../../../model/response/getViewRewardPointsResponse.dart';
import '../../../model/response/profileResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../theme/CustomAppColor.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';
import '../../component/toastMessage.dart';

class ProfileScreen extends StatefulWidget {
  //final Function(ThemeMode) onThemeChanged;

  ProfileScreen();

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  bool isInternetConnected = true;
  bool isDarkMode = false;
  bool editProfile = false;
  late double mediaWidth;
  late double screenHeight;
  String? userId = "";
  String? firstName = "";
  String? lastName = "";
  String? phoneNo = "";
  String? email = "";
  String? imageUrl = "";
  String active = "0";
  String completed = "0";
  String favorites = "0";
  static const maxDuration = Duration(seconds: 2);
  bool isDataLoading = false;
  late ChaiBarDB database;
  var _connectivityService = ConnectivityService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  var selectedAvatar =
      "https://icons.iconarchive.com/icons/hopstarter/superhero-avatar/256/Avengers-Captain-America-icon.png";

  String? theme = "";
  String? vendorId = "";
  String? domainUrl = "";
  int? customerId = 0;
  int? totalPoints = 0;
  Color primaryColor = CustomAppColor.PrimaryAccent;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];

  final GlobalKey _buttonKey = GlobalKey();
  bool mExpanded = false;
  String mSelectedText = "";
  final List<String> themeType = ["Light", "Dark", "Default"];
  String selectedValue = "";

  Uri _url = Uri.parse('');

  @override
  void initState() {
    super.initState();
    Helper.getProfileDetails().then((onValue) {
      setState(() {
        customerId = int.parse("${onValue?.id ?? 0}");
        totalPoints = int.parse("${onValue?.totalPoints ?? 0}");
      });
      print("Total points:: $totalPoints");
    });

    Helper.getVendorDetails().then((onValue) {
      setState(() {
        vendorId = "${onValue?.id}";
        print("domainUrl${onValue?.domainUrl}");
        _url = Uri.parse("${onValue?.domainUrl}");
        //setThemeColor();
      });
    });

    Helper.getAppThemeMode().then((appTheme) {
      setState(() {
        //print("App theme $appTheme");
        selectedValue = "$appTheme" != "null" ? "$appTheme" : themeType.first;
      });
    });
    $FloorChaiBarDB
        .databaseBuilder('basic_structure_database.db')
        .build()
        .then((value) async {
      this.database = value;
    });
    firstName = "";
    lastName = "";
    email = "";
    isDataLoading = true;
    _fetchDataFromPref();
    _fetchData();
    _getRedeemPointsData();
  }

  void openUrl() async {
    final Uri url = Uri.parse("${domainUrl ?? ""}");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch $url";
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    mediaWidth = MediaQuery.of(context).size.width;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
        backgroundColor: CustomAppColor.Background,
        /*   appBar: AppBar(
          leading: SizedBox(),
          systemOverlayStyle:
              SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
          centerTitle: true,
          title: Text("Profile",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        ),*/
        body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/profileBack.png"),
                  fit: BoxFit.cover)),
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 14),
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            child: Image.asset(
                              "assets/userIcon.png",
                              width: 120,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          SizedBox(height: 15),
                          Text(
                              "${firstName?.toUpperCase() ?? ""} ${lastName?.toUpperCase() ?? ""}",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          SizedBox(height: 2),
                          Text("${email ?? ""}",
                              style:
                                  TextStyle(fontSize: 13, color: Colors.white)),
                          SizedBox(height: 2),
                          phoneNo != "null"
                              ? Text(
                                  "Mobile: ${phoneNo == "null" ? "" : phoneNo}",
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.white))
                              : SizedBox(),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double widthFactor =
                            (constraints.maxWidth / 400).clamp(0.8, 1.2);

                        return GestureDetector(
                          onTap: () {
                            _launchUrl();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildCount("$active", "Active", widthFactor),
                              _buildCount(
                                  "$totalPoints", "Reward Points", widthFactor),
                              _buildCount(
                                  "$completed", "Completed", widthFactor),
                            ],
                          ),
                        );
                      },
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25)),
                      child: Column(
                        children: [
                          SizedBox(height: 25),
                          _buildSettingsItem(Icons.edit, "Personal Information",
                              "Edit your profile", "/EditInformationScreen"),
                          _buildSettingsItem(Icons.store_sharp, "Locations",
                              "Click here for offers", "/LocationListScreen"),
                          _buildSettingsItem(Icons.logout, "Logout", "", ""),
                        ],
                      ),
                    )
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCount(String count, String label, double widthFactor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: CustomAppColor.BottomNavColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              count,
              maxLines: 2,
              style: TextStyle(
                fontSize: widthFactor * 14, // Adjust font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            SizedBox(
              width: widthFactor * 90, // Adjust width
              child: Text(
                label,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: widthFactor * 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      IconData icon, String title, String subtitle, String route) {
    return ListTile(
      leading: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: CustomAppColor.Background,
              borderRadius: BorderRadius.all(Radius.circular(30))),
          child: Icon(
            icon,
            color: CustomAppColor.PrimaryAccent,
            size: 20,
          )),
      title: Text(title,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      /* subtitle: subtitle.isNotEmpty
          ? Text(
              subtitle,
              style: TextStyle(fontSize: 12),
            )
          : null,*/
      trailing: Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        if (route.isNotEmpty) {
          Navigator.pushNamed(context, route);
        } else {
          _showLogOutDialog();
        }
      },
    );
  }

  Future<void> _fetchData() async {
    bool isConnected = await _connectivityService.isConnected();
    print(("isConnected - ${isConnected}"));
    if (!isConnected) {
      setState(() {
        isLoading = false;
        isInternetConnected = false;
        CustomSnackBar.showSnackbar(context: context, message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      hideKeyBoard();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        await Future.delayed(Duration(milliseconds: 2));
        await Provider.of<MainViewModel>(context, listen: false)
            .fetchProfile("/api/v1/app/customers/$vendorId/get_profile");
        if (mounted) {
          ApiResponse apiResponse =
              Provider.of<MainViewModel>(context, listen: false).response;
          getProfileResponse(context, apiResponse);
        }
      }
    }
  }

  Future<void> _getRedeemPointsData() async {
    bool isConnected = await _connectivityService.isConnected();
    print(("isConnected - ${isConnected}"));
    if (!isConnected) {
      setState(() {
        isLoading = false;
        isInternetConnected = false;
        CustomSnackBar.showSnackbar(context: context, message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      hideKeyBoard();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        await Future.delayed(Duration(milliseconds: 2));
        await Provider.of<MainViewModel>(context, listen: false)
            .fetchRedeemPointsApi("api/v1/app/rewards/view_points");
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getRedeemPointResponse(context, apiResponse);
      }
    }
  }

  Future<void> _saveChanges() async {
    bool isConnected = await _connectivityService.isConnected();
    print(("isConnected - ${isConnected}"));
    if (!isConnected) {
      setState(() {
        isLoading = false;
        isInternetConnected = false;
        CustomSnackBar.showSnackbar(context: context, message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      hideKeyBoard();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        EditProfileRequest request = EditProfileRequest(
            email: _emailController.text,
            firstName: _nameController.text,
            lastName: _lastNameController.text);
        await Future.delayed(Duration(milliseconds: 2));
        await Provider.of<MainViewModel>(context, listen: false).editProfile(
            "/api/v1/app/customers/$userId/update_profile", request);
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getProfileResponse(context, apiResponse);
      }
    }
  }

  Future<Widget> getProfileResponse(
      BuildContext context, ApiResponse apiResponse) async {
    ProfileResponse? mediaList = apiResponse.data as ProfileResponse?;
    print("apiResponse${apiResponse.status}");
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        await Helper.saveProfileDetails(mediaList);
        print("${mediaList?.completedOrders}");
        if (editProfile) {
          Navigator.pop(context);
          CustomAlert.showToast(
              context: context, message: "${apiResponse.message}");
        }

        _fetchDataFromPref();

        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        // _fetchDataFromPref();
        print("Message : ${apiResponse.message}");
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        } else {
          CustomSnackBar.showSnackbar(context: context, message: 'Something went wrong!');
        }
        print(apiResponse.message);
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

  Future<Widget> getRedeemPointResponse(
      BuildContext context, ApiResponse apiResponse) async {
    GetViewRewardPointsResponse? response =
        apiResponse.data as GetViewRewardPointsResponse?;
    print("apiResponse${apiResponse.status}");
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        totalPoints = response?.totalPoints;
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        // _fetchDataFromPref();
        print("Message : ${apiResponse.message}");
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Something went wrong.'),
              duration: maxDuration,
            ),
          );
        }
        print(apiResponse.message);
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

  void _fetchDataFromPref() async {
    Helper.getProfileDetails().then((profile) {
      setState(() {
        isLoading = false;
        firstName = "${profile?.firstName}";
        userId = "${profile?.id}";
        lastName = "${profile?.lastName}";
        phoneNo = "${profile?.phoneNumber}";
        email = "${profile?.email}";
        active = "${profile?.activeOrders ?? 0}";
        completed = "${profile?.completedOrders ?? 0}";
        favorites = "${profile?.favorites ?? 0}";
        //isUsernameRetrieved = true;
      });
      print("$firstName");
      print("profileResponse?.favorites :: ${profile?.favorites}");
    });
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

  Future<void> _showLogOutDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20), // Adjust the radius as needed
          ),
          insetPadding: EdgeInsets.zero,
          elevation: 5,
          titleTextStyle: TextStyle(
              fontSize: 20,
              color: isDarkMode ? Colors.white : CustomAppColor.Primary,
              fontWeight: FontWeight.bold),
          title: Center(
              child: Text(
            "Logout",
            style: TextStyle(fontSize: 20, color: CustomAppColor.PrimaryAccent),
          )),
          content: IntrinsicHeight(
            child: Container(
              //height: screenHeight * 0.25,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                          child: Text(
                        "Are you sure you want to logout?",
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: mediaWidth * 0.3,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.black54),
                          ),
                          child: Text(
                            "No",
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: mediaWidth * 0.3,
                        child: TextButton(
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  CustomAppColor.PrimaryAccent)),
                          child: Text(
                            "Yes",
                            style: TextStyle(fontSize: 12),
                          ),
                          onPressed: () {
                            Helper.clearAllSharedPreferencesForLogout();
                            database.favoritesDao.clearAllFavoritesProduct();
                            database.cartDao.clearAllCartProduct();
                            database.categoryDao.clearAllCategories();
                            database.productDao.clearAllProducts();
                            database.cartDao.clearAllCartProduct();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/SignInScreen',
                              (Route<dynamic> route) => false,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[],
        );
      },
    );
  }

  void openBottomSheet(BuildContext context,
      List<PrivateCouponDetailsResponse>? couponsResponse) {
    showModalBottomSheet(
      context: context,
      shape: Border(),
      scrollControlDisabledMaxHeightRatio: 0.85,
      isScrollControlled: false,
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          // Optional padding for better spacing
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // Ensures the column takes only the required space
            children: [
              // Static "Close" button
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: ShapeDecoration(
                      color: CustomAppColor.Primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: Text(
                      "Close",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // Static text outside the list
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  "Coupons",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),

              // Divider line
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                width: double.infinity,
                color: isDarkMode ? Colors.white : Colors.transparent,
                height: 0.4,
              ),

              // List of coupons inside a SingleChildScrollView to prevent overflow
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListView.builder(
                        itemCount: couponsResponse?.length ?? 0,
                        // Make sure it's safe to access
                        shrinkWrap: true,
                        // Ensures ListView takes only as much space as needed
                        physics: NeverScrollableScrollPhysics(),
                        // Prevents scrolling conflicts with SingleChildScrollView
                        padding: EdgeInsets.only(bottom: 10),
                        itemBuilder: (context, index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              appliedCouponWidget(couponsResponse![index]),
                              // Your existing widget
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 10),
                                width: mediaWidth * 0.5,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.transparent,
                                height: 0.4,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget appliedCouponWidget(PrivateCouponDetailsResponse couponsResponse) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? CustomAppColor.DarkCardColor : Colors.blue[50],
      ),
      padding: EdgeInsets.only(left: 10, right: 0, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: CustomAppColor.PrimaryAccent),
              padding: EdgeInsets.all(5),
              child: Icon(
                Icons.discount,
                color: Colors.white,
                size: 18,
              )),
          SizedBox(
            width: 15,
          ),
          Container(
            width: mediaWidth * 0.75,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*  Text(
                  "Expire At => ${convertDateTimeFormat("${couponsResponse?.expireAt?.toString().toUpperCase()}")}",
                  style: TextStyle(fontSize: 11),
                ),*/
                SizedBox(
                  height: 2,
                ),
                Text("Code : ${couponsResponse?.couponCode?.toUpperCase()}",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(
                  height: 2,
                ),
                Text("${couponsResponse?.description?.toUpperCase()}",
                    style:
                        TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
                SizedBox(
                  height: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Min Amt. : \$${couponsResponse.minCartAmt?.toUpperCase()}",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal)),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                        "Max Amt. : \$${couponsResponse.maxDiscountAmt?.toUpperCase()}",
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal))
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text("You can use coupon code to apply.",
                      style: TextStyle(
                          fontSize: 10, fontWeight: FontWeight.normal)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}
