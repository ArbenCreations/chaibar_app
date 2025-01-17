import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerText extends StatelessWidget {
  late final double height;
  late final double width;


  //NewsOfferListWidget(ScrollController scrollController);

  ShimmerText({required this.height,required this.width});
  @override
  Widget build(BuildContext context) {
    return   Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12),
              color: Colors.white,),
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
            height: height,
            width: width,
          ),
        );
  }
}
