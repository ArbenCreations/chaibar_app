import 'package:flutter/material.dart';

import '../../utils/Helper.dart';
import '../../utils/Util.dart';

class ApplyCouponDialog{
  static Future<void> showDialogBox({
    required BuildContext context,
    required TextEditingController couponController,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: Border.all(),
          title: Text("Enter coupon code to apply"),
          content: SingleChildScrollView(
              child: Expanded(
                child: TextField(
                  style: TextStyle(
                    fontSize: 14.0,
                  ),
                  obscureText: false,
                  obscuringCharacter: "*",
                  controller: couponController,
                  onChanged: (value) {
                    // _isValidInput();
                  },
                  onSubmitted: (value) {},
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Coupon Code",
                    icon: Icon(Icons.card_giftcard),
                  ),
                ),
              ),),
          actions: <Widget>[
            TextButton(
              child: Text('Apply'),
              onPressed: () {
                hideKeyBoard();
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}