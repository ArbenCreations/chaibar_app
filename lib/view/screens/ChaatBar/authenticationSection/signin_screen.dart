import 'package:ChaatBar/model/apis/api_response.dart';
import 'package:ChaatBar/model/request/signInRequest.dart';
import 'package:ChaatBar/model/response/rf_bite/signInResponse.dart';
import 'package:ChaatBar/utils/Util.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/sign_in_with_google.dart';
import 'package:ChaatBar/view_model/main_view_model.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../languageSection/Languages.dart';
import '../../../../model/response/rf_bite/profileResponse.dart';
import '../../../../theme/AppColor.dart';
import '../../../../utils/Helper.dart';
import '../../../component/connectivity_service.dart';
import '../../../component/toastMessage.dart';

class SigninScreen extends StatefulWidget {
  @override
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  bool passwordVisible = false;
  bool isLoading = false;
  final ConnectivityService _connectivityService = ConnectivityService();

  bool inputValid = false;
  bool isChecked = false;
  late double screenWidth;
  late bool isDarkMode;
  String? deviceToken;

  @override
  void initState() {
    super.initState();
    passwordVisible = true;
    inputValid = false;
    Helper.getDeviceToken().then((token) {
      setState(() {
        deviceToken = token;
      });
    });
    /*setState(() {
      _passwordController.text = "12345678";
      _emailController.text = "vibhuti@rootficus.com";
    });*/
  }

  void _isValidInput() {
    if (_passwordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.length >= 8) {
      setState(() {
        inputValid = true;
      });
    } else {
      setState(() {
        inputValid = false;
      });
    }
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
          body: CustomScrollView(slivers: [
        SliverAppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: isDarkMode ? AppColor.WHITE : AppColor.PRIMARY,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
          ),
          expandedHeight: 250.0,
          floating: false,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: AppColor.WHITE,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          stretch: false,
          pinned: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Image.asset(
              "assets/signUpBG.jpg",
              fit: BoxFit.fill,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: GestureDetector(
            onTap: () {
              hideKeyBoard();
            },
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      height: screenHeight,
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: screenHeight -
                                MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Container(
                                    width: screenWidth,
                                    padding: EdgeInsets.zero,
                                    child: Card(
                                      elevation: 0,
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(40),
                                              topRight: Radius.circular(40))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12.0, vertical: 20),
                                        child: Column(
                                          children: [
                                            SizedBox(height: 20),
                                            _buildLabelText(
                                                context,
                                                "${Languages.of(context)?.labelWelcomeBack}",
                                                24,
                                                true),
                                            _buildLabelText(
                                                context,
                                                "${Languages.of(context)?.labelWeMissedYou}",
                                                14,
                                                false),
                                            SizedBox(height: 25),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Column(
                                                children: [
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
                                                  SizedBox(height: 6),
                                                  _buildPasswordInput(
                                                      context,
                                                      Languages.of(context)!
                                                          .labelPassword,
                                                      _passwordController,
                                                      Icon(
                                                        Icons.password,
                                                        size: 18,
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                      passwordVisible,
                                                      isDarkMode),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 32.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(context,
                                                      '/ForgotPasswordScreen');
                                                },
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    "${Languages.of(context)?.labelForgotPass}",
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 85),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10.0),
                                              child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    _buildFooter(
                                                        context, apiResponse),
                                                  ]),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Center(
                                                child: Text(
                                              "OR",
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            )),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            GestureDetector(
                                              onTap: () async {
                                                User? user =
                                                    await signInWithGoogle(
                                                        context,
                                                        deviceToken.toString());
                                                if (user != null) {
                                                  print(
                                                      "Signed in: ${user.displayName}");
                                                  _signIn(user);
                                                  //Navigator.pushReplacementNamed(context, "/VendorLocationScreen");
                                                }
                                              },
                                              child: Card(
                                                margin: EdgeInsets.zero,
                                                color: Colors.grey.shade100,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            6)),
                                                child: Container(
                                                  width: screenWidth * 0.6,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 9),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      color: AppColor.PRIMARY),
                                                  child: Center(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        child: Image.asset(
                                                          "assets/google_logo.png",
                                                          width: 22,
                                                          fit: BoxFit.fill,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        "Sign In With Google",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            color:
                                                                AppColor.WHITE),
                                                      ),
                                                    ],
                                                  )),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "${Languages.of(context)?.labelNeedAcc} ",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/SignUpScreen');
                                                    },
                                                    child: Text(
                                                      "${Languages.of(context)?.labelRegisterHere}",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.green,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ),
                                                ],
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Stack(
                    children: [
                      // Block interaction
                      ModalBarrier(
                          dismissible: false, color: Colors.transparent),
                      // Loader indicator
                      Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ])),
    );
  }

  _buildLabelText(BuildContext context, String text, double size, bool isBold) {
    return Text(
      text,
      style: TextStyle(
          fontSize: size,
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal),
    );
  }

  Widget _buildPhoneInput(BuildContext context, String text,
      TextEditingController nameController, Icon icon) {
    //nameController.text = widget.data as String;
    return Card(
      child: Container(
        //height: 60,
        width: screenWidth * 0.8,
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border(
              top: BorderSide(
                  color: isDarkMode ? Colors.grey : Colors.black54, width: 0.4),
              bottom: BorderSide(
                  color: isDarkMode ? Colors.grey : Colors.black54, width: 0.4),
              right: BorderSide(
                  color: isDarkMode ? Colors.grey : Colors.black54, width: 0.4),
              left: BorderSide(
                  color: isDarkMode ? Colors.grey : Colors.black54,
                  width: 0.4)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                style: TextStyle(
                  fontSize: 14.0,
                ),
                obscureText: false,
                obscuringCharacter: "*",
                controller: nameController,
                onChanged: (value) {
                  _isValidInput();
                },
                textAlignVertical: TextAlignVertical.top,
                onSubmitted: (value) {},
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: text,
                  alignLabelWithHint: true,
                  counterText: "",
                  icon: icon,
                  /*suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${Languages.of(context)?.labelSaveId}",
                          style: TextStyle(fontSize: 10),
                        ),
                        Checkbox(
                          checkColor: Colors.white,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          semanticLabel:
                              "${Languages.of(context)?.labelSaveId}",
                          side: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black),
                          value: isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                        ),
                      ],
                    )*/
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordInput(
    BuildContext context,
    String text,
    TextEditingController nameController,
    Icon icon,
    bool passwordVisibles,
    bool isDarkMode,
  ) {
    return Card(
      child: Container(
        width: screenWidth * 0.8,
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          border: Border(
              top: BorderSide(
                  color: isDarkMode ? Colors.grey : Colors.black54, width: 0.4),
              bottom: BorderSide(
                  color: isDarkMode ? Colors.grey : Colors.black54, width: 0.4),
              right: BorderSide(
                  color: isDarkMode ? Colors.grey : Colors.black54, width: 0.4),
              left: BorderSide(
                  color: isDarkMode ? Colors.grey : Colors.black54,
                  width: 0.4)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Expanded(
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                style: TextStyle(fontSize: 14.0),
                obscureText: passwordVisibles,
                obscuringCharacter: "*",
                controller: nameController,
                onChanged: (value) {
                  _isValidInput();
                },
                scrollPadding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                onSubmitted: (value) {},
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: text,
                  alignLabelWithHint: true,
                  icon: icon,
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisibles
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 20,
                      color: isDarkMode ? Colors.white60 : Colors.black45,
                    ),
                    onPressed: () {
                      setState(
                        () {
                          passwordVisible = !passwordVisible;
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ApiResponse apiResponse) {
    return Column(
      children: [
        SizedBox(
          width: screenWidth * 0.7,
          height: 45,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
            ),
            child: ElevatedButton(
              onPressed: () async {
                _signIn(null);
                //_getApiAccessKey();
              },
              child: Text(
                Languages.of(context)!.labelLogin,
                style: TextStyle(
                    fontSize: 14,
                    color: inputValid ? Colors.white : AppColor.PRIMARY),
              ),
              style: ElevatedButton.styleFrom(
                  //padding: EdgeInsets.symmetric(vertical: 10.0),
                  backgroundColor: inputValid ? AppColor.PRIMARY : Colors.white,
                  elevation: 3,
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(2))),
            ),
          ),
        ),
      ],
    );
  }

  void Validate(String email) {
    bool isValid = EmailValidator.validate(email);
    print(isValid);
  }

  Future<void> _signIn(User? user) async {
    hideKeyBoard();
    _isValidInput();
    //Navigator.pushNamed(context, "/VendorScreen");
    const maxDuration = Duration(seconds: 2);

    if (inputValid) {
      SignInRequest request = SignInRequest(
          customer: CustomerSignIn(
        deviceToken: "${deviceToken}",
        email: _emailController.text,
        password: _passwordController.text,
      ));

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
        await Provider.of<MainViewModel>(context, listen: false)
            .signInWithPass("/api/v1/app/customers/sign_in", request);

        ApiResponse apiResponse =
            Provider.of<MainViewModel>(context, listen: false).response;
        getSignInResponse(context, apiResponse);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${Languages.of(context)?.labelPleaseEnterAllDetails}'),
        duration: maxDuration,
      ));
    }
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
        );
        Helper.saveProfileDetails(data);

        String token = "${mediaList?.token}";
        print("token :: $token ");
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
        Navigator.pushReplacementNamed(context, "/VendorLocationScreen",
            arguments: "");

        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("message : ${apiResponse.message}");
        ToastComponent.showToast(
            context: context, message: apiResponse.message);
        return Center();
      case Status.INITIAL:
      default:
        return Center();
    }
  }
}
