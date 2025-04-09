import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../theme/CustomAppColor.dart';
import '../../../language/Languages.dart';
import '../../../model/request/signInRequest.dart';
import '../../../model/response/profileResponse.dart';
import '../../../model/response/signInResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../utils/Helper.dart';
import '../../../utils/apis/api_response.dart';
import '../../component/connectivity_service.dart';
import '../../component/toastMessage.dart';

class GetStartedScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<GetStartedScreen> {
  static const maxDuration = Duration(seconds: 2);
  bool isLoading = false;
  String? deviceToken;

  @override
  void initState() {
    super.initState();
    Helper.getDeviceToken().then((token) {
      setState(() {
        deviceToken = token;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final ConnectivityService _connectivityService = ConnectivityService();
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    var mediaWidth = MediaQuery.of(context).size.width;
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }
          SystemNavigator.pop();
        },
        child: Scaffold(
            backgroundColor: Colors.white,
            body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/chai_back.jpg"),
                      fit: BoxFit.cover)),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(6)
                              )
                            ),
                            padding: EdgeInsets.all(5.0),
                            margin: EdgeInsets.only(top: 15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              child: Image.asset(
                                "assets/app_logo.png",
                                height: 60,
                                width: 200,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Center(
                            child: MaterialButton(
                              minWidth: mediaWidth * 0.55,
                              color: CustomAppColor.Primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              height: 48,
                              onPressed: () async {
                                Navigator.of(context)
                                    .pushReplacementNamed("/SignInScreen");
                              },
                              child: Text(
                                "Sign In",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: MaterialButton(
                              minWidth: mediaWidth * 0.55,
                              color: CustomAppColor.Primary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              height: 48,
                              onPressed: () async {
                                Navigator.of(context)
                                    .pushReplacementNamed("/RegisterScreen");
                              },
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              SignInRequest request = SignInRequest(
                                  customer: CustomerSignIn(
                                deviceToken: "${deviceToken}",
                                email: "guest@isekaitech.com",
                                password: "Isekai@123",
                              ));

                              bool isConnected =
                                  await _connectivityService.isConnected();
                              if (!isConnected) {
                                setState(() {
                                  isLoading = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${Languages.of(context)?.labelNoInternetConnection}'),
                                      duration: maxDuration,
                                    ),
                                  );
                                });
                              } else {
                                await Provider.of<MainViewModel>(context,
                                        listen: false)
                                    .signInWithPass(
                                        "/api/v1/app/customers/sign_in",
                                        request);

                                ApiResponse apiResponse =
                                    Provider.of<MainViewModel>(context,
                                            listen: false)
                                        .response;
                                getSignInResponse(context, apiResponse);
                              }
                            },
                            child: Container(
                              width: mediaWidth * 0.55,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                // Change this to match your theme
                                borderRadius: BorderRadius.circular(8),
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
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )));
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

        //await Helper.savePassword(_passwordController.text);
        String? password = await Helper.getPassword();
        print("password: ${password}");
        Navigator.pushReplacementNamed(context, "/VendorsListScreen",
            arguments: "");

        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("message : ${apiResponse.message}");
        CustomToast.showToast(context: context, message: apiResponse.message);
        return Center();
      case Status.INITIAL:
      default:
        return Center();
    }
  }
}
