import 'package:flutter/material.dart';

import '../../theme/AppColor.dart';

class DashboardSearchComponent extends StatelessWidget {
  final TextEditingController queryController;
  final double screenWidth;
  final double screenHeight;
  final Color primaryColor;
  final Function() onTap;
  final List<String> hintTexts;
  final int hintIndex;

  const DashboardSearchComponent({
    Key? key,
    required this.queryController,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
    required this.hintTexts,
    required this.hintIndex,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              margin: EdgeInsets.only(top: 8, right: 12, left: 12),
              elevation: 0.3,
              child: Container(
                width: screenWidth * 0.85,
                height: 45,
                margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                        obscureText: false,
                        obscuringCharacter: "*",/*
                        controller: queryController,*/
                        readOnly: true,
                        onSubmitted: (value) {},
                        keyboardType: TextInputType.visiblePassword,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0.8)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.transparent, width: 0.7)),
                          hintText: "",
                          hintStyle: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                          prefixIcon: Icon(
                            Icons.search_outlined,
                            color: AppColor.PRIMARY,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 65,
              top: 20,
              // Adjust left padding to align with TextField text
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: child.key == ValueKey(hintTexts[hintIndex])
                        ? Offset(0, 0.8) // New text enters from bottom
                        : Offset(0, -0.8),
                    // Old text exits towards the top
                    end: Offset(0, 0),
                  ).animate(animation);
                  return SlideTransition(
                    position: offsetAnimation,
                    child: Align(alignment: Alignment.centerLeft, child: child),
                  );
                },
                child: Text(
                  hintTexts[hintIndex],
                  key: ValueKey<String>(hintTexts[hintIndex]),
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// Helper method to build the card
}
