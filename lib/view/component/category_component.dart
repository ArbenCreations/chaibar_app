import 'package:flutter/material.dart';

import '../../model/response/categoryListResponse.dart';
import '../../theme/CustomAppColor.dart';
import '../../utils/Util.dart';

class CategoryComponent extends StatefulWidget {
  final List<CategoryData?> categories;
  final double mediaWidth;
  final double screenHeight;
  final Color primaryColor;
  final bool isDarkMode;
  final String? selectedCategory;
  final Function(int index) onTap;

  const CategoryComponent({
    Key? key,
    required this.categories,
    required this.mediaWidth,
    required this.screenHeight,
    required this.onTap,
    required this.primaryColor,
    required this.isDarkMode,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  _CategoryComponentState createState() => _CategoryComponentState();
}

class _CategoryComponentState extends State<CategoryComponent> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: widget.categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          var currentItem = widget.categories[index];
          var currentCategoryName = widget.categories[index]?.categoryName;
          return GestureDetector(
            onTap: () {
              widget.onTap(index);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 0),
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      capitalizeFirstLetter("${currentCategoryName}"),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: widget.selectedCategory == currentCategoryName
                            ? 16
                            : 13,
                        color: widget.selectedCategory == currentCategoryName
                            ? Colors.white
                            : widget.isDarkMode
                                ? Colors.white
                                : Colors.white70,
                        fontWeight:
                            widget.selectedCategory == currentCategoryName
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                  widget.selectedCategory == currentCategoryName
                      ? Container(
                          height: 3,
                          width: 20,
                          color: CustomAppColor.PrimaryAccent,
                        )
                      : SizedBox()
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
