import 'package:ChaatBar/model/request/successCallbackRequest.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:provider/provider.dart';

import '../../../languageSection/Languages.dart';
import '../../../model/apis/api_response.dart';
import '../../../model/request/CardDetailRequest.dart';
import '../../../model/request/TransactionRequest.dart';
import '../../../model/response/rf_bite/PaymentDetailsResponse.dart';
import '../../../model/response/rf_bite/createOrderResponse.dart';
import '../../../model/response/rf_bite/successCallbackResponse.dart';
import '../../../model/response/rf_bite/tokenDetailsResponse.dart';
import '../../../theme/AppColor.dart';
import '../../../utils/Helper.dart';
import '../../../utils/Util.dart';
import '../../../view_model/main_view_model.dart';
import '../../component/connectivity_service.dart';
import '../../component/session_expired_dialog.dart';
import '../../component/toastMessage.dart';

class AddCardScreen extends StatefulWidget {
  final String? data;
  final CreateOrderResponse? orderData;

  AddCardScreen({Key? key, this.data, this.orderData}) : super(key: key);

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
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
  bool useFloatingAnimation = true;
  final OutlineInputBorder border = OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.grey.withOpacity(0.7),
      width: 2.0,
    ),
  );
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Color cardColor = AppColor.PRIMARY;

  late double screenWidth;
  late double screenHeight;
  String phoneCode = "";
  int countryCode = 0;
  bool isLoading = false;
  bool isValid = false;
  bool isDarkMode = false;
  bool isKeypadVisible = true;
  String responseMessage = '';
  String apiKey = "";
  bool phoneNumberValid = false;

  final _formKey = GlobalKey<FormState>();
  static const maxDuration = Duration(seconds: 2);

  final ConnectivityService _connectivityService = ConnectivityService();
  bool isInternetConnected = true;

  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Helper.getVendorDetails().then((data) {
      setState(() {
        apiKey = "${data?.apiKey}";
        print("apiKey:$apiKey");
      });
    });
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
          'Card Saved: ${_cardNumberController.text}, ${_cvvController.text}, ${_expiryDateController.text}, ${_nameController.text}');
      // Call your API to save card details
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
        return Center(
            child: CircularProgressIndicator(
          color: isDarkMode ? AppColor.WHITE : AppColor.PRIMARY,
        ));
      case Status.COMPLETED:
        print("rwrwr ");
        //Navigator.pushNamed(context, '/ProfileScreen');
        ToastComponent.showToast(
            context: context, message: apiResponse.message);

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
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () async {
            if (isKeyboardOpen(context)) {
              hideKeyBoard();
            } else {
              hideKeyBoard();
              await Future.delayed(Duration(milliseconds: 2));
              Navigator.of(context).pop();
              //Navigator.pushReplacementNamed(context, "/CardListScreen", arguments: "${Languages.of(context)?.labelAddedCard}");
            }
          },
        ),
        title: Text(
          Languages.of(context)!.labelAddedCard,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: AppColor.PRIMARY,
          statusBarIconBrightness: Brightness.light, // Change icon brightness
        ),
      ),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: AppColor.PRIMARY,
            statusBarIconBrightness: Brightness.light),
        child: Stack(
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
                            CreditCardForm(
                              formKey: formKey,
                              obscureCvv: true,
                              obscureNumber: true,
                              cardNumber: cardNumber,
                              cvvCode: cvvCode,
                              isHolderNameVisible: true,
                              isCardNumberVisible: true,
                              isExpiryDateVisible: true,
                              cardHolderName: cardHolderName,
                              expiryDate: expiryDate,
                              inputConfiguration: const InputConfiguration(
                                cardNumberDecoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8.0),
                                  labelText: 'Card Number',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 0.4)),
                                  hintText: 'XXXX XXXX XXXX XXXX',
                                ),
                                expiryDateDecoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8.0),
                                  labelText: 'Expiry Date (MM/YY)',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 0.4)),
                                  hintText: 'XX/XX',
                                ),
                                cvvCodeDecoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8.0),
                                  labelText: 'CVV',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 0.4)),
                                  hintText: 'XXX',
                                ),
                                cardHolderDecoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 8.0),
                                  labelText: 'Card Holder Name',
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(width: 0.4)),
                                ),
                              ),
                              onCreditCardModelChange: onCreditCardModelChange,
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _onValidate,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      AppColor.PRIMARY,
                                      AppColor.PRIMARY,
                                    ],
                                    begin: Alignment(-1, -4),
                                    end: Alignment(1, 4),
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Validate',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    package: 'flutter_credit_card',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                          dismissible: false,
                          color: Colors.black.withOpacity(0.3)),
                      // Loader indicator
                      Center(
                        child: CircularProgressIndicator(
                          color: isDarkMode ? AppColor.WHITE : AppColor.PRIMARY,
                        ),
                      ),
                    ],
                  )
                : SizedBox(),
          ],
        ),
      ),
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
    //Navigator.pushNamed(context, "/VendorScreen");
    const maxDuration = Duration(seconds: 2);
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
      if (expiryDate.isNotEmpty) {
        List<String> parts = expiryDate.split('/');
        expiryMonth = parts[0];
        expiryYear = parts[1];

        print("Month: $expiryMonth");
        print("Year: $expiryYear");
      } else {
        print("Invalid expiry date format.");
      }
      CardDetailsRequest cardDetails = CardDetailsRequest(
        number: cardNumber.replaceAll(" ", ""),
        expMonth: expiryMonth,
        expYear: "20$expiryYear",
        cvv: cvvCode,
        brand: "DISCOVER",
      );

      CardRequest cardRequest = CardRequest(card: cardDetails);

      await Provider.of<MainViewModel>(context, listen: false).getApiToken(
          "https://token-sandbox.dev.clover.com/v1/tokens",
          apiKey.toString(),
          cardRequest);
      //await Provider.of<MainViewModel>(context, listen: false).getApiToken("https://token.clover.com/v1/tokens", apiKey.toString(), cardRequest);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getApiTokenResponse(context, apiResponse);
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
        print("getApiTokenResponse : ${widget.data}");
        // Check if the token was saved successfully
        if (tokenDetailsResponse?.id?.isNotEmpty == true) {
          _getFinalPaymentApi(tokenDetailsResponse?.id.toString());
          print('Token saved successfully.');
        } else {
          print('Failed to save token.');
        }
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

  Future<void> _getFinalPaymentApi(String? source) async {
    hideKeyBoard();
    // _isValidInput();
    //Navigator.pushNamed(context, "/VendorScreen");
    const maxDuration = Duration(seconds: 2);
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
      TransactionRequest transactionRequest = TransactionRequest(
          //amount: convertToCents("${widget.orderData?.order?.payableAmount}"),
          amount: 5,
          currency: "usd",
          source: "$source");
      await Provider.of<MainViewModel>(context, listen: false)
          .getFinalPaymentApi("https://scl-sandbox.dev.clover.com/v1/charges", "f2240939-d0fa-ccfd-88ff-2f14e160dc6a",
              transactionRequest);
      // await Provider.of<MainViewModel>(context, listen: false).getFinalPaymentApi("https://scl.clover.com/v1/charges", "$apiKey", transactionRequest);
      //.getFinalPaymentApi("https://scl.clover.com/v1/charges",
      //   "3238f7d7-bbc4-9b71-314e-1b2e1bd76a9d", transactionRequest);
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
        print("getFinalPaymentApiResponse : ${widget.data}");

        // Check if the token was saved successfully
        if (paymentDetails?.id.isNotEmpty == true) {
          print('Token saved successfully.');
          _hitSuccessCallBack(paymentDetails?.id, "${paymentDetails?.status}");
          //Navigator.pushNamed(context, "/OrderSuccessfulScreen");
        } else {
          print('Failed to save token.');
        }
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

  Future<void> _hitSuccessCallBack(
      String? paymentId, String transactionStatus) async {
    hideKeyBoard();
    const maxDuration = Duration(seconds: 2);
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
      SuccessCallbackRequest request = SuccessCallbackRequest(
          orderId: int.parse("${widget.orderData?.order?.id}"),
          transactionId: "$paymentId",
          transactionStatus: "$transactionStatus",
          isPaymentSuccessTrue: true);
      await Provider.of<MainViewModel>(context, listen: false)
          .successCallback("/api/v1/app/customers/success_callback", request);
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
        print("getFinalPaymentApiResponse : ${widget.data}");

        print('Token saved successfully.');
        Navigator.pushNamed(context, "/OrderSuccessfulScreen",
            arguments: successCallbackResponse);
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

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
      cardColor = getCardColor(cardNumber);
    });
  }

  // Detect the card type based on the card number and assign a color
  Color getCardColor(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return Colors.blue; // Visa
    } else if (cardNumber.startsWith('5')) {
      return Colors.red; // MasterCard
    } else if (cardNumber.startsWith('3')) {
      return Colors.green; // American Express
    } else if (cardNumber.startsWith('6')) {
      return Colors.purple; // Discover
    } else {
      return AppColor.PRIMARY; // Default color
    }
  }

  double convertToCents(String amt) {
    return (double.parse("$amt") * 100);
  }
}
