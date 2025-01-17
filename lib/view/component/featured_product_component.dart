import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/response/rf_bite/productListResponse.dart';
import '../../theme/AppColor.dart';
import '../../utils/Util.dart';

class FeaturedProductComponent extends StatelessWidget {
  final ProductData data;
  final double screenWidth;
  final bool isDarkMode;
  final int index;
  final double screenHeight;
  final Color primaryColor;
  final Function() onAddTap;
  final Function() onMinusTap;
  final Function() onPlusTap;

  const FeaturedProductComponent({
    Key? key,
    required this.data,
    required this.index,
    required this.isDarkMode,
    required this.screenWidth,
    required this.screenHeight,
    required this.onAddTap,
    required this.onMinusTap,
    required this.onPlusTap,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/ProductDetailScreen", arguments: data);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2),
        child: Card(
          child: Container(
            width: screenWidth * 0.6,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12.5),
                            topRight: Radius.circular(12.5)),
                      ),
                      child: data.imageUrl == "" || data.imageUrl == null
                          ? Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.5),
                                      topRight: Radius.circular(12.5)),
                                  color: AppColor.PRIMARY),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.5),
                                    topRight: Radius.circular(12.5)),
                                child: Image.asset(
                                  "assets/pizza_image.jpg",
                                  height: screenHeight * 0.105,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.5),
                                    topRight: Radius.circular(12.5)),
                                border: Border.all(
                                    color: Theme.of(context).cardColor,
                                    width: 0.3),
                                color: isDarkMode
                                    ? AppColor.DARK_CARD_COLOR
                                    : Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12.5),
                                    topRight: Radius.circular(12.5)),
                                child: Image.network(
                                  "${data.imageUrl}",
                                  height: screenHeight * 0.105,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return Container(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12.5),
                                            topRight: Radius.circular(12.5)),
                                        child: Image.asset(
                                          "assets/pizza_image.jpg",
                                          height: screenHeight * 0.11,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Shimmer.fromColors(
                                        baseColor: Colors.white38,
                                        highlightColor: Colors.grey,
                                        child: Container(
                                          height: screenHeight * 0.105,
                                          width: double.infinity,
                                          color: Colors.white,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: data.quantity == 0
                              ? GestureDetector(
                                  onTap: onPlusTap,
                                  child: Card(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      child: Center(
                                        child: Text(
                                          "+",
                                          style: TextStyle(
                                              fontSize: 22,
                                              color: primaryColor),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Card(
                                  child: Container(
                                    margin: EdgeInsets.all(6),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          child: Icon(
                                            Icons.remove,
                                            size: 18,
                                            color: primaryColor,
                                          ),
                                          onTap: onMinusTap,
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                          data.quantity.toString(),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        SizedBox(
                                          width: 4,
                                        ),
                                        GestureDetector(
                                          child: Icon(
                                            Icons.add,
                                            size: 18,
                                            color: primaryColor,
                                          ),
                                          onTap: onAddTap,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Container(
                        width: double.infinity,
                        height: screenHeight * 0.105,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: AppColor.SECONDARY),
                              padding: EdgeInsets.all(3),
                              margin: EdgeInsets.all(4.5),
                              child: Text(
                                "#$index most liked",
                                style: TextStyle(fontSize: 9,color : Colors.white),
                              )),
                        ))
                  ],
                ),
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 4.0, bottom: 2, right: 8, left: 8),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: screenWidth * 0.38,
                              child: Text(
                                capitalizeFirstLetter("${data.title}"),
                                style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  WidgetSpan(
                                    child: Transform.translate(
                                      offset: const Offset(0, -4),
                                      // Moves the dollar sign slightly upward
                                      child: Text(
                                        "\$",
                                        style: TextStyle(
                                          fontSize: 10,
                                          // Smaller font size for the dollar sign
                                          color:
                                              primaryColor, // Color of the dollar sign
                                        ),
                                      ),
                                    ),
                                  ),
                                  TextSpan(
                                    text: "${data.price}",
                                    // Price value
                                    style: TextStyle(
                                      fontSize: 13,
                                      // Regular font size for price
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor, // Color for price
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 1,
                        ),
                        /*Container(
                        width: double.infinity,
                        child: Text(
                          '${data.shortDescription}',
                          style:
                              TextStyle(fontSize: 10, color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),*/
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Helper method to build the card
}
