import 'package:ChaiBar/theme/CustomAppColor.dart';
import 'package:flutter/material.dart';

class CircleDecorator extends StatelessWidget {
  final double size;

  const CircleDecorator({required this.size});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-size * 0.5, -size * 0.6),
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: CustomAppColor.PrimaryAccent.withValues(alpha: 0.14),
      ),
    );
  }
}
