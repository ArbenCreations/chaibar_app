import 'dart:convert';
import 'dart:io';

import 'package:apple_pay_flutter/apple_pay_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:provider/provider.dart';

import '../../../model/db/db_service.dart';
import '/model/request/successCallbackRequest.dart';
import '../../../language/Languages.dart';
import '../../../model/db/dataBaseDao.dart';
import '../../../model/request/CardDetailRequest.dart';
import '../../../model/request/EncryptedWalletRequest.dart';
import '../../../model/request/TransactionRequest.dart';
import '../../../model/request/addRewardPointsRequest.dart';
import '../../../model/request/getRewardPointsRequest.dart';
import '../../../model/response/PaymentDetailsResponse.dart';
import '../../../model/response/addRewardPointsResponse.dart';
import '../../../model/response/appleTokenDetailsResponse.dart';
import '../../../model/response/createOrderResponse.dart';
import '../../../model/response/getRewardPointsResponse.dart';
import '../../../model/response/successCallbackResponse.dart';
import '../../../model/response/tokenDetailsResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../theme/CustomAppColor.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/ApplePayButton.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';

class PaymentCardScreen extends StatefulWidget {
  final String? data;
  final String? rewardPoints;
  final CreateOrderResponse? orderData;

  PaymentCardScreen({Key? key, this.data, this.rewardPoints, this.orderData})
      : super(key: key);

  @override
  _PaymentCardScreenState createState() => _PaymentCardScreenState();
}

class _PaymentCardScreenState extends State<PaymentCardScreen> {
  bool isLightTheme = false;
  String cardNumber = '';
  String expiryDate = '';
  String expiryMonth = '';
  String expiryYear = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  bool useGlassMorphism = false;
  bool useBackgroundImage = false;
  bool useFloatingAnimation = false;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Color cardColor = Colors.black;

  late double mediaWidth;
  late double screenHeight;
  String phoneCode = "";
  int countryCode = 0;
  bool isLoading = false;
  bool isValid = false;
  bool isDarkMode = false;
  bool isKeypadVisible = true;
  String responseMessage = '';
  String apiKey = "";
  String appId = "";
  String merchantId = "";
  bool phoneNumberValid = false;
  int? customerId = 0;
  late CartDataDao cartDataDao;
  final _formKey = GlobalKey<FormState>();

  var _connectivityService = ConnectivityService();
  bool isInternetConnected = true;

  final TextEditingController cardHolderNameController =
      TextEditingController();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDatabase();
    Helper.getApiKey().then((data) {
      setState(() {
        apiKey = "${data ?? ""}";
      });
    });
    Helper.getAppId().then((data) {
      setState(() {
        appId = "${data ?? ""}";
      });
    });
    Helper.getMerchantId().then((data) {
      setState(() {
        merchantId = "${data ?? ""}";
      });
    });

    Helper.getProfileDetails().then((onValue) {
      setState(() {
        customerId = int.parse("${onValue?.id ?? 0}");
      });
    });
  }

  Future<void> initializeDatabase() async {
    cartDataDao =  DBService.instance.cartDao;
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter card number';
    }
    if (value.length != 16) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter CVV';
    }
    if (value.length != 3) {
      return 'CVV must be 3 digits';
    }
    return null;
  }

  String? validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter expiry date';
    }
    RegExp regExp = RegExp(r'^(0[1-9]|1[0-2])\/?([0-9]{2})$');
    if (!regExp.hasMatch(value)) {
      return 'Enter expiry date in MM/YY format';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter cardholder name';
    }
    return null;
  }

  void saveCard() {
    if (_formKey.currentState!.validate()) {
      // Save card details logic
      print(
          'Card Saved: ${cardNumberController.text}, ${cvvCodeController.text}, ${expiryDateController.text}, ${cardHolderNameController.text}');
      // Call your API to save card details
    }
  }

  Future<Widget> verifyOtpResponse(
      BuildContext context, ApiResponse apiResponse) async {
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(
            child: CircularProgressIndicator(
          color: isDarkMode ? Colors.white : CustomAppColor.Primary,
        ));
      case Status.COMPLETED:
        CustomSnackBar.showSnackbar(
            context: context, message: apiResponse.message);
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        } else {
          CustomSnackBar.showSnackbar(
              context: context, message: apiResponse.message);
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
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        systemOverlayStyle:
            SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        )),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => _onBackPressed(context),
        ),
        title: Text("Card Details",
            style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CreditCardWidget(
                    enableFloatingCard: useFloatingAnimation,
                    glassmorphismConfig: _getGlassmorphismConfig(),
                    cardNumber: cardNumber,
                    expiryDate: expiryDate,
                    cardHolderName: cardHolderName,
                    cvvCode: cvvCode,
                    bankName: ' ',
                    frontCardBorder: useGlassMorphism
                        ? null
                        : Border.all(color: Colors.grey),
                    backCardBorder: useGlassMorphism
                        ? null
                        : Border.all(color: Colors.grey),
                    showBackView: isCvvFocused,
                    obscureCardNumber: true,
                    obscureCardCvv: true,
                    isHolderNameVisible: true,
                    cardBgColor: cardColor,
                    backgroundImage:
                        useBackgroundImage ? 'assets/card_bg.png' : null,
                    isSwipeGestureEnabled: true,
                    onCreditCardWidgetChange:
                        (CreditCardBrand creditCardBrand) {},
                    customCardTypeIcons: <CustomCardTypeIcon>[],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          CreditCardForm(
                            formKey: formKey,
                            obscureCvv: true,
                            obscureNumber: true,
                            isHolderNameVisible: true,
                            isCardNumberVisible: true,
                            isExpiryDateVisible: true,
                            cardHolderName: cardHolderName,
                            expiryDate: expiryDate,
                            inputConfiguration: _getInputConfiguration(),
                            onCreditCardModelChange: (creditCardModel) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                setState(() {
                                  cardHolderName =
                                      creditCardModel.cardHolderName ?? '';
                                  cardNumber = creditCardModel.cardNumber ?? '';
                                  expiryDate = creditCardModel.expiryDate ?? '';
                                  cvvCode = creditCardModel.cvvCode ?? '';
                                  isCvvFocused = creditCardModel.isCvvFocused;
                                });
                              });
                            },
                            cardNumber: cardNumber,
                            cvvCode: cvvCode,
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              _onValidate();
                            }, //_onValidate,
                            child: _buildValidateButton(mediaWidth),
                          ),
                          Platform.isIOS
                              ? ApplePayButton(
                                  onPressed: () {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    makePayment(); // your payment logic
                                  },
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isLoading) _buildLoadingIndicator(),
        ],
      ),
    );
  }

  Future<void> makePayment() async {
    dynamic applePaymentData;
    List<PaymentItem> paymentItems = [
      PaymentItem(
        label: 'Label',
        amount: double.parse("${widget.orderData?.order?.totalAmount ?? 0}"),
        shippingcharge: 0.0,
      ),
    ];

    setState(() {
      isLoading = true;
    });

    try {
      applePaymentData = await ApplePayFlutter.makePayment(
        countryCode: "CA",
        currencyCode: "CAD",
        paymentNetworks: [
          PaymentNetwork.visa,
          PaymentNetwork.mastercard,
          PaymentNetwork.amex,
        ],
        merchantIdentifier: "$merchantId",
        paymentItems: paymentItems,
        customerEmail: "${widget.orderData?.order?.customerEmail ?? ''}",
        customerName: "${widget.orderData?.order?.customerName ?? ''}",
        companyName: "TheChaiBar",
      );

      var parsedData = jsonDecode(applePaymentData["paymentData"]);
      EncryptedWallet encryptedWallet = EncryptedWallet(
        applePayPaymentData: ApplePayPaymentData.fromJson(parsedData),
        addressLine1: "", // optional
        addressZip: "", // optional
      );

      ApplePayPaymentData applePayPaymentData =
          encryptedWallet.applePayPaymentData;

      if (applePayPaymentData.version.isNotEmpty &&
          applePayPaymentData.data.isNotEmpty &&
          applePayPaymentData.signature.isNotEmpty) {
        var requestJson = encryptedWallet.toJson();
        print("Request JSON: $requestJson");

        // Now send it
        await _getApiTokenForApplePay(widget.data, encryptedWallet);
      } else {
        print("Incomplete Apple Pay payment data.");
        _showPaymentError();
      }
    } on PlatformException catch (e) {
      print('Failed payment: ${e.message}');
      _showPaymentError();
    } catch (e) {
      print('Unexpected error: $e');
      _showPaymentError();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Helper to show error snack
  void _showPaymentError() {
    CustomSnackBar.showSnackbar(
      context: context,
      message: "Something went wrong. Please try again or use a card payment.",
    );
  }

  void _onBackPressed(BuildContext context) async {
    if (isKeyboardOpen(context)) {
      hideKeyBoard();
    } else {
      bool shouldPop = await _showExitConfirmation(context);
      if (shouldPop) {
        hideKeyBoard();
        await Future.delayed(Duration(milliseconds: 200));
        Navigator.of(context).pop();
      }
    }
  }

  Glassmorphism? _getGlassmorphismConfig() {
    if (!useGlassMorphism) {
      return null;
    }

    final LinearGradient gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[Colors.grey.withAlpha(50), Colors.grey.withAlpha(50)],
      stops: const <double>[0.3, 0],
    );

    return isLightTheme
        ? Glassmorphism(blurX: 8.0, blurY: 16.0, gradient: gradient)
        : Glassmorphism.defaultConfig();
  }

  InputConfiguration _getInputConfiguration() {
    return InputConfiguration(
      cardNumberDecoration:
          _buildInputDecoration('Card Number', 'XXXX XXXX XXXX XXXX'),
      expiryDateDecoration:
          _buildInputDecoration('Expiry Date (MM/YY)', 'XX/XX'),
      cvvCodeDecoration: _buildInputDecoration('CVV', 'XXX'),
      cardHolderDecoration:
          _buildInputDecoration('Card Holder Name', 'e.g. John Doe'),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: Border(),
            title: Text("Exit"),
            content: Text("Are you sure you want to leave?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Yes")),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildLoadingIndicator() {
    return Stack(
      children: [
        ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.3)),
        Center(
            child: CircularProgressIndicator(
                color: isDarkMode ? Colors.white : Colors.deepOrange)),
      ],
    );
  }

  Widget _buildValidateButton(double mediaWidth) {
    return Container(
      width: mediaWidth * 0.7,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomAppColor.PrimaryAccent, Colors.deepOrange],
          begin: Alignment(-1, -4),
          end: Alignment(1, 4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      child: Text(
        'Proceed to pay',
        style: TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint) {
    return InputDecoration(
      focusedBorder: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8.0),
      labelText: label,
      labelStyle: TextStyle(fontSize: 14, color: Colors.grey),
      errorStyle: TextStyle(fontSize: 10, color: Colors.red),
      enabledBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.2)),
      errorBorder: OutlineInputBorder(borderSide: BorderSide(width: 0.2)),
      focusedErrorBorder:
          OutlineInputBorder(borderSide: BorderSide(width: 0.2)),
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
    );
  }

  void _onValidate() {
    if (formKey.currentState?.validate() ?? false) {
      print('valid!');
      _getApiToken(widget.data);
    } else {
      print('invalid!');
    }
  }

  Future<void> _getApiToken(String? apiKey) async {
    hideKeyBoard();
    setState(() {
      isLoading = true;
    });
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      if (expiryDate.isNotEmpty) {
        List<String> parts = expiryDate.split('/');
        expiryMonth = parts[0];
        expiryYear = parts[1];

        print("Month: $expiryMonth");
        print("Year: $expiryYear");
        print("Year: ${apiKey.toString()}");
      } else {
        print("Invalid expiry date format.");
      }
      CardDetailsRequest cardDetails = CardDetailsRequest(
        number: cardNumber.replaceAll(" ", ""),
        expMonth: expiryMonth,
        expYear: "20$expiryYear",
        cvv: cvvCode,
        //brand: cardHolderName,
      );

      CardRequest cardRequest = CardRequest(card: cardDetails);
      //await Provider.of<MainViewModel>(context, listen: false).getApiToken("https://token-sandbox.dev.clover.com/v1/tokens", apiKey.toString(), cardRequest);
      await Provider.of<MainViewModel>(context, listen: false).getApiToken(
          "https://token.clover.com/v1/tokens", "$appId", cardRequest);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getApiTokenResponse(context, apiResponse);
    }
  }

  Future<void> _getApiTokenForApplePay(
      String? apiKey, EncryptedWallet applePayTokenRequest) async
  {
    hideKeyBoard();
    setState(() {
      isLoading = true;
    });
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
          .getApiTokenForApplePay("https://token.clover.com/v1/tokens",
              "$appId", applePayTokenRequest);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getApiAppleTokenResponse(context, apiResponse);
    }
  }

  Future<Widget> getApiAppleTokenResponse(
      BuildContext context, ApiResponse apiResponse) async
  {
    AppleTokenDetailsResponse? tokenDetailsResponse =
        apiResponse.data as AppleTokenDetailsResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        if (tokenDetailsResponse?.id?.isNotEmpty == true) {
          _getFinalPaymentApi(tokenDetailsResponse?.id.toString());
        }
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("message : ${apiResponse.message}");
        CustomSnackBar.showSnackbar(
            context: context, message: apiResponse.message);
        return Center();
      case Status.INITIAL:
      default:
        return Center();
    }
  }

  Future<Widget> getApiTokenResponse(
      BuildContext context, ApiResponse apiResponse) async {
    TokenDetailsResponse? tokenDetailsResponse =
        apiResponse.data as TokenDetailsResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        if (tokenDetailsResponse?.id?.isNotEmpty == true) {
          _getFinalPaymentApi(tokenDetailsResponse?.id.toString());
        }
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("message : ${apiResponse.message}");
        CustomSnackBar.showSnackbar(
            context: context, message: apiResponse.message);
        return Center();
      case Status.INITIAL:
      default:
        return Center();
    }
  }

  Future<void> _getFinalPaymentApi(String? source) async {
    hideKeyBoard();
    setState(() {
      isLoading = true;
    });
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      TransactionRequest transactionRequest = TransactionRequest(
          amount: convertToCents("${widget.orderData?.order?.totalAmount}"),
          currency: "cad",
          source: "$source",
          description: "Payment by ${cardHolderName}");
      await Provider.of<MainViewModel>(context, listen: false)
          //.getFinalPaymentApi("https://scl-sandbox.dev.clover.com/v1/charges", "", transactionRequest);
          .getFinalPaymentApi("https://scl.clover.com/v1/charges", "$apiKey",
              transactionRequest);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getFinalPaymentApiResponse(context, apiResponse);
    }
  }

  Future<Widget> getFinalPaymentApiResponse(
      BuildContext context, ApiResponse apiResponse) async {
    PaymentDetails? paymentDetails = apiResponse.data as PaymentDetails?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        if (paymentDetails?.id.isNotEmpty == true) {
          _hitSuccessCallBack(paymentDetails?.id, "${paymentDetails?.status}");
        }
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("message : ${apiResponse.message}");
        CustomSnackBar.showSnackbar(
            context: context, message: apiResponse.message);
        return Center();
      case Status.INITIAL:
      default:
        return Center();
    }
  }

  Future<void> _hitSuccessCallBack(
      String? paymentId, String transactionStatus) async {
    hideKeyBoard();
    setState(() {
      isLoading = true;
    });
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      SuccessCallbackRequest request = SuccessCallbackRequest(
          orderId: int.parse("${widget.orderData?.order?.id}"),
          transactionId: "$paymentId",
          customerId: "$customerId",
          transactionStatus: "succeeded",
          isPaymentSuccessTrue: true);
      await Provider.of<MainViewModel>(context, listen: false)
          .successCallback("api/v1/app/customers/success_callback", request);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getSuccessCallBackResponse(context, apiResponse);
    }
  }

  Future<Widget> getSuccessCallBackResponse(
      BuildContext context, ApiResponse apiResponse) async {
    SuccessCallbackResponse? successCallbackResponse =
        apiResponse.data as SuccessCallbackResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        print("getFinalPaymentApiResponse : ${widget.rewardPoints}");
        cartDataDao.clearAllCartProduct();
        if ("${widget.rewardPoints}" == "null" ||
            "${widget.rewardPoints}" == "0" ||
            "${widget.rewardPoints}" == "0.0") {
          _addRedeemPointsData("${successCallbackResponse?.order?.totalPrice}",
              successCallbackResponse);
        } else {
          _fetchRedeemPointsData(successCallbackResponse);
        }
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        print("message : ${apiResponse.message}");
        CustomSnackBar.showSnackbar(
            context: context, message: apiResponse.message);
        return Center();
      case Status.INITIAL:
      default:
        return Center();
    }
  }

  void _fetchRedeemPointsData(
      SuccessCallbackResponse? successCallbackResponse) async {
    setState(() {
      isLoading = true;
    });
    hideKeyBoard();
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages.of(context)?.labelNoInternetConnection}');
      });
    } else {
      GetRewardPointsRequest request = GetRewardPointsRequest(
          pointsToRedeem: double.parse("${widget.rewardPoints}"),
          orderId: int.parse("${widget.orderData?.order?.id}"));

      await Provider.of<MainViewModel>(context, listen: false)
          .fetchRewardPointsDetails(
              "api/v1/app/rewards/redeem_points", request);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getRedeemPointsDetails(context, apiResponse, successCallbackResponse);
    }
  }

  Widget getRedeemPointsDetails(BuildContext context, ApiResponse apiResponse,
      SuccessCallbackResponse? successCallbackResponse) {
    var message = apiResponse.message.toString();
    GetRewardPointsResponse? response =
        apiResponse.data as GetRewardPointsResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        _addRedeemPointsData("${successCallbackResponse?.order?.totalPrice}",
            successCallbackResponse);

        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        CustomSnackBar.showSnackbar(context: context, message: '$message');
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

  void _addRedeemPointsData(String orderAmount,
      SuccessCallbackResponse? successCallbackResponse) async {
    setState(() {
      isLoading = true;
    });
    hideKeyBoard();
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
      });
      CustomSnackBar.showSnackbar(
          context: context,
          message: '${Languages.of(context)?.labelNoInternetConnection}');
    } else {
      AddRewardPointsRequest request = AddRewardPointsRequest(
          amountSpent: double.parse("${widget.orderData?.order?.totalAmount}"),
          orderId: int.parse("${widget.orderData?.order?.id}"),
          couponId: int.parse("${widget.orderData?.order?.couponId}"),
          couponCode: "${widget.orderData?.order?.couponCode}");

      await Provider.of<MainViewModel>(context, listen: false)
          .addRewardPointsDetails("api/v1/app/rewards/add_points", request);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      addRedeemPointsDetails(context, apiResponse, successCallbackResponse);
    }
  }

  Widget addRedeemPointsDetails(BuildContext context, ApiResponse apiResponse,
      SuccessCallbackResponse? successCallbackResponse) {
    var message = apiResponse.message.toString();
    AddRewardPointsResponse? response =
        apiResponse.data as AddRewardPointsResponse?;
    ;
    setState(() {
      isLoading = false;
    });

    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        Navigator.pushNamed(
          context,
          "/OrderSuccessfulScreen",
          arguments: {
            "data": successCallbackResponse,
            'orderData': widget.orderData,
            'pointsEarned': "${response?.pointsEarned}"
          },
        );
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        CustomSnackBar.showSnackbar(context: context, message: '$message');
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

  double convertToCents(String amt) {
    return (double.parse("$amt") * 100);
  }
}
