import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:toastification/toastification.dart';

class CustomToast {
  static void showToast({
    required BuildContext context,
    required String? message,
    Duration duration = const Duration(seconds: 5),
  }) {
    Fluttertoast.cancel(); // Cancel any existing toast before showing a new one

    if(message!=null && message.isNotEmpty  && message!="null") {
      Fluttertoast.showToast(
        msg: "${message}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 2, /*
      backgroundColor: Colors.black,
      textColor: Colors.white,*/
        fontSize: 11.0,
      );
    }
    }
  }
