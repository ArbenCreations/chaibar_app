import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/response/rf_bite/categoryListResponse.dart';
import '../../model/response/rf_bite/productListResponse.dart';
import '../../theme/AppColor.dart';
import '../../utils/Util.dart';
import 'circluar_profile_image.dart';

class MenuScreenCategoryComponent extends StatelessWidget {
  final List<CategoryData?> categories;
  final double screenWidth;
  final double screenHeight;
  final Color primaryColor;
  final bool isDarkMode;
  final Function(CategoryData? categoryData) onTap;

  const MenuScreenCategoryComponent({
    Key? key,
    required this.categories,
    required this.screenWidth,
    required this.screenHeight,
    required this.onTap,
    required this.primaryColor,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Wrap(
            spacing: 6,
            // Horizontal space between items
            runSpacing: 5,
            // Vertical space between lines
            children:
            categories.map((result) {
              //CategoryData? result = categories[index];
              return Container(
                child: GestureDetector(
                  onTap: () {
                    onTap(result);
                  },
                  child: Container(
                      width: 95,
                      decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius
                              .circular(
                              12),
                          color: isDarkMode
                              ? AppColor
                              .DARK_CARD_COLOR
                              : Colors.grey[
                          200]),
                      margin: EdgeInsets
                          .symmetric(
                          horizontal:
                          5,
                          vertical:
                          5),
                      padding: EdgeInsets
                          .symmetric(
                          vertical: 8,
                          horizontal:
                          4),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .center,
                        children: [
                          CircularProfileImage(
                            size: 55,
                            imageUrl: result
                                ?.categoryImage,
                            name:
                            "${result?.categoryName}",
                            needTextLetter:
                            true,
                            placeholderImage:
                            "",
                              isDarkMode: isDarkMode
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: 105,
                            child: Center(
                              child: Text(
                                capitalizeFirstLetter(
                                    "${result?.categoryName}"),
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style: TextStyle(
                                    fontSize:
                                    12,
                                    color: isDarkMode
                                        ? AppColor.WHITE
                                        : AppColor.BLACK,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              );
            }).toList()),
      ),
    );
  }

// Helper method to build the card
}
