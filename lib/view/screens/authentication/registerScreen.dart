import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/model/request/signUpRequest.dart';
import '/model/response/signUpInitializeResponse.dart';
import '/utils/Util.dart';
import '../../../../language/Languages.dart';
import '../../../../theme/CustomAppColor.dart';
import '../../../../utils/Helper.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomAlert.dart';
import '../../component/connectivity_service.dart';
import '../../component/custom_button_component.dart';
import '../../component/googleSignIN.dart';

class RegisterScreen extends StatefulWidget {
  final String? userId;

  RegisterScreen({Key? key, this.userId}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  late double mediaWidth;
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
  bool isLogin = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
        Navigator.pushReplacementNamed(context, "/SignInScreen");
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          onTap: () {
            hideKeyBoard();
          },
          child: Container(
            height: screenHeight,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/signUpBack.png"),
                    fit: BoxFit.cover)),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    height: screenHeight,
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          "assets/app_logo.png",
                          height: 45,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 10),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                buildTextInput(
                                    context,
                                    "${Languages.of(context)!.labelFirstname}",
                                    _nameController,
                                    Icons.account_box_outlined),
                                SizedBox(width: 5),
                                buildTextInput(
                                    context,
                                    "${Languages.of(context)!.labelLastname}",
                                    _lastNameController,
                                    Icons.account_box_outlined),
                                _buildEmailInput(
                                    context,
                                    "Enter your ${Languages.of(context)!.labelEmail}",
                                    _emailController,
                                    Icons.email_outlined),
                                _buildPhoneInput(
                                    context,
                                    "Enter your ${Languages.of(context)!.labelPhoneNumber}",
                                    _phoneController,
                                    Icons.call),
                                _buildPasswordTextField(
                                    context,
                                    "New ${Languages.of(context)!.labelPassword}",
                                    _passwordController,
                                    passwordVisible,
                                    isDarkMode,
                                    "password",
                                    Icons.password),
                                _buildPasswordTextField(
                                    context,
                                    Languages.of(context)!.labelConfirmPass,
                                    _confirmPasswordController,
                                    confirmPasswordVisible,
                                    isDarkMode,
                                    "confirmPassword",
                                    Icons.verified_user),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        _submitButton(null),
                        SizedBox(
                          height: 5,
                        ),
                        _divider(),
                        SizedBox(
                          height: 5,
                        ),
                        _googleButton(),
                        SizedBox(
                          height: 5,
                        ),
                        /*SizedBox(
                          width: mediaWidth * 0.55,
                          child: SignInWithAppleButton(
                            style: SignInWithAppleButtonStyle.black,
                            text: "Sign up",
                            //iconAlignment: IconAlignment.center,
                            onPressed: () async {
                              User? user = await context
                                  .read<AuthenticationProvider>()
                                  .signInWithApple();
                              if (user != null) {
                                // Check if we have all required info
                                print(
                                    "User signed in successfully: ${user.email}");
                                print(
                                    "User signed in successfully: ${user.displayName}");
                                bool isEmailRelay = user.email?.endsWith(
                                        "@privaterelay.appleid.com") ??
                                    true;
                                bool isNameMissing = user.displayName == null ||
                                    user.displayName!.isEmpty;

                                if (isEmailRelay || isNameMissing) {
                                  // Show bottom sheet to collect missing details
                                  showUserDetailsBottomSheet(context, user);
                                } else {
                                  print(
                                      "User signed in successfully: ${user.email}");
                                }
                              } else {
                                print("Apple sign-in failed or was canceled.");
                              }
                            },
                          ),
                        ),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "Have an account?",
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, "/SignInScreen");
                                },
                                child: Text(
                                  "Sign in",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                )),
                          ],
                        ),
                      ],
                    ),
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
      ),
    );
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
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

  Widget _googleButton() {
    return GestureDetector(
      onTap: () async {
        User? user = await signInWithGoogle(context, "$deviceToken");

        if (user != null) {
          _showModal(context, user);
          print("Signed in: ${user.displayName}");
        }
      },
      child: Container(
        height: 50,
        width: mediaWidth * 0.55,
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: CustomAppColor.PrimaryAccent,
                  border: Border(
                      right: BorderSide(width: 0.4, color: Colors.white),
                      top: BorderSide.none),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(5),
                      topLeft: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/google_logo.png",
                  width: 24,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: CustomAppColor.PrimaryAccent,
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(5),
                      topRight: Radius.circular(5)),
                ),
                alignment: Alignment.center,
                child: Text('Sign up with Google',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _submitButton(User? user) {
    return GestureDetector(
      onTap: () {
        //_checkValidInput();
        _signUp(user);
        if (inputValid) {
          _signUp(user);
        }
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: mediaWidth * 0.55,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.black, // Change this to match your theme
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                "Sign Up",
                style: TextStyle(fontSize: 16, color: Colors.white),
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
    );
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

  Widget _buildEmailInput(BuildContext context, String text,
      TextEditingController emailController, IconData icon) {
    return Container(
      width: mediaWidth,
      margin: EdgeInsets.symmetric(vertical: 6.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: CustomAppColor.TextFieldBackColor,
        shape: BoxShape.rectangle,
        border: Border(
            top: BorderSide(
                color: isDarkMode
                    ? Colors.grey
                    : CustomAppColor.TextFieldBackColor,
                width: 0.4),
            bottom: BorderSide(
                color: isDarkMode
                    ? Colors.grey
                    : CustomAppColor.TextFieldBackColor,
                width: 0.4),
            right: BorderSide(
                color: isDarkMode
                    ? Colors.grey
                    : CustomAppColor.TextFieldBackColor,
                width: 0.4),
            left: BorderSide(
                color: isDarkMode
                    ? Colors.grey
                    : CustomAppColor.TextFieldBackColor,
                width: 0.4)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
            maxLength: 30,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              errorStyle: TextStyle(fontSize: 9, height: 0.5),
              errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 0.4)),
              hintText: text,
              hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
              counterText: "",
              icon: Icon(
                icon,
                size: 18,
              ),
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
        ],
      ),
    );
  }

  Widget _buildPhoneInput(BuildContext context, String text,
      TextEditingController numberController, IconData icon) {
    return Container(
      width: mediaWidth,
      margin: EdgeInsets.symmetric(vertical: 6.0),
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        color: CustomAppColor.TextFieldBackColor,
        shape: BoxShape.rectangle,
        border: Border(
            top: BorderSide(
                color: isDarkMode
                    ? Colors.grey
                    : CustomAppColor.TextFieldBackColor,
                width: 0.4),
            bottom: BorderSide(
                color: isDarkMode
                    ? Colors.grey
                    : CustomAppColor.TextFieldBackColor,
                width: 0.4),
            right: BorderSide(
                color: isDarkMode
                    ? Colors.grey
                    : CustomAppColor.TextFieldBackColor,
                width: 0.4),
            left: BorderSide(
                color: isDarkMode
                    ? Colors.grey
                    : CustomAppColor.TextFieldBackColor,
                width: 0.4)),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: numberController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Only allow numbers
            ],
            maxLength: 12,
            // "+1 " + 10 digits
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              errorStyle: TextStyle(fontSize: 9, height: 0.5),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 0.4),
              ),
              hintText: "Enter phone number",
              hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
              counterText: "",
              icon: Icon(Icons.phone, size: 18),
            ),
            validator: (value) {
              if (value == null || value.length != 12) {
                return "Please enter a valid 10-digit phone number";
              }
              return null;
            },
          )
        ],
      ),
    );
  }

  Widget buildTextInput(BuildContext context, String text,
      TextEditingController nameController, IconData icon) {
    return Container(
      width: mediaWidth,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      margin: EdgeInsets.symmetric(vertical: 6.0),
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
            controller: nameController,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Enter your $text",
              hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
              // Adjust padding
              icon: Icon(
                icon,
                size: 18,
              ),
              counterText: "",
              errorStyle: TextStyle(fontSize: 9, height: 0.5),
              // Reduces error text size
              errorMaxLines: 2,
              // Allows error messages to wrap properly
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 0.4),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter a $text";
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordTextField(
      BuildContext context,
      String text,
      TextEditingController passwordController,
      bool visibility,
      bool isDarkMode,
      String type,
      IconData icon) {
    return Container(
      width: mediaWidth,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      margin: EdgeInsets.symmetric(vertical: 6.0),
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
            obscureText: visibility,
            style: TextStyle(fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: text,
              contentPadding:
                  EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
              // Adjust padding
              icon: Icon(
                icon,
                size: 18,
              ),
              counterText: "",
              hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
              errorStyle: TextStyle(fontSize: 9, height: 0.5),
              // Reduces error text size
              errorMaxLines: 2,
              // Allows error messages to wrap properly
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 0.4),
              ),
              suffixIcon: GestureDetector(
                child: Icon(
                  visibility ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                ),
                onTap: () {
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "$text is required";
              }
              if (!hasMinLength(value)) {
                return "$text must be at least 8 characters long";
              }
              if (!hasUppercase(value)) {
                return "$text must contain at least one uppercase letter";
              }
              if (!hasDigit(value)) {
                return "$text must contain at least one digit";
              }
              if (!hasSpecialCharacter(value)) {
                return "$text must contain at least one special character";
              }
              if (_passwordController.text != _confirmPasswordController.text) {
                return "Password doesn't match";
              }
              return null;
            },
          ),
        ],
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
    if (_formKey.currentState?.validate() == true) {
    } else {
      print("Not Validated");
    }
    print(_nameController.text);
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
          //deviceToken: deviceToken,
          email: _emailController.text,
          password: _passwordController.text,
          firstName: _nameController.text,
          lastName: _lastNameController.text,
          phoneNumber: _phoneController.text,
        ));

        await Provider.of<MainViewModel>(context, listen: false).signUpData(
            "api/v1/app/temp_customers/initiate_temp_customer", request);
        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getSignUpResponse(context, apiResponse, request);
      }
    }
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
        await Helper.savePassword(_passwordController.text);

        if (_phoneController.text.isNotEmpty) {
          Navigator.pushNamed(context, "/OTPVerifyScreen",
              arguments: "${_phoneController.text}");
        } else {
          Navigator.pushNamed(context, "/OTPVerifyScreen",
              arguments: "${request.customer?.phoneNumber}");
        }
        return Container();
      case Status.ERROR:
        if (message.contains("Invalid Request")) {
          message =
              "Something went wrong, Please signup normally for the time being";
        } else if (message.contains("401")) {
        } else if (apiResponse.status == 500) {
          CustomAlert.showToast(
              context: context, message: "Something went wrong!");
        } else {
          CustomAlert.showToast(context: context, message: "message");
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

  void _showModal(BuildContext context, User? user) {
    showDialog<void>(
        context: context,
        barrierDismissible: true,
        useSafeArea: true,
        builder: (BuildContext context) {
          bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
          TextEditingController phoneController = TextEditingController();
          TextEditingController passwordController = TextEditingController();
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 10),
            title: Text(
              "Please enter your phone number for verification",
              style: TextStyle(fontSize: 12),
            ),
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
                  Text("Signing up as: ${user?.displayName}"),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    "Email : ${user?.email}",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4.0),
                    margin: EdgeInsets.symmetric(vertical: 4.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: isDarkMode
                            ? CustomAppColor.DarkCardColor
                            : Colors.white,
                        border: Border.all(color: Colors.grey, width: 0.5)),
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: TextStyle(
                              fontSize: 11.0,
                            ),
                            obscureText: false,
                            obscuringCharacter: "*",
                            controller: phoneController,
                            onChanged: (value) {},
                            onSubmitted: (value) {},
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: Languages.of(context)!.labelPhoneNumber,
                              hintStyle:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                              icon: Icon(
                                Icons.call,
                                size: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              CustomButtonComponent(
                  text: "Continue",
                  mediaWidth: MediaQuery.of(context).size.width,
                  textColor: Colors.white,
                  buttonColor: CustomAppColor.PrimaryAccent,
                  isDarkMode: isDarkMode,
                  verticalPadding: 10,
                  onTap: () {
                    _saveChanges(phoneController.text, "googlesign1", context,
                        user, user?.displayName);
                  })
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        });
  }

  void showUserDetailsBottomSheet(BuildContext context, User user) {
    TextEditingController nameController =
        TextEditingController(text: user.displayName);
    TextEditingController emailController = TextEditingController(
        text: user.email?.endsWith("@privaterelay.appleid.com") == true
            ? user.email
            : user.email);
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
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Please fill all fields")));
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
}
