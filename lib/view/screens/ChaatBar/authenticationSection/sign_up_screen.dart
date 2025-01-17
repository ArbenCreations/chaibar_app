import 'package:ChaatBar/model/apis/api_response.dart';
import 'package:ChaatBar/model/request/signUpRequest.dart';
import 'package:ChaatBar/model/response/rf_bite/signUpInitializeResponse.dart';
import 'package:ChaatBar/utils/Util.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/sign_in_with_google.dart';
import 'package:ChaatBar/view_model/main_view_model.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../languageSection/Languages.dart';
import '../../../../theme/AppColor.dart';
import '../../../../utils/Helper.dart';
import '../../../component/connectivity_service.dart';
import '../../../component/toastMessage.dart';

class SignUpScreen extends StatefulWidget {
  final String? userId; // Define the 'data' parameter here

  SignUpScreen({Key? key, this.userId}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late double screenWidth;
  late double screenHeight;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool sheetPasswordVisible = false;
  bool sheetConfirmPasswordVisible = false;
  bool isLoading = false;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);

  bool inputValid = false;
  bool isDarkMode = false;
  String? deviceToken;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.white12,
      statusBarIconBrightness:
          Brightness.dark, // Light icons for the status bar
      //statusBarBrightness: Brightness.light,       // Status bar brightness (for iOS)
    ));
    Helper.getDeviceToken().then((token) {
      setState(() {
        deviceToken = token;
      });
    });
    passwordVisible = true;
    confirmPasswordVisible = true;
    sheetPasswordVisible = true;
    sheetConfirmPasswordVisible = true;
    inputValid = false;
    isDarkMode = false;
  }

  void _isValidInput() {
    //print(input);
    if (_emailController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text.length >= 8 &&
        _passwordController.text == _confirmPasswordController.text &&
        EmailValidator.validate(_emailController.text)) {
      setState(() {
        inputValid = true;
      });
    } else {
      setState(() {
        inputValid = false;
      });
    }
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _sheetPhoneController = TextEditingController();
  final TextEditingController _sheetPasswordController =
      TextEditingController();
  final TextEditingController _sheetConfirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    ApiResponse apiResponse = Provider.of<MainViewModel>(context).response;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          hideKeyBoard();
        },
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
              statusBarColor: Colors.white38,
              statusBarIconBrightness: Brightness.dark),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: screenHeight * 0.35,
                          child: Image(
                            alignment: Alignment.topCenter,
                            width: screenWidth,
                            height: screenHeight * 0.35,
                            image: AssetImage("assets/signUpBG.jpg"),
                            fit: BoxFit.cover,
                          ),
                          alignment: AlignmentDirectional.center,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: screenHeight * 0.28,
                            ),
                            Container(
                              height: screenHeight * 0.76,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: screenHeight -
                                        MediaQuery.of(context)
                                            .viewInsets
                                            .bottom,
                                  ),
                                  child: IntrinsicHeight(
                                    child: Column(
                                      children: [
                                        Flexible(
                                          child: Container(
                                            width: screenWidth,
                                            child: Card(
                                              elevation: 0,
                                              margin: EdgeInsets.zero,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  40),
                                                          topRight:
                                                              Radius.circular(
                                                                  40))),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 16.0,
                                                    right: 16,
                                                    top: 12),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      height: 14,
                                                    ),
                                                    Center(
                                                      child: _buildLabelText(
                                                          context,
                                                          Languages.of(context)!
                                                              .labelSetProfile,
                                                          24,
                                                          true),
                                                    ),
                                                    SizedBox(
                                                      height: 12,
                                                    ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.max,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(height: 5),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      18.0),
                                                          child: Column(
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  _buildNameInput(
                                                                      context,
                                                                      Languages.of(
                                                                              context)!
                                                                          .labelName,
                                                                      _nameController,
                                                                      Icon(
                                                                        Icons
                                                                            .person,
                                                                        size:
                                                                            18,
                                                                        color: isDarkMode
                                                                            ? Colors.white
                                                                            : Colors.black,
                                                                      )),
                                                                  SizedBox(
                                                                      width: 5),
                                                                  _buildNameInput(
                                                                      context,
                                                                      Languages.of(
                                                                              context)!
                                                                          .labelLastname,
                                                                      _lastNameController,
                                                                      Icon(
                                                                        Icons
                                                                            .person,
                                                                        size:
                                                                            18,
                                                                        color: isDarkMode
                                                                            ? Colors.white
                                                                            : Colors.black,
                                                                      ))
                                                                ],
                                                              ),
                                                              _buildPhoneInput(
                                                                  context,
                                                                  Languages.of(
                                                                          context)!
                                                                      .labelEmail,
                                                                  _emailController,
                                                                  Icon(
                                                                    Icons.mail,
                                                                    size: 16,
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                  )),
                                                              _buildPhoneInput(
                                                                  context,
                                                                  Languages.of(
                                                                          context)!
                                                                      .labelPhoneNumber,
                                                                  _phoneController,
                                                                  Icon(
                                                                    Icons.call,
                                                                    size: 16,
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                  )),
                                                              _buildPasswordInput(
                                                                  context,
                                                                  Languages.of(
                                                                          context)!
                                                                      .labelPassword,
                                                                  _passwordController,
                                                                  Icon(
                                                                    Icons
                                                                        .password,
                                                                    size: 16,
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                  passwordVisible,
                                                                  isDarkMode,
                                                                  "password"),
                                                              _buildPasswordInput(
                                                                  context,
                                                                  Languages.of(
                                                                          context)!
                                                                      .labelConfirmPass,
                                                                  _confirmPasswordController,
                                                                  Icon(
                                                                    Icons
                                                                        .password,
                                                                    size: 16,
                                                                    color: isDarkMode
                                                                        ? Colors
                                                                            .white
                                                                        : Colors
                                                                            .black,
                                                                  ),
                                                                  confirmPasswordVisible,
                                                                  isDarkMode,
                                                                  "confirmPassword"),
                                                            ],
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 25,
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: _buildFooter(
                                                              context, null),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Center(
                                                            child: Text(
                                                          "OR",
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Center(
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              User? user =
                                                                  await signInWithGoogle(
                                                                      context,
                                                                      "$deviceToken");

                                                              if (user !=
                                                                  null) {
                                                                print(
                                                                    "Signed in: ${user.displayName}");

                                                                //Navigator.pushReplacementNamed(context, "/VendorLocationScreen");
                                                              }
                                                            },
                                                            child: Card(
                                                              margin: EdgeInsets
                                                                  .zero,
                                                              color: Colors.grey
                                                                  .shade100,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              6)),
                                                              child: Container(
                                                                width:
                                                                    screenWidth *
                                                                        0.6,
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10,
                                                                        vertical:
                                                                            9),
                                                                decoration: BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                8),
                                                                    color: AppColor
                                                                        .PRIMARY),
                                                                child: Center(
                                                                    child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      child: Image
                                                                          .asset(
                                                                        "assets/google_logo.png",
                                                                        width:
                                                                            22,
                                                                        fit: BoxFit
                                                                            .fill,
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 8,
                                                                    ),
                                                                    Text(
                                                                      "Sign Up With Google",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              14,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              AppColor.PRIMARY),
                                                                    ),
                                                                  ],
                                                                )),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 42,
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Already have an account?",
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        GestureDetector(
                                                            onTap: () {
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  "/SignInScreen");
                                                            },
                                                            child: Text(
                                                              "Sign in",
                                                              style: TextStyle(
                                                                  fontSize: 12,
                                                                  color: AppColor
                                                                      .PRIMARY,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            )),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                            dismissible: false, color: Colors.transparent),
                        // Loader indicator
                        Center(
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  _buildLabelText(BuildContext context, String text, int size, bool isBold) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size.toDouble(),
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildPhoneInput(BuildContext context, String text,
      TextEditingController nameController, Icon icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isDarkMode ? AppColor.DARK_CARD_COLOR : Colors.white,
          border: Border.all(color: Colors.grey, width: 0.5)),
      child: Row(
        children: [
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(
                fontSize: 12.0,
              ),
              obscureText: false,
              obscuringCharacter: "*",
              controller: nameController,
              onChanged: (value) {
                _isValidInput();
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
        ],
      ),
    );
  }

  Widget _buildNameInput(BuildContext context, String text,
      TextEditingController nameController, Icon icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isDarkMode ? AppColor.DARK_CARD_COLOR : Colors.white,
          border: Border.all(color: Colors.grey, width: 0.5)),
      child: Row(
        children: [
          SizedBox(width: 8),
          Container(
            width: screenWidth * 0.35,
            child: TextField(
              style: TextStyle(
                fontSize: 12.0,
              ),
              obscureText: false,
              obscuringCharacter: "*",
              controller: nameController,
              onChanged: (value) {
                _isValidInput();
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
        ],
      ),
    );
  }

  Widget _buildPasswordInput(
      BuildContext context,
      String text,
      TextEditingController nameController,
      Icon icon,
      bool visibility,
      bool isDarkMode,
      String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isDarkMode ? AppColor.DARK_CARD_COLOR : Colors.white,
          border: Border.all(color: Colors.grey, width: 0.5)),
      child: Row(
        children: [
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: 14.0,
              ),
              obscureText: visibility,
              obscuringCharacter: "*",
              controller: nameController,
              onChanged: (value) {
                _isValidInput();
              },
              onSubmitted: (value) {},
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: text,
                hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                icon: icon,
                suffixIcon: IconButton(
                  icon: Icon(
                    visibility ? Icons.visibility : Icons.visibility_off,
                    size: 18,
                    color: isDarkMode ? Colors.white60 : Colors.black45,
                  ),
                  onPressed: () {
                    setState(
                      () {
                        if (type == "password") {
                          passwordVisible = !passwordVisible;
                        } else if (type == "confirmPassword") {
                          confirmPasswordVisible = !confirmPasswordVisible;
                        } else if (type == "sheetPassword") {
                          sheetPasswordVisible = !sheetPasswordVisible;
                        } else if (type == "sheetConfirmPassword") {
                          sheetConfirmPasswordVisible =
                              !sheetConfirmPasswordVisible;
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, User? user) {
    return GestureDetector(
      onTap: () async {
        _signUp(user);
      },
      child: Card(
        margin: EdgeInsets.zero,
        color: AppColor.PRIMARY,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        child: Container(
          width: screenWidth * 0.6,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  Languages.of(context)!.labelConfirm,
                  style: TextStyle(
                      color: inputValid ? Colors.white : AppColor.WHITE,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.play_arrow_rounded,
                size: 18,
                color: AppColor.WHITE,
              )
            ],
          ),
        ),
      ),
    );
  }

  void Validate(String email) {
    bool isValid = EmailValidator.validate(email);
    print(isValid);
  }

  _signUp(User? user) async {
    hideKeyBoard();
    _isValidInput();
    print(_nameController.text);
    //Navigator.pushNamed(context, "/OTPVerifyScreen", arguments: "");

    if (inputValid) {
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
        SignUpRequest request = SignUpRequest(
            customer: CustomerSignUp(
          deviceToken: deviceToken,
          email: _emailController.text,
          password: _passwordController.text,
          firstName: _nameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text,
        ));

        await Provider.of<MainViewModel>(context, listen: false).signUpData(
            "/api/v1/app/temp_customers/initiate_temp_customer", request);
        //Navigator.pushNamed(context, '/BottomNav');

        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getSignUpResponse(context, apiResponse);
      }
    } else {
      if (_emailController.text.isEmpty &&
          _nameController.text.isEmpty &&
          _lastNameController.text.isEmpty &&
          _passwordController.text.isEmpty &&
          _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter all the details'),
            duration: maxDuration,
          ),
        );
      } else if (!EmailValidator.validate(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Enter valid email address.'),
            duration: maxDuration,
          ),
        );
      } else if (_passwordController.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${Languages.of(context)?.labelPasswordAlert}'),
            duration: maxDuration,
          ),
        );
      } else if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${Languages.of(context)?.labelPasswordDoesntMatch}"),
            duration: maxDuration,
          ),
        );
      }
    }
  }

  Future<Widget> getSignUpResponse(
      BuildContext context, ApiResponse apiResponse) async {
    SignUpInitializeResponse? signUpResponse =
        apiResponse.data as SignUpInitializeResponse?;
    String? message = apiResponse.message.toString();
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("GetSetUpAccountWidget : ${signUpResponse?.phoneNumber}");
        // await Helper.saveProfileDetails(signUpResponse);

        await Helper.savePassword(_passwordController.text);

        if (_phoneController.text.isNotEmpty) {
          Navigator.pushNamed(context, "/OTPVerifyScreen",
              arguments: "${_phoneController.text}");
        } else {
          Navigator.pushNamed(context, "/OTPVerifyScreen",
              arguments: "${_sheetPhoneController.text}");
        }
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        ToastComponent.showToast(context: context, message: message);
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

  void _showModal(BuildContext context, User user) {
    showDialog<void>(
        context: context,
        barrierDismissible: true,
        useSafeArea: true,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 10),
            title: Text("Please enter following details to proceed"),
            content: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 2,
                  ),
                  Text("Signing up as: ${user.displayName}"),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "Email : ${user.email}",
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  _buildPhoneInput(
                      context,
                      Languages.of(context)!.labelPhoneNumber,
                      _sheetPhoneController,
                      Icon(
                        Icons.call,
                        size: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      )),
                  _buildPasswordInput(
                      context,
                      Languages.of(context)!.labelPassword,
                      _sheetPasswordController,
                      Icon(
                        Icons.password,
                        size: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      sheetPasswordVisible,
                      isDarkMode,
                      "sheetPassword"),
                  _buildPasswordInput(
                      context,
                      Languages.of(context)!.labelConfirmPass,
                      _sheetConfirmPasswordController,
                      Icon(
                        Icons.password,
                        size: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      sheetConfirmPasswordVisible,
                      isDarkMode,
                      "sheetConfirmPassword"),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            actions: <Widget>[_buildFooter(context, user)],
            actionsAlignment: MainAxisAlignment.center,
          );
        });
  }
}
