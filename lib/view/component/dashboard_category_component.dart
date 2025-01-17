import 'package:flutter/material.dart';

import '../../model/response/rf_bite/categoryListResponse.dart';
import '../../model/response/rf_bite/vendorListResponse.dart';
import '../../theme/AppColor.dart';
import '../../utils/Util.dart';
import 'circluar_profile_image.dart';

class DashboardCategoryComponent extends StatelessWidget {
  final List<CategoryData?> categories;
  final double screenWidth;
  final double screenHeight;
  final Color primaryColor;
  final bool isDarkMode;
  final VendorData? vendorData;

  const DashboardCategoryComponent({
    Key? key,
    required this.categories,
    required this.screenWidth,
    required this.screenHeight,
    required this.primaryColor,
    required this.isDarkMode,
    required this.vendorData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: categories.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var currentItem = categories[index];
        var currentCategoryName = categories[index]?.categoryName;
        var currentCategoryImage = categories[index]?.categoryImage;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: GestureDetector(
            onTap: () {
              VendorData? data = vendorData;
              data?.detailType = "menu";
              data?.selectedCategoryId = currentItem?.id;
              Navigator.pushNamed(context, "/MenuScreen", arguments: data);
            },
            child: Card(
              margin: EdgeInsets.symmetric(horizontal: 3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              elevation: 3,
              shadowColor: isDarkMode ? AppColor.DARK_CARD_COLOR : Colors.white,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color:
                        isDarkMode ? AppColor.DARK_CARD_COLOR : Colors.white),
                width: 60,
                padding: EdgeInsets.only(bottom: 8, top: 2, left: 2, right: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircularProfileImage(
                        size: 48,
                        imageUrl: currentCategoryImage,
                        name: "${currentCategoryName}",
                        needTextLetter: true,
                        placeholderImage: "",
                        isDarkMode: isDarkMode),
                    SizedBox(
                      height: 8,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        capitalizeFirstLetter("${currentCategoryName}"),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
