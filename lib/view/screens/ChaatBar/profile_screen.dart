import 'package:ChaatBar/model/db/ChaatBarDatabase.dart';
import 'package:ChaatBar/model/request/editProfileRequest.dart';
import 'package:ChaatBar/model/request/getCouponListRequest.dart';
import 'package:ChaatBar/model/response/couponListResponse.dart';
import 'package:ChaatBar/view/component/toastMessage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../languageSection/Languages.dart';
import '../../../model/apis/api_response.dart';
import '../../../model/response/rf_bite/profileResponse.dart';
import '../../../theme/AppColor.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../view_model/main_view_model.dart';
import '../../component/circluar_profile_image.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';

class ProfileScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;

  ProfileScreen({required this.onThemeChanged});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLoading = false;
  bool isInternetConnected = true;
  bool isDarkMode = false;
  bool editProfile = false;
  late double screenWidth;
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
  late ChaatBarDatabase database;
  final ConnectivityService _connectivityService = ConnectivityService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? theme = "";
  String? vendorId = "";
  Color primaryColor = AppColor.SECONDARY;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];

  final GlobalKey _buttonKey = GlobalKey();
  bool mExpanded = false;
  String mSelectedText = "";
  final List<String> themeType = ["Light", "Dark", "Default"];
  String selectedValue = "";

  @override
  void initState() {
    super.initState();
    Helper.getVendorDetails().then((onValue) {
      print("theme : $onValue");
      setState(() {
        theme = onValue?.theme;
        vendorId = "${onValue?.id}";
        //setThemeColor();
      });
    });

    Helper.getAppThemeMode().then((appTheme) {
      setState(() {
        //print("App theme $appTheme");
        selectedValue = "$appTheme" != "null" ? "$appTheme" : themeType.first;
      });
    });
    $FloorChaatBarDatabase
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
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacementNamed(context, "/BottomNav");
      },
      child: Scaffold(
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 30),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "$firstName $lastName",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            CircularProfileImage(
                                size: 70,
                                imageUrl: imageUrl,
                                name: "${firstName}",
                                needTextLetter: true,
                                placeholderImage: "",
                                isDarkMode: isDarkMode)
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Email: $email",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "Mobile: $phoneNo",
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          width: screenWidth * 0.75,
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            shadowColor: Colors.black,
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 15),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  _buildCount("$active", "Active"),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  _buildCount("$completed", "Completed"),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  _buildCount("$favorites", "Favorites"),
                                  SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 18,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        shadowColor: Colors.black,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 2,
                            ),
                            _buildItem(
                                Icons.edit_document,
                                "Edit Personal Information",
                                "Edit your personal Information",
                                "EditInformationScreen"),
                            _buildItem(Icons.card_giftcard_rounded,
                                "Available Coupons", "Click here for exciting offers!", ""),
                            //_buildItem(Icons.language,"Language","English",""),
                            _buildTheme(),
                            /*_buildItem(Icons.contact_support_rounded,
                                "Help & Support", "Help & Support", "")*/
                            /* _buildItem(Icons.perm_contact_cal_sharp,
                                "Contact Us", "Contact Us", ""),*/
                            _buildItem(
                                Icons.logout, "Logout", "", "SignInScreen"),
                            SizedBox(
                              height: 2,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      /* Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        shadowColor: Colors.black,
                        child: Column(
                          children: [
                            SizedBox(height: 2,),
                            SizedBox(height: 2,),
                          ],
                        ),
                      ),
                      SizedBox(height: 5,),
                      Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        shadowColor: Colors.black,
                        child: Column(
                          children: [
                            SizedBox(height: 2,),
                            SizedBox(height: 2,),
                          ],
                        ),
                      )*/
                    ],
                  ),
                ],
              ),
            ),
            isLoading
                ? Stack(
                    children: [
                      // Block interaction
                      ModalBarrier(
                        dismissible: false,
                      ),
                      // Loader indicator
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
      IconData icon, String value, String detail, String navigation) {
    return GestureDetector(
      onTap: () {
        if (value == "Logout") {
          _showLogOutDialog();
        } else if (value == "Edit Personal Information") {
          _showEditProfileDialog();
        } else if (value == "Available Coupons") {
          setState(() {
            isLoading = true;
          });
          _getCouponDetails();

          //Navigator.pushNamed(context, "/$navigation");
        }
      },
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 22,
                color: primaryColor,
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  value != "Logout"
                      ? Text(
                          detail,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[500]),
                        )
                      : SizedBox(),
                ],
              ),
              Spacer(),
              /*Text("$detail",
                  style: TextStyle(fontSize: 13,color: Colors.grey),)*/
              value != "Logout"
                  ? Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCount(String count, String text) {
    return Column(
      children: [
        Text(
          "$count",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600]),
        ),
        Text(
          "$text",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.normal),
        )
      ],
    );
  }

  Widget _buildTheme() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.looks,
                    size: 22,
                    color: primaryColor,
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Theme",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      Text(
                        "Light/Dark/Default",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Card(
              elevation: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(color: Colors.grey, width: 0.5)),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      final RenderBox button = _buttonKey.currentContext
                          ?.findRenderObject() as RenderBox;
                      final RenderBox overlay = Overlay.of(context)
                          .context
                          .findRenderObject() as RenderBox;
                      final RelativeRect position = RelativeRect.fromRect(
                        Rect.fromPoints(
                          button.localToGlobal(Offset.zero, ancestor: overlay),
                          button.localToGlobal(
                              button.size.bottomRight(Offset.zero),
                              ancestor: overlay),
                        ),
                        Offset.zero & overlay.size,
                      );
                      showMenu(
                        context: context,
                        position: position,
                        items: themeType.map((item) {
                          return PopupMenuItem<String>(
                            value: item,
                            child: Text(
                              capitalizeFirstLetter("${item}"),
                              style: TextStyle(color: AppColor.WHITE),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ).then((value) async {
                        if (value != null) {
                          await Helper.saveAppThemeMode(value);

                          setState(() {
                            selectedValue = value;

                            if ("$value" == "Default") {
                              print("value $value");
                              widget.onThemeChanged(ThemeMode.system);
                              /* Provider.of<ThemeNotifier>(
                                            context,
                                            listen: false)
                                                                                              .setThemeByName('$value');*/
                            } else if ("$value" == "Light") {
                              widget.onThemeChanged(ThemeMode.light);
                            } else if ("$value" == "Dark") {
                              widget.onThemeChanged(ThemeMode.dark);
                            } else {
                              widget.onThemeChanged(ThemeMode.light);
                            }
                          });
                        }
                      });
                    },
                    child: Row(
                      key: _buttonKey,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        selectedValue.isEmpty
                            ? Container(width: 40)
                            : Text(
                                capitalizeFirstLetter("${selectedValue}"),
                                style: TextStyle(fontSize: 13),
                              ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.keyboard_arrow_down_sharp,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (mExpanded)
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
              color: Colors.white,
              child: Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: themeType.map((city) {
                    return ListTile(
                      title: Align(
                          alignment: Alignment.centerRight, child: Text(city)),
                      onTap: () {
                        setState(() {
                          mSelectedText = city;
                          mExpanded = false;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _fetchData() async {
    bool isConnected = await _connectivityService.isConnected();
    print(("isConnected - ${isConnected}"));
    if (!isConnected) {
      setState(() {
        isLoading = false;
        isInternetConnected = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Languages.of(context)!.labelNoInternetConnection),
            duration: maxDuration,
          ),
        );
      });
    } else {
      hideKeyBoard();
      if (mounted) {
        setState(() {
          isLoading = true;
        });
        await Future.delayed(Duration(milliseconds: 2));
        await Provider.of<MainViewModel>(context, listen: false)
            .fetchProfile("/api/v1/app/customers/$vendorId/get_profile");
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getProfileResponse(context, apiResponse);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Languages.of(context)!.labelNoInternetConnection),
            duration: maxDuration,
          ),
        );
      });
    } else {
      hideKeyBoard();
      if (mounted) {
        setState(() {
          isLoading = true;
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
          ToastComponent.showToast(
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

  Future<void> _getCouponDetails() async {
    bool isConnected = await _connectivityService.isConnected();
    print(("isConnected - ${isConnected}"));
    if (!isConnected) {
      setState(() {
        isLoading = false;
        isInternetConnected = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(Languages.of(context)!.labelNoInternetConnection),
            duration: maxDuration,
          ),
        );
      });
    } else {
      hideKeyBoard();
      if (mounted) {
        setState(() {
          isLoading = true;
        });
        GetCouponListRequest request =
            GetCouponListRequest(vendorId: int.parse("${vendorId}"));
        await Future.delayed(Duration(milliseconds: 2));
        await Provider.of<MainViewModel>(context, listen: false)
            .fetchCouponList(
                "/api/v1/app/customers/get_customer_coupons", request);
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getCouponResponse(context, apiResponse);
      }
    }
  }

  Future<Widget> getCouponResponse(
      BuildContext context, ApiResponse apiResponse) async {
    CouponListResponse? couponList = apiResponse.data as CouponListResponse?;
    print("apiResponse${apiResponse.status}");
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        openBottomSheet(context, couponList?.couponsResponse);
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
    await Future.delayed(Duration(milliseconds: 2));
    Helper.getProfileDetails().then((profile) {
      setState(() {
        isLoading = false;
        print("$firstName");
        firstName = "${profile?.firstName}";
        userId = "${profile?.id}";
        lastName = "${profile?.lastName}";
        phoneNo = "${profile?.phoneNumber}";
        email = "${profile?.email}";

        active = "${profile?.activeOrders ?? 0}";
        completed = "${profile?.completedOrders ?? 0}";
        favorites = "${profile?.favorites ?? 0}";
        print("profileResponse?.favorites :: ${profile?.favorites}");
        //isUsernameRetrieved = true;
      });
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
              color: isDarkMode ? Colors.white : AppColor.PRIMARY,
              fontWeight: FontWeight.bold),
          title: Center(
              child: Text(
            "Logout",
            style: TextStyle(fontSize: 20),
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
                        height: 10,
                      ),
                      Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: AppColor.PRIMARY),
                          child: Icon(
                            Icons.logout_outlined,
                            size: 55,
                            color: Colors.white,
                          )),
                      SizedBox(
                        height: 15,
                      ),
                      Center(
                          child: Text(
                        "Are you sure you want to logout?",
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
                        width: screenWidth * 0.25,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(Colors.redAccent),
                          ),
                          child: Text("No"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        width: screenWidth * 0.33,
                        child: TextButton(
                          child: Text("Yes"),
                          onPressed: () {
                            Helper.clearAllSharedPreferences();
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

  Future<void> _showEditProfileDialog() async {
    _nameController.text = "$firstName";
    _lastNameController.text = "$lastName";
    _emailController.text = "$email";
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Adjust the radius as needed
          ),
          insetPadding: EdgeInsets.symmetric(horizontal: 28, vertical: 5),
          elevation: 5,
          icon: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    size: 20,
                  ))),
          iconPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          titleTextStyle: TextStyle(
              fontSize: 20,
              color: isDarkMode ? Colors.white : AppColor.PRIMARY,
              fontWeight: FontWeight.bold),
          title: Center(
              child: Text(
            "Edit Profile",
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
                        height: 10,
                      ),
                      Row(
                        children: [
                          _buildNameInput(
                              context,
                              Languages.of(context)!.labelName,
                              _nameController,
                              Icon(
                                Icons.person,
                                size: 18,
                                color: AppColor.SECONDARY,
                              )),
                          SizedBox(
                            width: 8,
                          ),
                          _buildNameInput(
                              context,
                              Languages.of(context)!.labelLastname,
                              _lastNameController,
                              Icon(
                                Icons.person,
                                size: 18,
                                color: AppColor.SECONDARY,
                              )),
                        ],
                      ),
                      _buildNameInput(
                          context,
                          Languages.of(context)!.labelEmail,
                          _emailController,
                          Icon(
                            Icons.mail,
                            size: 16,
                            color: AppColor.SECONDARY,
                          )),
                      SizedBox(
                        width: 25,
                      ),
                      Container(
                        width: screenWidth * 0.33,
                        child: TextButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  WidgetStatePropertyAll(AppColor.SECONDARY)),
                          child: Text("Save Changes"),
                          onPressed: () {
                            setState(() {
                              editProfile = true;
                            });
                            _saveChanges();
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

  Widget _buildNameInput(BuildContext context, String text,
      TextEditingController nameController, Icon icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
              color: isDarkMode ? AppColor.BLACK : Colors.grey, width: 0.5)),
      child: Row(
        children: [
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.only(right: 4),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minWidth: screenWidth * 0.28, maxWidth: screenWidth * 01),
              child: IntrinsicWidth(
                child: TextField(
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                  obscureText: false,
                  obscuringCharacter: "*",
                  controller: nameController,
                  onChanged: (value) {
                    //_isValidInput();
                  },
                  onSubmitted: (value) {},
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: text,
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    icon: icon,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void openBottomSheet(BuildContext context,
      List<PrivateCouponDetailsResponse>? couponsResponse) {
    showModalBottomSheet(
      context: context,
      shape: Border(),
      scrollControlDisabledMaxHeightRatio: 0.85,
      isScrollControlled: false,
      // Allows draggable sheet
      builder: (context) {
        return Container(
          child: ListView.builder(
            itemCount: couponsResponse?.length,
            padding: EdgeInsets.only(bottom: 10),
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => {Navigator.of(context).pop()},
                    child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: ShapeDecoration(
                                color: AppColor.PRIMARY,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            child: Text(
                              "Close",
                              style: TextStyle(color: AppColor.WHITE),
                            ))),
                  ),
                  Text("Coupons",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  SizedBox(
                    height: 10,
                  ),
                  appliedCouponWidget(couponsResponse![index]),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    width: screenWidth * 0.5,
                    color: isDarkMode ? Colors.white : Colors.transparent,
                    height: 0.4,
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget appliedCouponWidget(PrivateCouponDetailsResponse couponsResponse) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColor.DARK_CARD_COLOR : Colors.blue[50],
      ),
      padding: EdgeInsets.only(left: 10, right: 0, top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: AppColor.SECONDARY),
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
            width: screenWidth * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Expire At => ${convertDateTimeFormat("${couponsResponse?.expire_at?.toUpperCase()}")}",
                  style: TextStyle(fontSize: 11),
                ),
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
}
