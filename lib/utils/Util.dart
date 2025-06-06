import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../language/Languages.dart';
import '../view/component/CustomAlert.dart';
import '../view/component/toastMessage.dart';

bool validatePassword(String password) {
  // Regular expression pattern for password validation
  String pattern =
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$';

  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(password);
}

String extractNames(String fullName, bool isFirst) {
  // Trim any extra spaces and split by whitespace
  List<String> nameParts = fullName.trim().split(' ');

  // Default to an empty string if no name parts are available
  String firstName = nameParts.isNotEmpty ? nameParts.first : '';
  String lastName = nameParts.length > 1 ? nameParts.last : '';

  if (isFirst) {
    return firstName;
  } else {
    return lastName;
  }
}


bool isKeyboardOpen(BuildContext context) {
  return MediaQuery.of(context).viewInsets.bottom != 0;
}


String capitalizeFirstLetter(String input) {
  if (input.isEmpty) {
    return input;
  }
  if (input.contains("_")) {
    var replacedInput = input.replaceAll("_", " ");
    input = replacedInput;
  }
  return input[0].toUpperCase() + input.substring(1);
}


String nonCapitalizeString(String input) {
  if (input.isEmpty) {
    return input;
  }
  return input.toLowerCase();
}

String convertDateFormat(String input) {
  if (input.isEmpty) {
    return input;
  }
  String localTime = convertUtcDateToLocal(input);

  DateTime parsedDate = DateTime.parse(localTime);
  String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);

  return formattedDate;
}

String convertUtcDateToLocal(String utcTime) {
  if (utcTime.isEmpty) {
    return utcTime;
  }
  DateTime utcDateTime = DateTime.parse(utcTime);

  // Convert the DateTime object to local time
  DateTime localDateTime = utcDateTime.toLocal();

  // Print the local time
 // print('Local Time: ${localDateTime.toString()}');

  return "${localDateTime.toString()}";
}

String convertDateTimeFormat(String input) {
  if (input.isEmpty) {
    return input;
  }
  String localTime = convertUtcDateToLocal(input);

  DateTime parsedDate = DateTime.parse(localTime);
  String formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(parsedDate);

  return formattedDate;
}
String convertTimeFormat(String input) {
  if (input.isEmpty) {
    return input;
  }
  String localTime = convertUtcDateToLocal(input);

  DateTime parsedDate = DateTime.parse(localTime);
  String formattedDate = DateFormat('hh:mm a').format(parsedDate);

  return formattedDate;
}

String convertedDateTimeFormat(String input) {
  if (input.isEmpty) {
    return input;  // Return empty string if input is empty
  }

  // Parse the input as an ISO 8601 string
  DateTime parsedDate = DateTime.parse(input);

  // Convert the parsed UTC date to local time
  DateTime localDate = parsedDate.toLocal();

  // Format the local date in the desired format
  String formattedDate = DateFormat('dd-MM-yyyy').format(localDate);

  return formattedDate;
}

String convertTime(String input) {
  if (input.isEmpty) {
    return input;
  }
  String localTime = convertUtcDateToLocal(input);
  DateTime date = DateTime.parse(localTime); // Example date and time
  String formattedTime =
      DateFormat('hh:mm a').format(date); // This will output "02:30 PM"
  return formattedTime;
}

String currencyFormat(String symbol, String input, String country) {
  if (input.isEmpty) {
    return input;
  }
  double value = 0;
  print(country);

  var locale;

  if (country == "India") {
    locale = 'en_IN';
  } else if (country == "Bangladesh") {
    locale = 'bn_BD';
  } else if (country == "Saudi Arabi") {
    locale = 'ar_SA';
  }
  final formatter;
  try {
    value = double.parse(input);
  } catch (e) {
    return "${symbol}${input}";
  }
  if (country == "") {
    formatter = NumberFormat.currency(
      symbol: "${symbol}",
      decimalDigits: 2,
    );
  } else {
    formatter = NumberFormat.currency(
      locale: locale,
      symbol: "${symbol}",
      decimalDigits: 2,
    );
  }
  return "${formatter.format(value)}";
}

String convertDateMonthFormat(String input) {
  if (input.isEmpty) {
    return input;
  }
  DateTime date = DateTime.parse(input);
  String day = DateFormat('d').format(date);
  String month = DateFormat('MMM').format(date);
  return '$day\n$month';
  // return formattedDate;
}

String addCurrencySymbol(String? currencySymbol, String input) {
  if (input.isEmpty) {
    return input;
  }else if(currencySymbol == null || currencySymbol == "null"){
    return input;
  }

  if (input == "**") {
    print("object");
    return "${currencySymbol}${input}";
  }
  String amount = "";
  try {
    currencySymbol != null
        ? amount =
            "${currencySymbol}${double.parse("${input}").toStringAsFixed(2)}"
        : "${double.parse("${input}").toStringAsFixed(2)}";
  } catch (e) {
    return "${currencySymbol}${input}";
  }
  print("${input == "**"}");
  print("${input}");

  return amount;
}

bool isBalanceMoreThanAmount(String balance, String amt, BuildContext context) {
  double intBalance = extractFloat(balance);
  double inrAmt = amt != null || amt != "" ? extractFloat(amt) : 0;
  if (intBalance <= inrAmt) {
    CustomAlert.showToast(
        context: context, message: 'You do not have enough balance.');
    return false;
  } else {
    return true;
  }
}

double extractFloat(String str) {
  // Regular expression to match floating-point numbers, including those with decimals and negative sign
  final regex = RegExp(r'-?\d+(\.\d+)?');
  final match = regex.firstMatch(str);
  if (match != null) {
    return double.parse(match.group(0)!);
  } else {
    throw FormatException('No floating-point number found in the string');
  }
}

bool checkMoneyOut(String transactionType, int? senderId, int? userId){

  if(nonCapitalizeString(transactionType) == nonCapitalizeString("transfer")){
    if(userId !=0) {
      if (userId == senderId) {
        return true;
      }
      else {
        return false;
      }
    }else
      return false;
  }else if(nonCapitalizeString(transactionType) == nonCapitalizeString("withdraw")){
    return true;
  }else{
    return false;
  }

}

String addCurrencySymbolTransaction(
    String? currencySymbol, String input, String requestType, int? userId, int? senderId) {
  if (input.isEmpty) {
    return input;
  }
  String amount = "";
  currencySymbol != null
      ? amount =
          "${currencySymbol}${double.parse("${input}").toStringAsFixed(2)}"
      : "${double.parse("${input}").toStringAsFixed(2)}";
  if (checkMoneyOut(requestType, senderId, userId)) {
    amount = "-$amount";
  } else/* if (requestType == "Withdraw")*/ {
    amount = "+$amount";
  } /*else if (requestType == "Transfer") {
    amount = "-$amount";
  } else if (requestType == "In complete") {
    amount = "-$amount";
  }*/
  return amount;
}

colorStatus(String status, BuildContext context) {
  Color color = Colors.black;
  if (status == Languages.of(context)!.labelPending) {
    color = Colors.orange;
  } else if (status == Languages.of(context)!.labelSuccess) {
    color = Colors.green;
  } else if (status == Languages.of(context)!.labelRejected) {
    color = Colors.red;
  } else if (status == Languages.of(context)!.labelInComplete) {
    color = Colors.red;
  }
  return color;
}


void hideKeyBoard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

Future<String?> getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // This is the unique ID on Android devices
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor; // This is the unique ID on iOS devices
  }
  return null;
}


/// Format date in 'dd-MM-yyyy' format
String convertedDateMonthFormat(String input) {
  if (input.isEmpty) return input;
  try {
    DateTime date = DateTime.parse(input);
    return DateFormat("MMM,dd yyyy").format(date);  // Output in 29Jan2025 format
  } catch (e) {
    return 'Invalid date format';
  }
}

bool hasMinLength(String value) {
  return value.length >= 8;
}

bool hasUppercase(String value) {
  return value.contains(RegExp(r'[A-Z]'));
}

bool hasDigit(String value) {
  return value.contains(RegExp(r'\d'));
}

bool hasSpecialCharacter(String value) {
  return value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
}


Map<String, String> splitFullName(String? displayName) {
  if (displayName == null || displayName.trim().isEmpty) {
    return {'firstName': '', 'lastName': ''};
  }

  List<String> parts = displayName.trim().split(RegExp(r'\s+'));

  if (parts.length == 1) {
    return {'firstName': parts[0], 'lastName': ''};
  } else {
    String firstName = parts.first;
    String lastName = parts.sublist(1).join(' '); // handles middle names too
    return {'firstName': firstName, 'lastName': lastName};
  }
}


String safeUrl(String? url) {
  return (url == null || url.trim().isEmpty) ? "https://thechaibar.ca/" : url;
}


void handleApplePaymentResponse(Map<String, dynamic> applePaymentData) {
  try {
    final dynamic paymentDataRaw = applePaymentData["paymentData"];

    // Step 1: Decode and deeply convert to Map<String, dynamic>
    Map<String, dynamic> parsedPaymentData = {};

    if (paymentDataRaw is String) {
      final decoded = jsonDecode(paymentDataRaw);
      if (decoded is Map) {
        parsedPaymentData = deepCast(decoded);
      } else {
        throw Exception('Decoded paymentData is not a Map');
      }
    } else if (paymentDataRaw is Map) {
      parsedPaymentData = deepCast(paymentDataRaw);
    } else {
      throw Exception('Unexpected paymentData format');
    }

    // Step 2: Safely extract fields
    final header = parsedPaymentData["header"] as Map<String, dynamic>? ?? {};

    final String version = parsedPaymentData["version"] ?? "";
    final String data = parsedPaymentData["data"] ?? "";
    final String signature = parsedPaymentData["signature"] ?? "";
    final String transactionId = header["transactionId"] ?? "";
    final String ephemeralPublicKey = header["ephemeralPublicKey"] ?? "";
    final String publicKeyHash = header["publicKeyHash"] ?? "";

    final String transactionIdentifier = applePaymentData["transactionIdentifier"] ?? "";

    // Debug output
    print("Version: $version");
    print("Data: $data");
    print("Signature: $signature");
    print("TransactionId: $transactionId");
    print("EphemeralPublicKey: $ephemeralPublicKey");
    print("PublicKeyHash: $publicKeyHash");
    print("TransactionIdentifier: $transactionIdentifier");

    final encryptedWallet = {
      "version": version,
      "data": data,
      "signature": signature,
      "header": {
        "transactionId": transactionId,
        "ephemeralPublicKey": ephemeralPublicKey,
        "publicKeyHash": publicKeyHash,
      },
      "transactionIdentifier": transactionIdentifier,
    };

    print("Encrypted Wallet: $encryptedWallet");
  } catch (e, stacktrace) {
    print("Unexpected error: $e");
    print(stacktrace);
  }
}

// 👇 Deep conversion helper
Map<String, dynamic> deepCast(Map input) {
  return input.map((key, value) {
    if (value is Map) {
      return MapEntry(key.toString(), deepCast(value));
    }
    return MapEntry(key.toString(), value);
  });
}










