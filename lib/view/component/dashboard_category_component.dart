import 'package:flutter/material.dart';

import '../../model/response/categoryListResponse.dart';
import '../../model/response/vendorListResponse.dart';

class DashboardCategoryComponent extends StatefulWidget {
  final List<CategoryData?> categories;
  final double mediaWidth;
  final double screenHeight;
  final Color primaryColor;
  final bool isDarkMode;
  final CategoryData? categoryData;
  final Function(CategoryData?) onCategoryTap;
  final VendorData? vendorData;

  const DashboardCategoryComponent({
    Key? key,
    required this.categories,
    required this.mediaWidth,
    required this.screenHeight,
    required this.primaryColor,
    required this.isDarkMode,
    required this.categoryData,
    required this.onCategoryTap,
    required this.vendorData,
  }) : super(key: key);

  @override
  _DashboardCategoryComponentState createState() =>
      _DashboardCategoryComponentState();
}

class _DashboardCategoryComponentState
    extends State<DashboardCategoryComponent> {
  CategoryData? selectedCategory; // Store the selected category

  @override
  void initState() {
    super.initState();
    selectedCategory =
        widget.categoryData; // Initialize with the passed category
  }


  @override
  void didUpdateWidget(covariant DashboardCategoryComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update selectedCategory when widget.categoryData changes
    if (widget.categoryData?.id != oldWidget.categoryData?.id) {
      setState(() {
        selectedCategory = widget.categoryData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //print("selectedCategory ${widget.categoryData?.categoryName}");
    selectedCategory = selectedCategory ?? widget.categoryData;
    return ListView.builder(
      itemCount: widget.categories.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var currentItem = widget.categories[index];
        var currentCategoryName = currentItem?.categoryName;
        var currentCategoryImage = currentItem?.categoryImage ?? "";
        bool isSelected = selectedCategory?.id == currentItem?.id;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedCategory = currentItem; // Update currentItem
            });
            widget.onCategoryTap(currentItem);
          },
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isSelected ? widget.primaryColor : Colors.white,
                    // Change color if selected
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 55,
                            height: 55,
                            child: Image.network(
                              currentCategoryImage,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            left: 5,
                            child: Container(
                              width: 45,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: widget.mediaWidth,
                        height: 25,
                        alignment: Alignment.center,
                        child: Text(
                          "$currentCategoryName",
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black54,
                            fontSize: 11,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
