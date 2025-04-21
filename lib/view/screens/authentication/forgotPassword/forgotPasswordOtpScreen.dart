import 'package:flutter/services.dart';

import '../../../component/custom_circular_progress.dart';
import '/model/request/verifyOtpChangePass.dart';
import 'package:flutter/material.dart';

import '../../../../../language/Languages.dart';
import '../../../component/customNumberKeyboard.dart';

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
  List<String> _inputValues = ['', '', '', '', '', ''];

  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

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
        body: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  Center(
                    child: Image(
                      alignment: Alignment.topLeft,
                      height: screenHeight * 0.25,
                      image: AssetImage("assets/forgot_pass_img.png"),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8),
                      child: Text("Enter the 6-digit otp sent to your email address.",style: TextStyle(fontSize: 12),),
                    ),
                  ),
                  _buildOtpInput(context, mediaWidth, isDarkMode),
                  Spacer(),
                  CustomNumberKeyboard(onKeyTap: (value) async {
                    if (value == "clear") {
                      _handleBackspace();
                    } else if (value == "submit") {
                      String otp = _inputValues
                          .map((controller) => controller)
                          .join();
                      print("${widget.data}");
                      VerifyOtChangePassRequest data =
                      VerifyOtChangePassRequest(email: "${widget.data}", mobileOtp: otp , );
                      if (otp.isNotEmpty && otp.length == 6) {
                        Navigator.pushNamed(
                            context, "/NewPassForgotPassScreen",
                            arguments: data);
                      }
                    } else {
                      _handleKeyTap(value);
                    }
                  })
                  //if (isLoading) CircularProgressIndicator(),
                ],
              ),
            ),
            isLoading
                ? CustomCircularProgress()
                : SizedBox(),
          ],
        ),
      ),
      isLoading
          ? CustomCircularProgress()
          : SizedBox(),
    ]);
  }

  Widget _buildOtpInput(
      BuildContext context, double mediaWidth, bool isDarkMode) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          6,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                isKeypadVisible = true;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                    width: 0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              width: mediaWidth / 7.68,
              height: 68.0,
              child: Center(
                child: Text(
                  _inputValues[index],
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
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
}
