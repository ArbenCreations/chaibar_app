import 'package:flutter/services.dart';

import '../../component/CustomSnackbar.dart';
import '../../component/custom_circular_progress.dart';
import '/model/db/ChaiBarDB.dart';
import '/model/request/editProfileRequest.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../component/CustomAlert.dart';
import '../../../language/Languages.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../../model/response/profileResponse.dart';
import '../../../theme/CustomAppColor.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';

class EditProfileScreen extends StatefulWidget {
  EditProfileScreen();

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
  final ConnectivityService _connectivityService = ConnectivityService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? theme = "";
  String? vendorId = "";
  Color primaryColor = CustomAppColor.PrimaryAccent;
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
      setState(() {
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
    $FloorChaiBarDB
        .databaseBuilder('basic_structure_database.db')
        .build()
        .then((value) async {
      this.database = value;
    });
    isDataLoading = true;
    _fetchDataFromPref();
    _fetchData();
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
        Navigator.pushReplacementNamed(context, "/ProfileScreen");
      },
      child: Scaffold(
        backgroundColor: CustomAppColor.Background,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light
          ),
          title: Text(
            "Edit Profile",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image(
                      image: AssetImage("assets/app_logo.png"),
                      height: screenHeight / 5,
                      width: mediaWidth / 2.5,
                    ),
                    _buildNameInput(
                        context,
                        Languages.of(context)!.labelName,
                        _nameController,
                        Icon(
                          Icons.person,
                          size: 18,
                          color: CustomAppColor.PrimaryAccent,
                        ), true),
                    SizedBox(
                      height: 8,
                    ),
                    _buildNameInput(
                        context,
                        Languages.of(context)!.labelLastname,
                        _lastNameController,
                        Icon(
                          Icons.person,
                          size: 18,
                          color: CustomAppColor.PrimaryAccent,
                        ), true),
                    SizedBox(
                      height: 8,
                    ),
                    _buildNonEditableInput(
                        context,
                        Languages.of(context)!.labelEmail,
                        _emailController,
                        Icon(
                          Icons.mail,
                          size: 16,
                          color: CustomAppColor.PrimaryAccent,
                        ), false),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      width: mediaWidth * 0.65,
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                WidgetStatePropertyAll(CustomAppColor.PrimaryAccent)),
                        child: Text(
                          "Save",
                          style: TextStyle(fontSize: 16),
                        ),
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
              ),
              isLoading
                  ? CustomCircularProgress()
                  : SizedBox()
            ],
          ),
        ),
      ),
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
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getProfileResponse(context, apiResponse);
      }
    }
  }

  Future<void> _saveChanges() async {
    bool isConnected = await _connectivityService.isConnected();
    hideKeyBoard();
    print(("isConnected - ${isConnected}"));
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    if (!isConnected) {
      setState(() {
        isLoading = false;
        isInternetConnected = false;
        CustomSnackBar.showSnackbar(context: context, message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
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
          Navigator.of(context).pushReplacementNamed("/BottomNavigation", arguments: 1);
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
        _nameController.text = firstName.toString();
        _lastNameController.text = lastName.toString();
        _emailController.text = email.toString();
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

  Widget _buildNameInput(BuildContext context, String text,
      TextEditingController nameController, Icon icon, isClickable) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.0),
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        style: TextStyle(
          fontSize: 12.0,
        ),
        obscureText: false,
        obscuringCharacter: "*",
        controller: nameController,
        enabled: true,
        readOnly: true,
        onChanged: (value) {
          //_isValidInput();
        },
        onSubmitted: (value) {},
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: Colors.grey)),
          border: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: CustomAppColor.Primary)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: CustomAppColor.Primary)),
          hintText: text,
          labelText: "$text",
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
          //icon: icon,
        ),
      ),
    );
  }
  Widget _buildNonEditableInput(BuildContext context, String text,
      TextEditingController nameController, Icon icon, isClickable) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.0),
      margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        style: TextStyle(
          fontSize: 12.0,
        ),
        obscureText: false,
        obscuringCharacter: "*",
        controller: nameController,
        enabled: true,
        readOnly: true,
        onChanged: (value) {
          //_isValidInput();
        },
        onSubmitted: (value) {},
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: Colors.grey)),
          border: OutlineInputBorder(
              borderSide: BorderSide(width: 0.5, color: CustomAppColor.Primary)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: CustomAppColor.Primary)),
          hintText: text,
          labelText: "$text",
          labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
          //icon: icon,
        ),
      ),
    );
  }
}
