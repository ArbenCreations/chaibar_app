import 'package:flutter/material.dart';

class IndentedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
     double curveHeight = 20; // Height of the rounded curve

    // Start at the left bottom
    path.lineTo(0, size.height );
    // Draw a curve from bottom left to bottom right
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height ,
    );
    // Move up the right side
    path.lineTo(size.width, curveHeight);
    // Create rounded indentation on the top edge
    path.quadraticBezierTo(size.width - 160, 0, size.width - 160, 0);
    path.quadraticBezierTo(size.width -160, -curveHeight, 160, 0);
   // path.lineTo(160, 0); // Straight line across most of the top
    path.quadraticBezierTo(160, 0, 0, curveHeight); // Curve to create indentation on the left
    path.close();
   /* double topCurveDepth = 20; // Depth of the top curve

// Start at the left bottom
    path.lineTo(0, size.height);

// Draw a curve from bottom left to bottom right
    path.quadraticBezierTo(
      size.width / 2, size.height,
      size.width, size.height,
    );

// Move up the right side
    path.lineTo(size.width, topCurveDepth);

// Create slight curve on the top-right corner
    path.quadraticBezierTo(size.width - 40, 0, size.width - 160, 0);

// Draw a curve on the top-center
    path.quadraticBezierTo(size.width / 2, -curveHeight, 160, 0);

// Create slight curve on the top-left corner
    path.quadraticBezierTo(40, 0, 0, topCurveDepth);

// Close the path
    path.close();*/
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
