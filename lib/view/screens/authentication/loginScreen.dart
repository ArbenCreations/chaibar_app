import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '/model/request/signInRequest.dart';
import '/model/response/signInResponse.dart';
import '/utils/Util.dart';
import '../../../../language/Languages.dart';
import '../../../../model/response/profileResponse.dart';
import '../../../../theme/CustomAppColor.dart';
import '../../../../utils/Helper.dart';
import '../../../model/request/signUpRequest.dart';
import '../../../model/response/signUpInitializeResponse.dart';
import '../../../model/services/AuthenticationProvider.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomAlert.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/connectivity_service.dart';
import '../../component/custom_circular_progress.dart';
import '../../component/googleSignIN.dart';

class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  bool passwordVisible = false;
  bool isLoading = false;
  bool isLogin = true;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  bool inputValid = false;
  late double mediaWidth;
  late double screenHeight;
  late bool isDarkMode;
  String? deviceToken;
  String _appVersion = '';

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    inputValid = false;
    _loadAppVersion();
    Helper.getDeviceToken().then((token) {
      setState(() {
        deviceToken = token;
      });
    });
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
    });
  }

  final TextEditingController _emailController =
      TextEditingController(text: "");
  final TextEditingController _passwordController =
      TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    ApiResponse apiResponse = Provider.of<MainViewModel>(context).response;

    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          SystemNavigator.pop();
        },
        child: Scaffold(
          extendBody: false,
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/loginBack.png"),
                    fit: BoxFit.cover)),
            child: SingleChildScrollView(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height, // Ensures proper height
                child: Stack(
                  children: [
                    /*  Positioned(
                        top: -screenHeight * .15,
                        right: -MediaQuery.of(context).size.width * .4,
                        child: BezierContainer()),*/
                    SafeArea(
                      child: Row(
                        children: [
                          Expanded(
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //SizedBox(height: 150),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                      children: [
                                        /*     Image.asset(
                                          "assets/app_logo.png",
                                          height: 45,
                                        ),*/

                                        /* _buildLabelText(
                                  context, "Login to Your Account!", 18, false),*/
                                        _buildPhoneInput(
                                          context,
                                          "${Languages.of(context)?.labelEmail}",
                                          _emailController,
                                          Icon(
                                            Icons.person,
                                            size: 20,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        _buildPasswordInput(
                                          context,
                                          Languages.of(context)!.labelPassword,
                                          _passwordController,
                                          Icon(
                                            Icons.password,
                                            size: 18,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          passwordVisible,
                                          isDarkMode,
                                        ),
                                        _buildFooter(context, apiResponse),
                                        _divider(),
                                        _googleButton(),
                                        Platform.isIOS
                                            ? SizedBox(
                                                width: mediaWidth * 0.55,
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    User? user = await context
                                                        .read<
                                                            AuthenticationProvider>()
                                                        .signInWithApple();
                                                    if (user != null) {
                                                      bool isEmailRelay =
                                                          user.email?.endsWith(
                                                                  "@privaterelay.appleid.com") ??
                                                              true;
                                                      bool isNameMissing =
                                                          user.displayName ==
                                                                  null ||
                                                              user.displayName!
                                                                  .isEmpty;
                                                      _appleSignIn(user, true);
                                                    } else {
                                                      print(
                                                          "Apple sign-in failed or was canceled.");
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(Icons.apple,
                                                            color:
                                                                Colors.white),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          'Sign in with Apple',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            // <- Change text size here
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                        GestureDetector(
                                          onTap: () async {
                                            setState(() {
                                              isLoading = true;
                                            });
                                            SignInRequest request =
                                                SignInRequest(
                                                    customer: CustomerSignIn(
                                              deviceToken: "${deviceToken}",
                                              email: "guest@isekaitech.com",
                                              password: "Isekai@123",
                                            ));

                                            bool isConnected =
                                                await _connectivityService
                                                    .isConnected();
                                            if (!isConnected) {
                                              setState(() {
                                                isLoading = false;
                                                CustomSnackBar.showSnackbar(
                                                    context: context,
                                                    message:
                                                        '${Languages.of(context)?.labelNoInternetConnection}');
                                              });
                                            } else {
                                              await Provider.of<MainViewModel>(
                                                      context,
                                                      listen: false)
                                                  .signInWithPass(
                                                      "/api/v1/app/customers/sign_in",
                                                      request);

                                              ApiResponse apiResponse =
                                                  Provider.of<MainViewModel>(
                                                          context,
                                                          listen: false)
                                                      .response;
                                              getSignInResponse(
                                                  context, apiResponse);
                                            }
                                          },
                                          child: Container(
                                            width: mediaWidth * 0.55,
                                            height: 50,
                                            margin: EdgeInsets.only(top: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.black,
                                              // Change this to match your theme
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Continue as guest user",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 70),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Not Registered? ",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/RegisterScreen');
                              },
                              child: Text(
                                "${Languages.of(context)?.labelSignup}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: EdgeInsets.only(bottom: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Version $_appVersion',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                    isLoading ? CustomCircularProgress() : SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildPhoneInput(BuildContext context, String text,
      TextEditingController nameController, Icon icon) {
    //nameController.text = widget.data as String;
    return Container(
      width: mediaWidth * 0.8,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: CustomAppColor.TextFieldBackColor,
        shape: BoxShape.rectangle,
        border: Border.all(
            color: isDarkMode ? Colors.grey : CustomAppColor.TextFieldBackColor,
            width: 0.4),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.01),
            // Shadow color
            offset: Offset(0, 1),
            // Adjust X and Yoffset to match Figma
            blurRadius: 10,
            // Adjust this for more/less blur
            spreadRadius: 0.6, // Adjust spread if needed
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              controller: nameController,
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter
              ],
              textInputAction: TextInputAction.next,
              maxLength: 30,
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 0.4)),
                hintText: text,
                counterText: "",
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter an email address";
                }
                final emailRegex =
                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) {
                  return "Please enter a valid email address";
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInput(
    BuildContext context,
    String text,
    TextEditingController passwordController,
    Icon icon,
    bool passwordVisibles,
    bool isDarkMode,
  ) {
    return Container(
      width: mediaWidth * 0.8,
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: CustomAppColor.TextFieldBackColor,
        shape: BoxShape.rectangle,
        border: Border.all(
          color: isDarkMode ? Colors.grey : CustomAppColor.TextFieldBackColor,
          width: 0.4,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.01),
            offset: Offset(0, 1),
            blurRadius: 10,
            spreadRadius: 0.6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: passwordController,
            obscureText: passwordVisible,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: text,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
              // Adjust padding

              counterText: "",
              errorStyle: TextStyle(fontSize: 11, height: 1),
              // Reduces error text size
              errorMaxLines: 2,
              // Allows error messages to wrap properly
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 0.4),
              ),
              suffixIcon: GestureDetector(
                child: Icon(
                  passwordVisible ? Icons.visibility_off : Icons.visibility,
                  size: 20,
                ),
                onTap: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Password is required";
              }
              if (!hasMinLength(value)) {
                return "Password must be at least 8 characters long";
              }
              if (!hasUppercase(value)) {
                return "Password must contain at least one uppercase letter";
              }
              if (!hasDigit(value)) {
                return "Password must contain at least one digit";
              }
              if (!hasSpecialCharacter(value)) {
                return "Password must contain at least one special character";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ApiResponse apiResponse) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topRight,
          margin: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/ForgotPasswordScreen');
            },
            child: Text(
              "${Languages.of(context)?.labelForgotPass}?",
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () async {
                hideKeyBoard();
                _checkValidInput();
                if (_formKey.currentState?.validate() == true) {
                } else {
                  print("Not Validated");
                }
                if (inputValid) {
                  _signIn(null, false);
                }
              },
              child: Container(
                width: mediaWidth * 0.55,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black, // Change this to match your theme
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Sign In",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
                right: -10, // Adjust position
                top: -10,
                bottom: -10,
                child: Container(
                  width: 36,
                  height: 36,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: CustomAppColor.PrimaryAccent,
                    // Change color as needed
                    shape: BoxShape.circle,
                  ),
                  child: Image(
                    image: AssetImage("assets/coffeeIcon.png"),
                    height: 10,
                    width: 10, // Use appropriate icon
                  ),
                )),
          ],
        ),
      ],
    );
  }

  void Validate(String email) {
    bool isValid = EmailValidator.validate(email);
    print(isValid);
  }

  Future<void> _signIn(User? user, bool isAppleLogin) async {
    hideKeyBoard();
    setState(() {
      isLoading = true;
    });
    if (inputValid || user != null) {
      SignInRequest signInRequest = SignInRequest();
      if (isAppleLogin) {
        signInRequest = SignInRequest(
            customer: CustomerSignIn(
          deviceToken: "${deviceToken}",
          email: user != null ? "${user.email}" : _emailController.text,
          password: user != null ? "applesign1" : _passwordController.text,
        ));
      } else {
        signInRequest = SignInRequest(
            customer: CustomerSignIn(
          deviceToken: "${deviceToken}",
          email: user != null ? "${user.email}" : _emailController.text,
          password: user != null ? "googlesign1" : _passwordController.text,
        ));
      }
      bool isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackbar(
              context: context,
              message: '${Languages.of(context)?.labelNoInternetConnection}');
        });
      } else {
        await Provider.of<MainViewModel>(context, listen: false)
            .signInWithPass("/api/v1/app/customers/sign_in", signInRequest);

        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getSignInResponse(context, apiResponse);
      }
    }
  }

  Future<void> _appleSignIn(User? user, bool isAppleLogin) async {
    hideKeyBoard();
    setState(() {
      isLoading = true;
    });
    if (inputValid || user != null) {
      SignInRequest signInRequest = SignInRequest(
          customer: CustomerSignIn(
        deviceToken: "${deviceToken}",
        email: user != null ? "${user.email}" : _emailController.text,
        password: user != null ? "applesign1" : _passwordController.text,
      ));
      bool isConnected = await _connectivityService.isConnected();
      if (!isConnected) {
        setState(() {
          isLoading = false;
          CustomSnackBar.showSnackbar(
              context: context,
              message: '${Languages.of(context)?.labelNoInternetConnection}');
        });
      } else {
        await Provider.of<MainViewModel>(context, listen: false)
            .signInWithPass("/api/v1/app/customers/sign_in", signInRequest);

        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getAppleSignInResponse(context, apiResponse, user);
      }
    }
  }

  Widget _googleButton() {
    return GestureDetector(
      onTap: () async {
        User? user = await signInWithGoogle(context, deviceToken.toString());
        if (user != null) {
          print("Signed in: ${user.displayName}");
          _signIn(user, false);
        }
      },
      child: Container(
        height: 50,
        width: mediaWidth * 0.55,
        margin: EdgeInsets.symmetric(
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: CustomAppColor.PrimaryAccent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              "assets/google_logo.png",
              width: 22,
              fit: BoxFit.fill,
              color: Colors.white,
            ),
            Container(
              margin: EdgeInsets.only(left: 8.0),
              alignment: Alignment.center,
              child: Text(
                  isLogin ? 'Sign in with Google' : 'Sign up with Google',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<Widget> getSignInResponse(
      BuildContext context, ApiResponse apiResponse) async {
    SignInResponse? mediaList = apiResponse.data as SignInResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("GetSignInResponse : ${mediaList}");

        ProfileResponse data = ProfileResponse(
          phoneNumber: mediaList?.customer?.phoneNumber,
          id: mediaList?.customer?.id,
          email: mediaList?.customer?.email,
          lastName: mediaList?.customer?.lastName,
          firstName: mediaList?.customer?.firstName,
          totalPoints: mediaList?.customer?.totalPoints,
        );
        Helper.saveProfileDetails(data);
        Helper.saveRedeemPoints(mediaList?.customer?.totalPoints);
        String token = "${mediaList?.token}";
        print("token :: $token ${mediaList?.customer?.totalPoints}");
        bool isSaved = await Helper.saveUserToken(token);

        // Check if the token was saved successfully
        if (isSaved) {
          print('Token saved successfully.');
        } else {
          print('Failed to save token.');
        }

        await Helper.savePassword(_passwordController.text);
        String? password = await Helper.getPassword();
        print("password: ${password}");
        Navigator.pushReplacementNamed(context, "/VendorsListScreen",
            arguments: "");

        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("message : ${apiResponse.message}");
        CustomAlert.showToast(context: context, message: apiResponse.message);
        return Center();
      case Status.INITIAL:
      default:
        return Center();
    }
  }

  Future<Widget> getAppleSignInResponse(
      BuildContext context, ApiResponse apiResponse, User? user) async {
    SignInResponse? mediaList = apiResponse.data as SignInResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("GetSignInResponse : ${mediaList}");

        ProfileResponse data = ProfileResponse(
          phoneNumber: mediaList?.customer?.phoneNumber,
          id: mediaList?.customer?.id,
          email: mediaList?.customer?.email,
          lastName: mediaList?.customer?.lastName,
          firstName: mediaList?.customer?.firstName,
          totalPoints: mediaList?.customer?.totalPoints,
        );
        Helper.saveProfileDetails(data);
        Helper.saveRedeemPoints(mediaList?.customer?.totalPoints);
        String token = "${mediaList?.token}";
        print("token :: $token ${mediaList?.customer?.totalPoints}");
        bool isSaved = await Helper.saveUserToken(token);

        // Check if the token was saved successfully
        if (isSaved) {
          print('Token saved successfully.');
        } else {
          print('Failed to save token.');
        }

        await Helper.savePassword("applesign1");
        String? password = await Helper.getPassword();
        print("password: ${password}");
        Navigator.pushReplacementNamed(context, "/VendorsListScreen",
            arguments: "");

        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("message : ${apiResponse.message}");
        if (apiResponse.message == "Invalid email or password") {
          //showUserDetailsBottomSheet(context, user);
          _showSignUpBottomSheet(context, user);
        } else {
          CustomAlert.showToast(context: context, message: apiResponse.message);
        }

        return Center();
      case Status.INITIAL:
      default:
        return Center();
    }
  }

  Widget _divider() {
    return Container(
      width: mediaWidth * 0.5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  void _checkValidInput() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    String? emailError = validateEmail(email);
    String? passwordError = validatePasswordMessage(password);

    if (emailError == null && passwordError == null) {
      setState(() {
        inputValid = true;
      });
    } else {
      if (emailError != null && _emailController.text.length > 3) {
        print("emailError: $emailError");
      }
      if (passwordError != null && _passwordController.text.length > 3) {
        print("emailError: $passwordError");
      }
      setState(() {
        inputValid = false;
      });
    }
  }

  String? validateEmail(String email) {
    if (email.isEmpty) {
      return "Email cannot be empty";
    }

    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(email)) {
      return "Enter a valid email address";
    }

    return null; // Email is valid
  }

  bool validatePassword(String password) {
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$';

    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  String? validatePasswordMessage(String password) {
    if (password.isEmpty) {
      return "Password cannot be empty";
    } else if (password.length < 8) {
      return "Password must be at least 8 characters long";
    } else if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "Password must contain at least one lowercase letter";
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain at least one uppercase letter";
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Password must contain at least one number";
    } else if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      return "Password must contain at least one special character (!@#\$&*~)";
    }
    return null; // Password is valid
  }

  bool isAppleRelayEmail(email) {
    return email.endsWith("@privaterelay.appleid.com");
  }

  void showUserDetailsBottomSheet(BuildContext context, User? user) {
    TextEditingController nameController =
        TextEditingController(text: user?.displayName);
    TextEditingController emailController = TextEditingController(
        text: user?.email?.endsWith("@privaterelay.appleid.com") == true
            ? user?.email
            : user?.email);
    TextEditingController phoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Complete Your Profile",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                // Name Input
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Full Name"),
                ),

                // Email Input (if hidden by Apple)
                TextField(
                  controller: emailController,
                  decoration:
                      InputDecoration(labelText: "Email", hintText: "optional"),
                  keyboardType: TextInputType.emailAddress,
                ),

                // Phone Number Input
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    String fullName = nameController.text.trim();
                    String email = emailController.text.trim();
                    String phone = phoneController.text.trim();

                    if (fullName.isEmpty || email.isEmpty || phone.isEmpty) {
                      CustomSnackBar.showSnackbar(
                          context: context, message: 'Please fill all fields');
                      return;
                    }
                    //Navigator.pop(context);
                    _saveChanges(phoneController.text, "applesign1", context,
                        user, fullName);
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveChanges(String phoneNo, String password,
      BuildContext context, User? user, name) async {
    hideKeyBoard();

    SignUpRequest request = SignUpRequest(
        customer: CustomerSignUp(
      password: password,
      email: "${user?.email}",
      firstName: extractNames("${name}", true),
      lastName: extractNames("${name}", false),
      phoneNumber: phoneNo,
    ));

    await Provider.of<MainViewModel>(context, listen: false).signUpData(
        "api/v1/app/temp_customers/initiate_temp_customer", request);
    ApiResponse apiResponse =
        Provider.of<MainViewModel>(context, listen: false).response;
    getSignUpResponse(context, apiResponse, request);
  }

  void _showSignUpBottomSheet(BuildContext context, User? user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8, minHeight: screenHeight * 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SignUpForm(user),
        );
      },
    );
  }

  Future<Widget> getSignUpResponse(BuildContext context,
      ApiResponse apiResponse, SignUpRequest request) async {
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
        await Helper.savePassword(request.customer?.password);

        Navigator.pushNamed(context, "/OTPVerifyScreen",
            arguments: "${request.customer?.phoneNumber}");
        return Container();
      case Status.ERROR:
        if (message.contains("Invalid Request")) {
          message =
              "Something went wrong, Please signup normally for the time being";
        } else if (message.contains("401")) {
        } else if (apiResponse.status == 500) {
          CustomAlert.showToast(
              context: context, message: "Something went wrong!");
        } else if (apiResponse.status == 422) {
          CustomAlert.showToast(context: context, message: message);
        } else {
          CustomAlert.showToast(context: context, message: message);
        }
        return Center(
          child: Text('Try again later..'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }
}

class SignUpForm extends StatefulWidget {
  final User? user;

  const SignUpForm(this.user, {Key? key}) : super(key: key);

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final displayName = widget.user?.displayName;
    if (displayName != null && displayName.trim().isNotEmpty) {
      final nameParts = splitFullName(displayName);
      firstNameController.text = nameParts['firstName'] ?? '';
      lastNameController.text = nameParts['lastName'] ?? '';
    }
  }

  Map<String, String> splitFullName(String displayName) {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    return {'firstName': firstName, 'lastName': lastName};
  }

  final maskFormatter = MaskTextInputFormatter(
    mask: '(###) ###-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  bool isLoading = false;

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      _saveChanges(phoneController.text, "applesign1", context, widget.user,
          firstNameController.text, lastNameController.text);
      // Simulate some network request
      await Future.delayed(Duration(seconds: 2));

      setState(() => isLoading = false);

      print("Form submitted with:");
      print("First Name: ${firstNameController.text}");
      print("Last Name: ${lastNameController.text}");
      print("Phone: +1 ${maskFormatter.getUnmaskedText()}");
    }
  }

  Future<void> _saveChanges(
      String phoneNo,
      String password,
      BuildContext context,
      User? user,
      String firstName,
      String lastName) async {
    hideKeyBoard();
    String cleanPhone = maskFormatter.getUnmaskedText();
    SignUpRequest request = SignUpRequest(
        customer: CustomerSignUp(
      password: password,
      email: "${user?.email}",
      firstName: firstName,
      lastName: lastName,
      phoneNumber: cleanPhone,
    ));

    await Provider.of<MainViewModel>(context, listen: false).signUpData(
        "api/v1/app/temp_customers/initiate_temp_customer", request);
    ApiResponse apiResponse =
        Provider.of<MainViewModel>(context, listen: false).response;
    getSignUpResponse(context, apiResponse, request);
  }

  Future<Widget> getSignUpResponse(BuildContext context,
      ApiResponse apiResponse, SignUpRequest request) async {
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
        //await Helper.savePassword(_passwordController.text);

        Navigator.pushNamed(context, "/OTPVerifyScreen",
            arguments: "${request.customer?.phoneNumber}");
        return Container();
      case Status.ERROR:
        if (message.contains("Invalid Request")) {
          message =
              "Something went wrong, Please signup normally for the time being";
        } else if (message.contains("401")) {
        } else if (apiResponse.status == 500) {
          CustomAlert.showToast(
              context: context, message: "Something went wrong!");
        } else if (apiResponse.status == 422) {
          CustomAlert.showToast(context: context, message: message);
        } else {
          CustomAlert.showToast(context: context, message: message);
        }
        return Center(
          child: Text('Try again later..'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        // 🔄 Real-time validation
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 5,
                width: 50,
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Center(
              child: Text(
                'Sign Up',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Text("First Name"),
            TextFormField(
              controller: firstNameController,
              decoration: InputDecoration(
                hintText: "Required",
                border: UnderlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'First name is required'
                  : null,
            ),
            SizedBox(height: 8),
            Text("Last Name"),
            TextFormField(
              controller: lastNameController,
              decoration: InputDecoration(
                hintText: "Required",
                border: UnderlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Last name is required'
                  : null,
            ),
            SizedBox(height: 8),
            Text("Email"),
            Text(
              widget.user?.email ?? "",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(
              height: 8,
            ),
            Text("Phone"),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              // 👈 This adds the "Done" button
              inputFormatters: [maskFormatter],
              decoration: InputDecoration(
                prefixText: '+1 ',
                hintText: "(123) 456-7890",
                border: UnderlineInputBorder(),
              ),
              validator: (value) {
                String digits = maskFormatter.getUnmaskedText();
                final regex = RegExp(r'^[2-9]\d{2}[2-9]\d{2}\d{4}$'); // Canada
                if (digits.isEmpty) {
                  return 'Phone number is required';
                } else if (!regex.hasMatch(digits)) {
                  return 'Enter a valid Canadian phone number';
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).unfocus();
              },
            ),
            SizedBox(height: 10),
            Text(
              "Your number lets TheChaiBar and Admin contact you about orders. It’s masked to help protect your privacy.",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            isLoading
                ? CustomCircularProgress()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: _handleSubmit,
                    child: Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
