import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/response/productListResponse.dart';
import '../../theme/CustomAppColor.dart';
import '../../utils/Util.dart';

class ProductComponent extends StatelessWidget {
  final ProductData item;
  final double mediaWidth;
  final bool isDarkMode;
  final double screenHeight;
  final Color primaryColor;
  final bool showFavIcon;
  final Function() onAddTap;
  final Function() onMinusTap;
  final Function() onPlusTap;
  final Function() onFavoriteTap;

  const ProductComponent({
    Key? key,
    required this.item,
    required this.mediaWidth,
    required this.isDarkMode,
    required this.screenHeight,
    required this.onAddTap,
    required this.showFavIcon,
    required this.onMinusTap,
    required this.onPlusTap,
    required this.onFavoriteTap,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "/ProductDetailScreen", arguments: item);
      },
      child: Container(
        width: (mediaWidth / 2) - 20,
        padding: EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            item.imageUrl == null || item.imageUrl == ""
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: primaryColor,
                    ),
                    child: ClipRRect(
                      // Ensures rounded corners apply to the image
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        "assets/app_logo.png",
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit
                            .cover, // Use BoxFit.cover to maintain aspect ratio and fill the container
                      ),
                    ),
                  )
                : Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Theme.of(context).cardColor, width: 0.3),
                          color: isDarkMode
                              ? CustomAppColor.DarkCardColor
                              : Colors.white,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: "${item.imageUrl ?? ""}",
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Shimmer.fromColors(
                              baseColor: Colors.white38,
                              highlightColor: Colors.grey,
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Image.asset(
                                "assets/app_logo.png",
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      item.featured == true
                          ? Positioned(
                              top: 6,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.green,
                                ),
                                child: Align(
                                  alignment: Alignment.bottomRight,
                                  child: item.quantity == 0
                                      ? Text(
                                          "Popular",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white),
                                        )
                                      : SizedBox(),
                                ),
                              ),
                            )
                          : SizedBox(),
                      Positioned(
                        bottom: 6,
                        right: 8,
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                              ),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.thumb_up, size: 12),
                                        SizedBox(width: 2),
                                        Text("${item.upvote_percentage ?? 0}%",
                                            style: TextStyle(fontSize: 9)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 2),
                            /* Container(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Colors.white,
                              ),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.thumb_down, size: 14),
                                        SizedBox(width: 2),
                                        Text("${item.downvote_percentage}%", style: TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),*/
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        left: 0,
                        child: Container(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: item.quantity == 0
                                ? GestureDetector(
                                    onTap: () {
                                      onAddTap();
                                    },
                                    child: Card(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      color: isDarkMode
                                          ? CustomAppColor.DarkCardColor
                                          : CustomAppColor.PrimaryAccent,
                                      child: Container(
                                          width: 32,
                                          height: 32,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                          )),
                                    ),
                                  )
                                : SizedBox(),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: item.quantity == 0
                                ? SizedBox()
                                : Card(
                                    child: Container(
                                      margin: EdgeInsets.all(6),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          color: isDarkMode
                                              ? CustomAppColor.DarkCardColor
                                              : Colors.white),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            child: Icon(
                                              Icons.remove,
                                              size: 18,
                                              color: primaryColor,
                                            ),
                                            onTap: () {
                                              onMinusTap();
                                            },
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            item.quantity.toString(),
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
                                            onTap: () {
                                              onPlusTap();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      item.isBuy1Get1 == true
                          ? Container(
                              width: double.infinity,
                              height: screenHeight * 0.165,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 6),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 3, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: CustomAppColor.Primary,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Text(
                                      "Buy 1 GET 1",
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    )),
                              ))
                          : SizedBox()
                    ],
                  ),
            //SizedBox(height: 2,),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: mediaWidth * 0.3,
                        child: Text(
                          capitalizeFirstLetter("${item.title}"),
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        //width: mediaWidth * 0.13,
                        child: Text(
                          "\$${item.price}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      )
                    ],
                  ),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 1.8,
                          height: double.infinity,
                          // Set to null so it can adjust dynamically
                          color: primaryColor,
                          margin:
                              EdgeInsets.only(right: 5, top: 3.5, bottom: 3.5),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            child: Text(
                              capitalizeFirstLetter('${item.shortDescription}'),
                              style: TextStyle(
                                fontSize: 10,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
