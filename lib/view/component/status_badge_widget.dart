import 'package:flutter/material.dart';

class StatusBadgeWidget extends StatelessWidget {
  late final Color color;
  late final String status;

  StatusBadgeWidget({
    required this.color,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: color),
          padding: EdgeInsets.symmetric(vertical: 6, horizontal: 15),
          child: Row(
            children: [
              Text(status,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
