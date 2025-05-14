import 'package:ChaiBar/view/component/CustomAlert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '/model/request/verifyOtpChangePass.dart';
import '/model/response/signUpInitializeResponse.dart';
import '/theme/CustomAppColor.dart';
import '/utils/Util.dart';
import '/view/screens/authentication/loginScreen.dart';
import '../../../../language/Languages.dart';
import '../../../../utils/Helper.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/connectivity_service.dart';
import '../../component/custom_circular_progress.dart';
import '../../component/session_expired_dialog.dart';

class NewPassForgotPassScreen extends StatefulWidget {
  final VerifyOtChangePassRequest? data;

  NewPassForgotPassScreen({Key? key, this.data}) : super(key: key);

  @override
  _NewPassForgotPassScreenState createState() =>
      _NewPassForgotPassScreenState();
}

class _NewPassForgotPassScreenState extends State<NewPassForgotPassScreen> {
  late double mediaWidth;
  late double screenHeight;
  bool isLoading = false;
  bool newPasswordVisible = false;
  bool confirmPasswordVisible = false;
  bool isValid = false;
  bool isKeypadVisible = true;
  String responseMessage = '';
  bool phoneNumberValid = false;
  bool isDarkMode = false;

  final TextEditingController _phoneNumberController = TextEditingController();
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
    print("${widget.data?.email}");
    isValid = false;
    phoneNumberValid = false;
    newPasswordVisible = true;
    confirmPasswordVisible = true;
    for (var i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus && _controllers[i].text.isEmpty) {
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

  Future<Widget> verifyOtpResponse(
      BuildContext context, ApiResponse apiResponse) async {
    SignUpInitializeResponse? mediaList =
        apiResponse.data as SignUpInitializeResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        CustomSnackBar.showSnackbar(
            context: context, message: mediaList?.message ?? "Successful!!");
        Helper.clearAllSharedPreferences();
        Future.delayed(Duration(milliseconds: 150), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => SigninScreen()),
            (Route<dynamic> route) => false,
          );
        });
        return Container();
      case Status.ERROR:
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        } else if (apiResponse.message?.contains("401") == true) {
          CustomSnackBar.showSnackbar(
              context: context, message: "Invalid OTP, please try again !");
        } else {
          CustomAlert.showToast(context: context, message: apiResponse.message);
        }
        return Center();
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

    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            hideKeyBoard();
            Future.delayed(Duration(milliseconds: 150), () {
              Navigator.pop(context);
            });
          },
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        )),
        title: Text(
          Languages.of(context)!.labelForgotPass,
          style: TextStyle(
              fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  Center(
                    child: Image(
                      alignment: Alignment.topLeft,
                      height: screenHeight * 0.27,
                      image: AssetImage("assets/forgot_password.png"),
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(height: 10),

                  // Descriptive text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Please enter your new password below to reset your current password. Make sure it's strong and secure.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  _buildPasswordTextFields(isDarkMode),
                  SizedBox(height: 15),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
          isLoading ? CustomCircularProgress() : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildPasswordTextFields(bool isDarkMode) {
    return Column(
      children: [
        _buildPasswordInput(
            context,
            Languages.of(context)!.labelNewPass,
            _newPasswordController,
            Icon(
              Icons.password,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            newPasswordVisible,
            isDarkMode),
        _buildPasswordInput(
            context,
            Languages.of(context)!.labelConfirmPass,
            _confirmPasswordController,
            Icon(
              Icons.password,
              size: 18,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            confirmPasswordVisible,
            isDarkMode)
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 4),
      child: Card(
        child: Container(
          //height: 60,
          width: mediaWidth * 0.92,
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
          decoration: BoxDecoration(
            //color: Theme.of(context).colorScheme.secondary.withAlpha(50),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            children: [
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  style: TextStyle(fontSize: 15.0),
                  obscureText: passwordVisibles,
                  obscuringCharacter: "*",
                  controller: nameController,
                  textAlignVertical: TextAlignVertical.center,
                  onChanged: (value) {
                    setState(() {
                      nameController.text = value;
                    });
                    isInputValid();
                  },
                  onSubmitted: (value) {},
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: text,
                    icon: icon,
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisibles
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: isDarkMode ? Colors.white : Colors.black,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(
                          () {
                            if (nonCapitalizeString(text) ==
                                nonCapitalizeString(
                                    "${Languages.of(context)!.labelNewPass}")) {
                              newPasswordVisible = !newPasswordVisible;
                            } else {
                              confirmPasswordVisible = !confirmPasswordVisible;
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
        ),
      ),
    );
  }

  void isInputValid() {
    if (_newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text &&
        _newPasswordController.text.length >= 8) {
      isValid = true;
    } else {
      isValid = false;
    }
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SizedBox(
        width: mediaWidth * 0.7,
        child: ElevatedButton(
          onPressed: () async {
            hideKeyBoard();
            String otp = "${widget.data}";
            isInputValid();
            if (otp.isNotEmpty &&
                _newPasswordController.text.isNotEmpty &&
                _confirmPasswordController.text.isNotEmpty &&
                _newPasswordController.text ==
                    _confirmPasswordController.text &&
                _newPasswordController.text.length >= 8) {
              setState(() {
                isLoading = true;
              });

              bool isConnected = await _connectivityService.isConnected();
              if (!isConnected) {
                setState(() {
                  isLoading = false;
                  CustomSnackBar.showSnackbar(
                      context: context,
                      message:
                          '${Languages.of(context)?.labelNoInternetConnection}');
                });
              } else {
                print(_phoneNumberController.text);
                setState(() {
                  isLoading = true;
                });
                print("${widget.data?.email}");
                VerifyOtChangePassRequest request = VerifyOtChangePassRequest(
                    email: "${widget.data?.email}",
                    password: _newPasswordController.text,
                    mobileOtp: "${widget.data?.mobileOtp}");

                await Provider.of<MainViewModel>(context, listen: false)
                    .VerifyOtpChangePass(
                        "/api/v1/app/customers/verify_otp_change_pass",
                        request);
                ApiResponse apiResponse =
                    Provider.of<MainViewModel>(context, listen: false).response;
                verifyOtpResponse(context, apiResponse);
              }
            } else if (_newPasswordController.text.length < 8) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${Languages.of(context)?.labelPasswordAlert}'),
                  duration: maxDuration,
                ),
              );
            } else if (_newPasswordController.text !=
                _confirmPasswordController.text) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "${Languages.of(context)?.labelPasswordDoesntMatch}"),
                  duration: maxDuration,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "${Languages.of(context)?.labelPleaseEnterAllDetails}"),
                  duration: maxDuration,
                ),
              );
            }
          },
          child: Text(
            Languages.of(context)!.labelValidate,
            style: TextStyle(
                color: isValid ? Colors.white : CustomAppColor.Primary),
          ),
          style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              backgroundColor: isValid ? CustomAppColor.Primary : Colors.white,
              elevation: 3,
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(2))),
        ),
      ),
    );
  }
}
