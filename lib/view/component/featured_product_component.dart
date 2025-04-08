import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/response/productListResponse.dart';
import '../../theme/CustomAppColor.dart';
import '../../utils/Util.dart';

class FeaturedProductComponent extends StatelessWidget {
  final ProductData data;
  final double mediaWidth;
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
    required this.mediaWidth,
    required this.screenHeight,
    required this.onAddTap,
    required this.onMinusTap,
    required this.onPlusTap,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, "/ProductDetailScreen", arguments: data),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        padding: const EdgeInsets.symmetric(vertical: 2.0), // Merged Padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white, // Add a color to avoid unnecessary rebuilds
        ),
        clipBehavior: Clip.hardEdge, // Ensures content follows borderRadius
        child: Column(
          children: [
            _buildImageSection(data, context),
            _buildInfoSection(data),
          ],
        ),
      )
    );
  }

  Widget _buildImageSection(data, BuildContext context) {
    return Stack(
      children: [
        Container(
          width: mediaWidth,
          height: 120,
          margin: const EdgeInsets.only(bottom: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: data.imageUrl == null || data.imageUrl.isEmpty
              ? _placeholderImage()
              : _networkImage(data.imageUrl ?? "", context),
        ),
        _buildQuantityButton(data),
        data.featured == true
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
              child: Text(
                "Popular",
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white),
            ),)
          ),
        )
            : SizedBox(),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: CustomAppColor.Primary,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.asset(
          "assets/app_logo.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _networkImage(String? imageUrl, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Theme.of(context).cardColor, width: 0.3),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: CachedNetworkImage(
          imageUrl: imageUrl ?? "",
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.white38,
            highlightColor: Colors.grey,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.12,
              width: double.infinity,
              color: Colors.white,
            ),
          ),
          errorWidget: (context, url, error) => _placeholderImage(),
        ),
      ),
    );
  }

  Widget _buildInfoSection(data) {
    return Container(
      width: mediaWidth,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  capitalizeFirstLetter(data.title),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            /*  Row(
                children: const [
                  Icon(Icons.thumb_up, size: 14),
                  SizedBox(width: 2),
                  Text("10%", style: TextStyle(fontSize: 10)),
                ],
              ),*/
            ],
          ),
          const SizedBox(height: 3), // Added spacing
          Text(
            "Get your food from Chai bar, we are happy to serve you",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "\$${data.price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(data) {
    return Align(
      alignment: Alignment.bottomRight,
      child: data.quantity == 0
          ? GestureDetector(
              onTap: onPlusTap,
              child: Container(
                width: 35,
                height: 35,
                margin: const EdgeInsets.only(right: 0, top: 0),
                decoration: BoxDecoration(
                  color: CustomAppColor.PrimaryAccent,
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                ),
                child: const Center(
                  child: Icon(Icons.add, size: 24, color: Colors.white),
                ),
              ),
            )
          : IntrinsicWidth(
            child: Container(
                margin: EdgeInsets.only(top: 4, right: 4),
                decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Row(
                      children: [
                        /*Text(
                                                'Quantity: ', style: TextStyle(fontSize: 12),),*/
                        GestureDetector(
                          child: Icon(
                            Icons.remove_circle_outline_rounded,
                            size: 24,
                            color:
                                data.quantity == 0 ? Colors.grey : Colors.black54,
                          ),
                          onTap: onMinusTap,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          "${data.quantity.toString()}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        GestureDetector(
                          child: Icon(
                            Icons.add_circle_outlined,
                            size: 24,
                            color: CustomAppColor.PrimaryAccent,
                          ),
                          onTap: onAddTap,
                        ),
                      ],
                    )),
              ),
          ),
    );
  }

// Helper method to build the card
}
