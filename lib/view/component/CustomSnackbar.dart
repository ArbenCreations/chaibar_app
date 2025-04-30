import 'package:flutter/material.dart';

class CustomSnackBar {
  static void showSnackbar({
    required BuildContext context,
    required String? message,
    Duration duration = const Duration(seconds: 10),
    bool isClick = false,
  }) {
    if (message != null && message.isNotEmpty && message != "null") {
      Future.microtask(() {
        if (!context.mounted) return;

        final snackBar = SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              if(isClick)
                {
                  Navigator.pushReplacementNamed(context, "/BottomNavigation",
                      arguments: 3);
                }
              // Optional: Add logic here if needed
            },
          ),
        );

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      });
    }
  }
}

