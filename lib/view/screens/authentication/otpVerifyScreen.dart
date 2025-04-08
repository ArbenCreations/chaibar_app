import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:provider/provider.dart';

import '/model/request/otpVerifyRequest.dart';
import '/model/response/signUpVerifyResponse.dart';
import '../../../../language/Languages.dart';
import '../../../../theme/CustomAppColor.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../utils/apis/api_response.dart';
import '../../component/connectivity_service.dart';
import '../../component/customNumberKeyboard.dart';
import '../../component/toastMessage.dart';

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
  final ConnectivityService _connectivityService = ConnectivityService();

  @override
  void initState() {
    super.initState();
    isValid = false;
    resendOtp = false;
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
        //Helper.saveProfileDetails(data);

        //CustomToast.showToast(context: context, message: message);
        //String token = "${signUpVerifyResponse?.token}";
        // Save the token
        //bool isSaved = await Helper.saveUserToken(token);

        // Check if the token was saved successfully
        //Helper.getUserToken();
        // Retrieve the token
        //String? retrievedToken = await Helper.getUserToken();
        //print('Retrieved Token: $retrievedToken');

        CustomToast.showToast(
            context: context,
            message: "Signup completed. Please Login to continue.");

        Navigator.pushReplacementNamed(context, "/SignInScreen", arguments: "");
        return Container();
      case Status.ERROR:
        CustomToast.showToast(context: context, message: message);
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
        //Call Toast
        CustomToast.showToast(context: context, message: message);
        // Navigate to the new screen after receiving the response
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        CustomToast.showToast(context: context, message: apiResponse.message);
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
    ApiResponse apiResponse = Provider.of<MainViewModel>(context).response;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: mediaWidth,
                  height: screenHeight * 0.15,
                  margin: EdgeInsets.zero,
                  child: _buildLabelText(
                      context,
                      "${Languages.of(context)?.labelOtpVerification}",
                      28,
                      true),
                  alignment: AlignmentDirectional.center,
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
                                _buildLabelText(
                                    context,
                                    "${Languages.of(context)!.labelResendCode} ",
                                    14,
                                    true),
                                _countdownTimer(),
                                Spacer(),
                                // if (resendOtp) _resendOtpButton(context)
                              ],
                            ),
                          ),
                          Spacer(),
                          CustomNumberKeyboard(onKeyTap: (value) async {
                            if (value == "clear") {
                              _handleBackspace();
                            } else if (value == "submit") {
                              // Navigator.pushReplacementNamed(context, "/VendorsListScreen" ,arguments : "");
                              String otp = _inputValues
                                  .map((controller) => controller)
                                  .join();
                              print("$otp");
                              if (otp.isNotEmpty && otp.length == 6) {
                                const maxDuration = Duration(seconds: 2);
                                print("otp $otp");
                                if (otp.isNotEmpty && otp.length == 6) {
                                  setState(() {
                                    isLoading = true;
                                  });

                                  bool isConnected =
                                      await _connectivityService.isConnected();
                                  if (!isConnected) {
                                    setState(() {
                                      isLoading = false;
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              '${Languages.of(context)?.labelNoInternetConnection}'),
                                          duration: maxDuration,
                                        ),
                                      );
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          '${Languages.of(context)?.labelPleaseEnterValidPhoneNo}'),
                                      duration: maxDuration,
                                    ),
                                  );
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
          isLoading
              ? Stack(
                  children: [
                    // Block interaction
                    ModalBarrier(dismissible: false, color: Colors.transparent),
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

  Widget _countdownTimer() {
    return TimerCountdown(
      endTime: DateTime.now().add(const Duration(minutes: 1, seconds: 0)),
      format: CountDownTimerFormat.minutesSeconds,
      enableDescriptions: false,
      spacerWidth: 2,
      timeTextStyle: TextStyle(fontWeight: FontWeight.w600),
      onEnd: () {
        setState(() {
          resendOtp = true;
        });
      },
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
          // PhoneRequest phoneRequest = PhoneRequest(
          //     customer: Customer(
          //         phoneNumber: phoneNo, mobileOtp: "", countryId: null));
          /*  await Provider.of<MainViewModel>(context, listen: false)
              .PhoneVerifyData(
                  "/api/v1/app/temp_customers/initiate_customer", phoneRequest); */
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
/*void restartTimer() {
    countDownTimer.cancel();
    startTimer();
  }*/
}
