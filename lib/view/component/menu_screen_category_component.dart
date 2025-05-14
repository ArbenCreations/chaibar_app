import 'package:flutter/material.dart';

import '../../model/response/categoryListResponse.dart';
import '../../theme/CustomAppColor.dart';
import '../../utils/Util.dart';
import 'circluar_profile_image.dart';

class MenuScreenCategoryComponent extends StatelessWidget {
  final List<CategoryData?> categories;
  final double mediaWidth;
  final double screenHeight;
  final Color primaryColor;
  final bool isDarkMode;
  final Function(CategoryData? categoryData) onTap;

  const MenuScreenCategoryComponent({
    Key? key,
    required this.categories,
    required this.mediaWidth,
    required this.screenHeight,
    required this.onTap,
    required this.primaryColor,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3,
            mainAxisSpacing: 2,
            childAspectRatio: 1, // Adjust aspect ratio as needed
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final result = categories[index];

            return GestureDetector(
              onTap: () {
                onTap(result);
              },
              child: Container(
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isDarkMode
                      ? CustomAppColor.DarkCardColor
                      : CustomAppColor.PrimaryAccent,
                ),
                margin: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProfileImage(
                      size: 60,
                      imageUrl: result?.categoryImage,
                      name: "${result?.categoryName}",
                      needTextLetter: true,
                      placeholderImage: "",
                      isDarkMode: isDarkMode,
                    ),
                    SizedBox(height: 5),
                    Container(
                      width: 90,
                      child: Center(
                        child: Text(
                          capitalizeFirstLetter("${result?.categoryName}"),
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDarkMode ? Colors.white : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
