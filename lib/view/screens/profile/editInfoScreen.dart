import 'dart:io';

import 'package:ChaiBar/model/request/deleteProfileRequest.dart';
import 'package:ChaiBar/theme/CustomAppColor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../language/Languages.dart';
import '../../../model/db/ChaiBarDB.dart';
import '../../../model/request/editProfileRequest.dart';
import '../../../model/response/profileResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../utils/apis/api_response.dart';
import '../../component/connectivity_service.dart';
import '../../component/custom_button_component.dart';
import '../../component/session_expired_dialog.dart';
import '../../component/toastMessage.dart';

class EditInformationScreen extends StatefulWidget {
  @override
  _EditInformationScreenState createState() => _EditInformationScreenState();
}

class _EditInformationScreenState extends State<EditInformationScreen> {
  bool isLoading = false;
  bool isInternetConnected = true;
  bool isDarkMode = false;
  late double mediaWidth;
  late double screenHeight;
  String documentNumber = "";
  String? firstName = "";
  String? lastName = "";
  String? email = "";
  String? dob = "";
  String? phone = "";
  String? imageUrl = "";
  String? userId = "";
  String? recentDocumentName = "";
  String? recentDocumentNumber = "";
  String? address = "";
  File? galleryFile = File("");
  bool passwordVisible = false;
  bool mExpanded = false;
  String mSelectedText = "";
  final List<String> docType = ["National Id", "Passport"];
  var selectedAvatar =
      "https://icons.iconarchive.com/icons/hopstarter/superhero-avatar/256/Avengers-Captain-America-icon.png";

  static const maxDuration = Duration(seconds: 2);
  bool isDataLoading = false;
  late ChaiBarDB database;
  final TextEditingController documentNumberController =
      TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    firstName = "";
    lastName = "";
    dob = "";
    email = "";
    phone = "";
    isDataLoading = true;
    $FloorChaiBarDB
        .databaseBuilder('basic_structure_database.db')
        .build()
        .then((value) async {
      this.database = value;
    });
    Helper.getProfileDetails().then((profileDetails) {
      setState(() {
        firstName = profileDetails?.firstName;
        lastName = profileDetails?.lastName;
        email = profileDetails?.email;
        phone = profileDetails?.phoneNumber ??" ";
        userId = "${profileDetails?.id}";
        _nameController.text = "${firstName}";
        _lastNameController.text = "${lastName}";
        _emailController.text = "${email}";
        _phoneController.text = "${phone}";
        isDataLoading = false;
      });
    });
  }

  Future<Widget> getProfileResponse(
      BuildContext context, ApiResponse apiResponse) async {
    ProfileResponse? mediaList = apiResponse.data as ProfileResponse?;
    print("apiResponse${mediaList?.message}");
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        CustomToast.showToast(
            context: context, message: "${mediaList?.message}");
        hideKeyBoard();
        Navigator.pushReplacementNamed(context, "/BottomNavigation",
            arguments: 3);

        _fetchDataFromPref();
        //Navigator.pushReplacementNamed(context, "/PersonalInfoScreen");
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        _fetchDataFromPref();
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
    setState(() {
      isLoading = false;
    });
  }

  Future<Widget> deleteProfileResponse(
      BuildContext context, ApiResponse apiResponse) async {
    ProfileResponse? mediaList = apiResponse.data as ProfileResponse?;
    print("apiResponse${mediaList?.message}");
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        CustomToast.showToast(
            context: context, message: "${mediaList?.message}");

        hideKeyBoard();
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
        return Container(); //Return an empty container as you'll navigate away
      case Status.ERROR:
        Navigator.pop(context);
        _fetchDataFromPref();
        print("Message : ${apiResponse.message}");
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        } else {
          CustomToast.showToast(context: context, message: apiResponse.message);
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

  Future<void> _showLogOutDialog() async {
    bool isConnected = await _connectivityService.isConnected();
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
                          onPressed: () async {},
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

  void _showModal(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
        TextEditingController phoneController = TextEditingController();
        bool passwordVisible = false;
        bool isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 10),
              title: Text(
                "Please enter your password for confirmation to delete account",
                style: TextStyle(fontSize: 12),
              ),
              content: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 5),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email : ${_emailController.text}",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: isDarkMode
                            ? CustomAppColor.DarkCardColor
                            : Colors.white,
                        border: Border.all(color: Colors.grey, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              style: TextStyle(fontSize: 11.0),
                              obscureText: !passwordVisible,
                              obscuringCharacter: "*",
                              controller: phoneController,
                              keyboardType: TextInputType.visiblePassword,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 16.0),
                                hintText: Languages.of(context)!.labelPassword,
                                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                                icon: Icon(
                                  Icons.email,
                                  size: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                                suffixIcon: GestureDetector(
                                  child: Icon(
                                    passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    size: 20,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: <Widget>[
                CustomButtonComponent(
                  text: "Delete",
                  mediaWidth: MediaQuery.of(context).size.width * 0.6,
                  textColor: Colors.white,
                  buttonColor: Colors.red,
                  isDarkMode: isDarkMode,
                  verticalPadding: 10,
                  onTap: () async {
                    hideKeyBoard();
                    bool isConnected = await _connectivityService.isConnected();

                    if (phoneController.text.isEmpty) {
                      CustomToast.showToast(
                          context: context, message: "Please enter password");
                    } else {
                      setState(() => isLoading = true);

                      if (!isConnected) {
                        setState(() {
                          isLoading = false;
                          isInternetConnected = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(Languages.of(context)!.labelNoInternetConnection),
                            duration: maxDuration,
                          ),
                        );
                      } else {
                        DeleteProfileRequest request = DeleteProfileRequest(
                          email: _emailController.text,
                          password: phoneController.text,
                        );

                        await Future.delayed(Duration(milliseconds: 2));
                        await Provider.of<MainViewModel>(context, listen: false)
                            .deleteProfile("/api/v1/app/customers/verify_and_destroy", request);

                        ApiResponse apiResponse =
                            Provider.of<MainViewModel>(context, listen: false).response;
                        deleteProfileResponse(context, apiResponse);

                        setState(() => isLoading = false);
                      }
                    }
                  },
                )
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    mediaWidth = MediaQuery.of(context).size.width;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          Languages.of(context)!.labelEditPersonalInfo,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 30),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: () => {},
                            child: Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    color: Theme.of(context).cardColor,
                                    width: 0.1),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                child: Image.asset(
                                  "assets/userIcon.png",
                                  width: 120,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: mediaWidth * 0.9,
                            minWidth: mediaWidth * 0.9,
                          ),
                          child: editableDetailBox(
                              Languages.of(context)!.labelFirstname,
                              "${firstName}",
                              12,
                              11,
                              Icons.person,
                              _nameController,
                              true),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: mediaWidth * 0.9,
                            minWidth: mediaWidth * 0.9,
                          ),
                          child: editableDetailBox(
                              Languages.of(context)!.labelLastname,
                              "${lastName}",
                              12,
                              11,
                              Icons.person,
                              _lastNameController,
                              true),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: mediaWidth * 0.9,
                            minWidth: mediaWidth * 0.9,
                          ),
                          child: editableDetailBox(
                              Languages.of(context)!.labelEmail,
                              "${email}",
                              12,
                              11,
                              Icons.email,
                              _emailController,
                              false),
                        ),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: mediaWidth * 0.9,
                            minWidth: mediaWidth * 0.9,
                          ),
                          child: editableDetailBox(
                              Languages.of(context)!.labelPhoneNumber,
                              "${email}",
                              12,
                              11,
                              Icons.call,
                              _phoneController,
                              false),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: mediaWidth * 0.45,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                                Theme.of(context).cardColor),
                          ),
                          onPressed: () async {
                            _saveChanges();
                          },
                          child: Text(
                            Languages.of(context)!.labelSubmit,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: mediaWidth * 0.45,
                        child: TextButton(
                          style: ButtonStyle(
                            backgroundColor:
                                WidgetStateProperty.all(Colors.red),
                          ),
                          onPressed: () async {
                            _deleteAccount();
                          },
                          child: Text(
                            Languages.of(context)!.labelDeleteAccount,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                        color: Colors.black.withOpacity(0.3)),
                    // Loader indicator
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Languages.of(context)!.labelNoInternetConnection),
              duration: maxDuration,
            ),
          );
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

  Future<void> _deleteAccount() async {
    hideKeyBoard();
    //_showLogOutDialog();
    _showModal(context);
  }

  Widget buildBirthdateSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 10),
        padding: EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Languages.of(context)!.labelBirthdate,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Text(
                  "${dob}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDocumentNumberSection(String heading, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text("${value}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        ],
      ),
    );
  }

  Future<File?> _resizeAndCompressImage(File file, int targetWidth) async {
    try {
      final directory = await getTemporaryDirectory();
      final targetPath = path.join(directory.path,
          '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg');

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        minWidth: targetWidth,
        quality: 85, // Adjust quality to balance size and quality
        format: CompressFormat.jpeg,
        keepExif: false, // Remove metadata
      );

      if (result == null) {
        print('Resizing and compression failed.');
        return null;
      }

      print('Original size: ${file.lengthSync()} bytes');
      print('Resized and compressed size: ${result.lengthSync()} bytes');

      return result;
    } catch (e) {
      print('Error resizing and compressing image: $e');
      return null;
    }
  }

  Widget editableDetailBox(
      String heading,
      String subHeading,
      double subHeadingTextSize,
      double headingTextSize,
      IconData icon,
      TextEditingController controller,
      bool isClickable) {
    //controller.text = subHeading;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        decoration: BoxDecoration(
          color: CustomAppColor.Background,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  heading,
                  style: TextStyle(
                    fontSize: headingTextSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 2,
            ),
            Container(
              color: Colors.white,
              child: TextField(
                scrollPadding: EdgeInsets.all(0),
                controller: controller,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {
                  //isInputValid();
                },
                style: TextStyle(fontSize: 13),
                onSubmitted: (value) {},
                keyboardType: TextInputType.visiblePassword,
                enabled: isClickable,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(width: 0, color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 0, color: Theme.of(context).cardColor)),
                  hintText: heading,
                  prefixIcon: Icon(
                    icon,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDOBInput(BuildContext context, String text,
      TextEditingController dateController, Icon icon) {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        children: [
          Expanded(
              child: TextField(
                  controller: dateController,
                  //editing controller of this TextField
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      border: InputBorder.none,
                      hintText: Languages.of(context)!.labelBirthdate,
                      icon: icon
                      //icon of text field
                      ),
                  readOnly: true,
                  // when true user cannot edit text
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate:
                            DateTime.now().subtract(Duration(days: 365 * 18)),
                        firstDate: DateTime(1950),
                        //DateTime.now() - not to allow to choose before today.
                        lastDate:
                            DateTime.now().subtract(Duration(days: 365 * 18)),
                        helpText: "${Languages.of(context)?.labelSelectDob}",
                        confirmText: "${Languages.of(context)?.labelConfirm}",
                        errorFormatText:
                            '${Languages.of(context)?.labelEnterValidDate}',
                        errorInvalidText:
                            '${Languages.of(context)?.labelEnterDateInValidRange}',
                        builder: (context, child) {
                          return Theme(
                            data: isDarkMode
                                ? ThemeData.dark()
                                : ThemeData
                                    .light(), // This will change to light theme.
                            child: child!,
                          );
                        });

                    if (pickedDate != null) {
                      print(
                          pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                      String formattedDate =
                          DateFormat('dd-MM-yyyy').format(pickedDate);
                      print(
                          formattedDate); //formatted date output using intl package =>  2021-03-16
                      setState(() {
                        _dobController.text =
                            formattedDate; //set output date to TextField value.
                      });
                    } else {}
                  })),
        ],
      ),
    );
  }

  void isInputValid() {}
}
