import 'package:flutter/material.dart';


class CustomCircularProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Block interaction
        ModalBarrier(dismissible: false, color: Colors.black12),
        // Loader indicator using GIF
        Center(
          child: Image.asset(
            'assets/spinner.gif', // Ensure the path is correct
            width: 160, // Adjust size as needed
            height: 140,
          ),
        ),
      ],
    );
  }
}
