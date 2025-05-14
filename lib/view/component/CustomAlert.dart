import 'package:flutter/material.dart';

class CustomAlert {
  static void showToast({
    required BuildContext context,
    required String? message,
    Duration duration = const Duration(seconds: 10),
  }) {
    if (message != null && message.isNotEmpty && message != "null") {
      // Run after current frame to make sure context is stable
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            Future.delayed(duration, () {
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop(); // Auto close dialog
              }
            });

            return AlertDialog(
              title: const Text("Notice"),
              content: Text(message),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      });
    }
  }
}
