import 'dart:io';

import 'package:ChaatBar/utils/Helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../languageSection/Languages.dart';
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
    ToastComponent.showToast(
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




