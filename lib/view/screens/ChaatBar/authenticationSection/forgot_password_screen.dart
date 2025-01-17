import 'package:ChaatBar/theme/AppColor.dart';
import 'package:ChaatBar/utils/Util.dart';
import 'package:ChaatBar/view/component/toastMessage.dart';
import 'package:ChaatBar/view/screens/ChaatBar/authenticationSection/signin_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../languageSection/Languages.dart';
import '../../../../model/apis/api_response.dart';
import '../../../../model/request/createOtpChangePass.dart';
import '../../../../model/response/rf_bite/createOtpChangePassResponse.dart';
import '../../../../utils/Helper.dart';
import '../../../../view_model/main_view_model.dart';
import '../../../component/connectivity_service.dart';
import '../../../component/session_expired_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late double screenWidth;
  late double screenHeight;
  bool isLoading = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;
  bool isValid = false;
  bool isOtpBoxVisible = false;
  String otp = '';
  bool phoneNumberValid = false;
  bool isDarkMode = false;
  String selectedItem = "";

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    isValid = false;
    phoneNumberValid = false;
    newPasswordVisible = true;
    confirmPasswordVisible = true;
    //_fetchData();
    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _controllers[i].text.isEmpty) {
          // Automatically select all text when the field gains focus
          _controllers[i].selection = TextSelection(
              baseOffset: 0, extentOffset: _controllers[i].text.length);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<Widget> generateOtpResponse(
      BuildContext context, ApiResponse apiResponse) async {
    CreateOtpChangePassResponse? mediaList =
        apiResponse.data as CreateOtpChangePassResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        String data = "${mediaList?.email}";
        ToastComponent.showToast(
            context: context, message: apiResponse.message);

        Navigator.pushNamed(context, "/OtpForgotPassScreen", arguments: data);

        setState(() {
          isOtpBoxVisible = true;
        });

        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        } else {
          ToastComponent.showToast(
              context: context, message: apiResponse.message);
        }
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

  Future<Widget> verifyOtpResponse(
      BuildContext context, ApiResponse apiResponse) async {
    final mediaList = apiResponse.data;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("rwrwr ");
        //Navigator.pushNamed(context, '/ProfileScreen');
        ToastComponent.showToast(
            context: context, message: apiResponse.message);
        Helper.clearAllSharedPreferences();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SigninScreen()),
          (Route<dynamic> route) => false,
        );

        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}"))
          SessionExpiredDialog.showDialogBox(context: context);
        return Center(
            //child: Text('Please try again later!!!'),
            );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Stack(children: [
      Scaffold(
          body: CustomScrollView(slivers: [
        CupertinoSliverNavigationBar(
          largeTitle: Text(
            "${Languages.of(context)!.labelForgotPass}",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColor.TEXT_COLOR),
          ),
          middle: Text(
            "${Languages.of(context)!.labelForgotPass}",
            style: TextStyle(
                fontSize: 24,
                color: isDarkMode ? Colors.white : AppColor.TEXT_COLOR),
          ),
          backgroundColor:
              isDarkMode ? AppColor.DARK_BG_COLOR : AppColor.BG_COLOR,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 24,
            ),
          ),
          alwaysShowMiddle: false,
          border: Border.all(color: Colors.transparent),
        ),
        SliverToBoxAdapter(
          child: Stack(
            children: [
              SingleChildScrollView(
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPhoneNumberTextField(),
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
                  : SizedBox(),
            ],
          ),
        )
      ])),
      /*isLoading
          ? Stack(
        children: [
          // Block interaction
          ModalBarrier(
              dismissible: false,
              color: Colors.transparent),
          // Loader indicator
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      )
          : SizedBox(),*/
    ]);
  }

  Widget _buildPhoneNumberTextField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: _buildLabelText(
                    context, "${Languages.of(context)?.labelEmail}", 12, false),
              ),
            ),
            Card(
              elevation: 2,
              child: Container(
                height: 55,
                width: screenWidth,
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border(
                      top: BorderSide(
                          color: isDarkMode ? Colors.grey : Colors.black54,
                          width: 0.4),
                      bottom: BorderSide(
                          color: isDarkMode ? Colors.grey : Colors.black54,
                          width: 0.4),
                      right: BorderSide(
                          color: isDarkMode ? Colors.grey : Colors.black54,
                          width: 0.4),
                      left: BorderSide(
                          color: isDarkMode ? Colors.grey : Colors.black54,
                          width: 0.4)),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        controller: _emailController,
                        //onChanged: isV,
                        keyboardType: TextInputType.emailAddress,
                        onSubmitted: (value) {
                          // if (value.isNotEmpty) {
                          //   Provider.of<MainViewModel>(context, listen: false)
                          //       .setSelectedMedia(null);
                          //   Provider.of<MainViewModel>(context, listen: false)
                          //       .fetchMediaData(value, phoneRequest);
                          // }
                        },
                        decoration: InputDecoration(
                          counterText: "",
                          border: InputBorder.none,
                          hintText: 'XXXXXXXXXX',
                          //suffixIcon:Icon(Icons.phone_enabled_sharp),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(AppColor.PRIMARY),
                ),
                onPressed: () async {
                  if (_emailController.text.isNotEmpty) {
                    print(_emailController.text);
                    setState(() {
                      isLoading = true;
                    });
                    var email = "${_emailController.text}";
                    CreateOtpChangePassRequest request =
                        CreateOtpChangePassRequest(email: '$email');

                    await Provider.of<MainViewModel>(context, listen: false)
                        .CreateOtpChangePass(
                            "/api/v1/app/customers/gen_otp_for_reset_pass",
                            request);
                    ApiResponse apiResponse =
                        Provider.of<MainViewModel>(context, listen: false)
                            .response;
                    generateOtpResponse(context, apiResponse);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text(Languages.of(context)!.labelEnterValidPhone),
                    ));
                  }
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
          ],
        ),
      ),
    );
  }

  void isInputValid() {
    String otp = _controllers.map((controller) => controller.text).join();
    if (otp.isNotEmpty &&
        otp.length == 6 &&
        _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text &&
        _newPasswordController.text.length >= 8) {
      isValid = true;
    } else {
      isValid = false;
    }
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
}
