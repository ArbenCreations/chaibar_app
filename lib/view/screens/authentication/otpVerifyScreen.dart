import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:provider/provider.dart';

import '/model/request/otpVerifyRequest.dart';
import '/model/response/signUpVerifyResponse.dart';
import '../../../../language/Languages.dart';
import '../../../../theme/CustomAppColor.dart';
import '../../../model/request/signUpRequest.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/connectivity_service.dart';
import '../../component/customNumberKeyboard.dart';
import '../../component/custom_circular_progress.dart';

class OTPVerifyScreen extends StatefulWidget {
  final String? data; // Define the 'data' parameter here

  OTPVerifyScreen({Key? key, this.data}) : super(key: key);

  @override
  _OTPVerifyScreenState createState() => _OTPVerifyScreenState();
}

class _OTPVerifyScreenState extends State<OTPVerifyScreen> {
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<String> _otp = List.generate(6, (_) => '');

  String dropdownValue = "";
  bool isValid = false;
  bool resendOtp = false;
  String phoneNo = "";
  late double mediaWidth;
  bool isLoading = false;
  List<String> _inputValues = ['', '', '', '', '', ''];
  late DateTime otpEndTime;

  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    isValid = false;
    resendOtp = false;
    otpEndTime = DateTime.now().add(Duration(minutes: 1, seconds: 30));
    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _controllers[i].text.isEmpty) {
          _controllers[i].selection = TextSelection(
              baseOffset: 0, extentOffset: _controllers[i].text.length);
        }
      });
    }
  }

  void _handleKeyTap(String value) {
    setState(() {
      for (int i = 0; i < _inputValues.length; i++) {
        if (_inputValues[i].isEmpty) {
          _inputValues[i] = value;
          break;
        }
      }
    });
  }

  void _handleBackspace() {
    setState(() {
      for (int i = _inputValues.length - 1; i >= 0; i--) {
        if (_inputValues[i].isNotEmpty) {
          _inputValues[i] = '';
          break;
        }
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _isValidOtp(String input) {
    print(input);
    if (input.isNotEmpty && input.length >= 10) {
      setState(() {
        isValid = true;
      });
    } else {
      setState(() {
        isValid = false;
      });
    }
  }

  Future<Widget> getOtpResponseDataWidget(
      BuildContext context, ApiResponse apiResponse) async {
    SignUpVerifyResponse? signUpVerifyResponse =
        apiResponse.data as SignUpVerifyResponse?;
    var message = apiResponse?.message.toString();
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("OtpVerify ${signUpVerifyResponse?.token}");
        CustomSnackBar.showSnackbar(
            context: context,
            message: "Signup completed. Please Login to continue.");

        Navigator.pushReplacementNamed(context, "/SignInScreen", arguments: "");
        return Container();
      case Status.ERROR:
        CustomSnackBar.showSnackbar(context: context, message: message);
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

  Widget getResendOtpResponse(BuildContext context, ApiResponse apiResponse) {
    var message = apiResponse.message.toString();
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        CustomSnackBar.showSnackbar(context: context, message: message);
        // Restart the timer
        setState(() {
          otpEndTime = DateTime.now()
              .add(Duration(minutes: 1, seconds: 30)); // reset timer
          resendOtp = false;
        });
        return Container();
      case Status.ERROR:
        CustomSnackBar.showSnackbar(
            context: context, message: apiResponse.message);
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

  @override
  Widget build(BuildContext context) {
    mediaWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 20),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                          ),
                        )),
                    Container(
                      height: screenHeight * 0.15,
                      margin: EdgeInsets.zero,
                      child: _buildLabelText(
                          context,
                          "${Languages.of(context)?.labelOtpVerification}",
                          28,
                          true),
                      alignment: AlignmentDirectional.center,
                    ),
                    SizedBox()
                  ],
                ),
                Expanded(
                  child: Container(
                    width: mediaWidth,
                    height: screenHeight * 0.72,
                    margin: EdgeInsets.zero,
                    child: Card(
                      color: CustomAppColor.Background,
                      margin: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*_buildLabelText(context,
                              Languages.of(context)!.labelWelcome, 16, false),

                          SizedBox(height: 4),*/
                          SizedBox(height: 20),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Center(
                              child: _buildLabelText(
                                  context,
                                  Languages.of(context)!.labelEnterCode,
                                  14,
                                  true),
                            ),
                          ),
                          SizedBox(height: 4),
                          Center(
                            child: _buildLabelText(
                                context,
                                "${Languages.of(context)!.labelSentCode} ${widget.data}",
                                12,
                                false),
                          ),
                          SizedBox(height: 22),
                          _buildOtpInput(context, mediaWidth, isDarkMode),

                          SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 24),
                            child: Row(
                              children: [
                                !resendOtp
                                    ? _buildLabelText(
                                        context,
                                        "${Languages.of(context)!.labelResendCode} ",
                                    14,
                                        true)
                                    : SizedBox(),
                                _countdownTimer(),
                                Spacer(),
                                if (resendOtp) _resendOtpButton(context)
                              ],
                            ),
                          ),
                          Spacer(),
                          CustomNumberKeyboard(onKeyTap: (value) async {
                            if (value == "clear") {
                              _handleBackspace();
                            } else if (value == "submit") {
                              String otp = _inputValues
                                  .map((controller) => controller)
                                  .join();
                              if (otp.isNotEmpty && otp.length == 6) {
                                if (otp.isNotEmpty && otp.length == 6) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  bool isConnected =
                                      await _connectivityService.isConnected();
                                  if (!isConnected) {
                                    setState(() {
                                      isLoading = false;
                                      CustomSnackBar.showSnackbar(
                                          context: context,
                                          message:
                                              '${Languages.of(context)?.labelNoInternetConnection}');
                                    });
                                  } else {
                                    OtpVerifyRequest phoneRequest =
                                        OtpVerifyRequest(
                                            customer: CustomerOtpVerify(
                                      phoneNumber: "${widget.data}",
                                      mobileOtp: otp,
                                    ));
                                    await Provider.of<MainViewModel>(context,
                                            listen: false)
                                        .signUpOtpVerifyData(
                                            "/api/v1/app/temp_customers/verify_customer_signup",
                                            phoneRequest);

                                    ApiResponse apiResponse =
                                        Provider.of<MainViewModel>(context,
                                                listen: false)
                                            .response;
                                    getOtpResponseDataWidget(
                                        context, apiResponse);
                                  }
                                } else {
                                  CustomSnackBar.showSnackbar(
                                      context: context,
                                      message:
                                          '${Languages.of(context)?.labelPleaseEnterValidPhoneNo}');
                                }
                              }
                            } else {
                              _handleKeyTap(value);
                            }
                          }),
                          //_buildFooter(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          isLoading ? CustomCircularProgress() : SizedBox(),
        ],
      ),
    );
  }

  Widget _countdownTimer() {
    return resendOtp
        ? SizedBox()
        : Row(
            children: [
              Icon(
                Icons.timer,
                size: 18,
                color: Colors.black54,
              ),
              SizedBox(
                width: 3,
              ),
              TimerCountdown(
                endTime: otpEndTime,
                format: CountDownTimerFormat.minutesSeconds,
                enableDescriptions: false,
                spacerWidth: 1,
                timeTextStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black54),
                onEnd: () {
                  setState(() {
                    resendOtp = true;
                  });
                },
              ),
            ],
          );
  }
  Widget _buildOtpInput(
      BuildContext context, double mediaWidth, bool isDarkMode) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          6,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                  color: isDarkMode ? Colors.grey : Colors.black54, width: 0.4),
              borderRadius: BorderRadius.circular(6),
            ),
            width: mediaWidth / 8.1,
            height: 50.0,
            child: Center(
              child: Text(
                _inputValues[index],
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildLabelText(BuildContext context, String text, int size, bool isBold) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size.toDouble(),
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _resendOtpButton(BuildContext context) {
    return GestureDetector(
        onTap: () async {
          phoneNo = widget.data as String;

          SignUpRequest request = SignUpRequest(
              customer: CustomerSignUp(
            email: "",
            password: "",
            firstName: "",
            lastName: "",
            phoneNumber: phoneNo,
          ));

          await Provider.of<MainViewModel>(context, listen: false).signUpData(
              "api/v1/app/temp_customers/initiate_temp_customer", request);
          ApiResponse apiResponse =
              Provider.of<MainViewModel>(context, listen: false).response;
          getResendOtpResponse(context, apiResponse);
        },
        child: Text(
          "${Languages.of(context)?.labelResendOtp}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ));
  }
}
