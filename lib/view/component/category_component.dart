import 'package:flutter/material.dart';

import '../../model/response/rf_bite/categoryListResponse.dart';
import '../../theme/AppColor.dart';
import '../../utils/Util.dart';
import 'circluar_profile_image.dart';

class CategoryComponent extends StatelessWidget {
  final List<CategoryData?> categories;
  final double screenWidth;
  final double screenHeight;
  final Color primaryColor;
  final bool isDarkMode;
  final String? selectedCategory;
  final Function(int index) onTap;

  const CategoryComponent({
    Key? key,
    required this.categories,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
    required this.primaryColor,
    required this.isDarkMode,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var currentItem = categories[index];
          var currentCategoryName = categories[index]?.categoryName;
          return GestureDetector(
            onTap: () {
              onTap(index);
            },
            child: Card(
              margin: EdgeInsets.only(
                  left: 3,
                  bottom: selectedCategory == currentCategoryName ? 28 : 38,
                  top: selectedCategory == currentCategoryName ? 0 : 12,
                  right: 3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              elevation: selectedCategory == currentCategoryName ? 16 : 2,
              shadowColor: AppColor.PRIMARY,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: selectedCategory == currentCategoryName
                        ? primaryColor
                        : isDarkMode?  AppColor.DARK_CARD_COLOR :Colors.white),
                width: 60,
                padding: EdgeInsets.only(bottom: 8, top: 2, left: 2, right: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircularProfileImage(
                      size: 55,
                      imageUrl: currentItem?.categoryImage,
                      name: "${currentCategoryName}",
                      needTextLetter: true,
                      placeholderImage: "",
                      isDarkMode: isDarkMode
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        capitalizeFirstLetter("${currentCategoryName}"),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 10,
                            color: selectedCategory == currentCategoryName
                                ? Colors.white
                                : isDarkMode? AppColor.WHITE : Colors.black,
                            fontWeight: selectedCategory == currentCategoryName
                                ? FontWeight.bold
                                : FontWeight.normal),
                      ),
                    ),
                    SizedBox(
                      height: selectedCategory == currentCategoryName ? 30 : 18,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
