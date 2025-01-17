import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CategoryShimmerList extends StatelessWidget {
  const CategoryShimmerList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: 3,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 9, vertical: 2),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.white38,
            highlightColor: Colors.grey,
            child: Container(
              margin: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(80),
              ),
              height: 50,
              width: 60,
            ),
          );
        });
  }
}
