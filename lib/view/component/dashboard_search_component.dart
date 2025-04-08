import 'package:flutter/material.dart';

import '../../theme/CustomAppColor.dart';

class DashboardSearchComponent extends StatelessWidget {
  final TextEditingController queryController;
  final double mediaWidth;
  final double screenHeight;
  final Color primaryColor;
  final Function() onTap;
  final int hintIndex;

  const DashboardSearchComponent({
    Key? key,
    required this.queryController,
    required this.mediaWidth,
    required this.screenHeight,
    required this.onTap,
    required this.hintIndex,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: mediaWidth * 0.9,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.06),
                  // Shadow color
                  offset: Offset(0, 1),
                  // Adjust X and Yoffset to match Figma
                  blurRadius: 5,
                  // Adjust this for more/less blur
                  spreadRadius: 0.1, // Adjust spread if needed
                ),
              ]),
          height: 45,
          margin: EdgeInsets.only(top: 4),
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.search_outlined,
                color: Colors.black54,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                "Search food, drinks, deserts",
                style: TextStyle(
                    fontSize: 13.0,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.normal),
              ),
              Spacer(),
              Container(
                height: 35,
                width: 1,
                margin: EdgeInsets.only(right: 10),
                color: Colors.grey.shade300,
              ),
              Icon(
                Icons.filter_list,
                color: CustomAppColor.PrimaryAccent,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

// Helper method to build the card
}
