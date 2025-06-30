import 'package:ChaiBar/theme/CustomAppColor.dart';
import 'package:ChaiBar/utils/Util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/model/request/verifyOtpChangePass.dart';
import '../../../../../language/Languages.dart';
import '../../../component/CustomSnackbar.dart';
import '../../../component/custom_circular_progress.dart';

class OtpForgotPassScreen extends StatefulWidget {
  final String? data;

  OtpForgotPassScreen({Key? key, this.data}) : super(key: key);

  @override
  _OtpForgotPassScreenState createState() => _OtpForgotPassScreenState();
}

class _OtpForgotPassScreenState extends State<OtpForgotPassScreen> {
  late double mediaWidth;
  late double screenHeight;
  bool isLoading = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;
  bool isValid = false;
  bool isKeypadVisible = true;
  String responseMessage = '';
  String otp = '';
  bool phoneNumberValid = false;
  bool isDarkMode = false;

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  List<String> _inputValues = List.generate(6, (_) => '');

  @override
  void initState() {
    super.initState();
    isValid = false;
    phoneNumberValid = false;
    newPasswordVisible = true;
    confirmPasswordVisible = true;
    _focusNodes[0].requestFocus();
    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _otpControllers[i].text.isEmpty) {
          // Automatically select all text when the field gains focus
          _otpControllers[i].selection = TextSelection(
              baseOffset: 0, extentOffset: _otpControllers[i].text.length);
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Stack(children: [
      Scaffold(
        appBar: AppBar(
          toolbarHeight: 65,
          systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.light
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              )
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            Languages.of(context)!.labelForgotPass,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        body: GestureDetector(
          onTap: () => {hideKeyBoard()},
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Center(
                      child: Image(
                        alignment: Alignment.topLeft,
                        height: screenHeight * 0.25,
                        image: AssetImage("assets/forgot_pass_img.png"),
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8),
                        child: Text(
                          "Enter the 6-digit otp sent to your email address.",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    _buildOtpInput(context, mediaWidth, isDarkMode),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: MaterialButton(
                    onPressed: () => _submitOtp("${widget.data}"),
                    color: CustomAppColor.Primary,
                    minWidth: mediaWidth * 0.6,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Submit",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                isLoading ? CustomCircularProgress() : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _buildOtpInput(
      BuildContext context, double mediaWidth, bool isDarkMode)
  {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          6,
          (index) => Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            width: mediaWidth / 7.68,
            height: 68.0,
            child: TextField(
              focusNode: _focusNodes[index],
              controller: _otpControllers[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              textInputAction:
                  index == 5 ? TextInputAction.done : TextInputAction.next,
              style: TextStyle(fontSize: 20),
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                    width: 0.4,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.length == 1) {
                  if (index < 5) {
                    FocusScope.of(context).nextFocus();
                  } else {
                    FocusScope.of(context).unfocus(); // Hide keyboard
                  }
                } else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).previousFocus();
                }
                _inputValues[index] = value;
              },
            ),
          ),
        ),
      ),
    );
  }

  void isInputValid() {
    String otp = _otpControllers.map((controller) => controller.text).join();
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

  void _submitOtp(String email) {
    String otp = _inputValues.join();

    VerifyOtChangePassRequest data = VerifyOtChangePassRequest(
      email: "${email ?? ""}",
      mobileOtp: otp,
    );

    if (otp.isNotEmpty && otp.length == 6) {
      hideKeyBoard();
      Navigator.pushNamed(
        context,
        "/NewPassForgotPassScreen",
        arguments: data,
      );
    } else {
      CustomSnackBar.showSnackbar(
          context: context, message: "Please enter all 6 digits");
    }
  }
}
