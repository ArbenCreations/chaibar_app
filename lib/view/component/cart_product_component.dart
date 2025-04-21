import 'dart:convert';

import 'package:ChaiBar/theme/CustomAppColor.dart';
import 'package:ChaiBar/view/component/CustomSnackbar.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/response/productListResponse.dart';
import '../../utils/Util.dart';

class CartProductComponent extends StatelessWidget {
  final ProductData item;
  final double mediaWidth;
  final double itemTotalPrice;
  final double addOnTotalPrice;
  final bool isDarkMode;
  final double screenHeight;
  final Color primaryColor;
  final Function() onAddTap;
  final Function() onMinusTap;
  final Function() onRemoveTap;

  const CartProductComponent({
    Key? key,
    required this.item,
    required this.mediaWidth,
    required this.isDarkMode,
    required this.itemTotalPrice,
    required this.addOnTotalPrice,
    required this.screenHeight,
    required this.onAddTap,
    required this.onMinusTap,
    required this.onRemoveTap,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //CustomSnackBar.showSnackbar(context: context, message: "${jsonDecode("${item?.addOn}")}");
    return Dismissible(
      key: Key(item.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onRemoveTap();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete, color: Colors.white, size: 24),
      ),
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: item.imageUrl == null || item.imageUrl!.isEmpty
                  ? Image.asset(
                      "assets/app_logo.png",
                      height: 65,
                      width: 65,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      item.imageUrl!,
                      height: 65,
                      width: 65,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, _) => Image.asset(
                        "assets/app_logo.png",
                        height: 65,
                        width: 65,
                        fit: BoxFit.cover,
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: 65,
                            width: 65,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(width: 14),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.isBuy1Get1 == true)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        "Buy 1 GET 1",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          capitalizeFirstLetter(item.title.toString()),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 14, color: Colors.grey),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    item.getAddOnList()?.isEmpty ?? true
                        ? capitalizeFirstLetter(
                            item.shortDescription.toString())
                        : addOns(item, context),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            '\$${itemTotalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!(item.getAddOnList()?.isEmpty ?? true)) ...[
                            SizedBox(width: 4),
                            Text(
                              '+\$${addOnTotalPrice.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ]
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: onMinusTap,
                            child: Icon(Icons.remove_circle_outline,
                                size: 22, color: Colors.grey),
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${item.quantity}',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          GestureDetector(
                            onTap: onAddTap,
                            child: Icon(Icons.add_circle_outline,
                                size: 22,
                                color: CustomAppColor.ButtonBackColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /*productSize.isNotEmpty
                                          ? Container(
                                              width: mediaWidth * 0.48,
                                              child: Wrap(
                                                spacing: 10,
                                                runSpacing: 5,
                                                children: List.generate(
                                                    productSize.length,
                                                    (index) {
                                                  itemTotalPrice = itemTotalPrice +
                                                      (int.parse(
                                                              "${productSize[index].price}") *
                                                          productSize[index]
                                                              .quantity);
                                                  return productSize[index]
                                                              .quantity >
                                                          0
                                                      ? Container(
                                                          width: mediaWidth *
                                                              0.48,
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  ConstrainedBox(
                                                                    constraints:
                                                                        BoxConstraints(
                                                                            maxWidth:
                                                                                mediaWidth * 0.173),
                                                                    child: Text(
                                                                      capitalizeFirstLetter(
                                                                          '${productSize[index].size}: '),
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              11,
                                                                          color:
                                                                              Colors.grey[700]),
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '\$${productSize[index].price}/item ',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        color: Colors
                                                                            .grey[700]),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  GestureDetector(
                                                                    child: Icon(
                                                                      Icons
                                                                          .remove_circle_outline_rounded,
                                                                      size: 18,
                                                                      color:
                                                                          primaryColor,
                                                                    ),
                                                                    onTap: () {
                                                                      if (int.parse(
                                                                              "${productSize[index].quantity}") >
                                                                          0) {
                                                                        productSize[index]
                                                                            .quantity--;
                                                                        item?.quantity--;

                                                                        setState(
                                                                            () {
                                                                          item?.productSizesList =
                                                                              jsonEncode(productSize);
                                                                          itemTotalPrice =
                                                                              itemTotalPrice + (int.parse("${productSize[index].price}") * productSize[index].quantity);
                                                                        });
                                                                        deleteProductInDb(item
                                                                            as ProductData);
                                                                      }
                                                                    },
                                                                  ),
                                                                  ConstrainedBox(
                                                                    constraints: BoxConstraints(
                                                                        minWidth:
                                                                            12,
                                                                        maxWidth:
                                                                            15),
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "${productSize[index].quantity.toString()}",
                                                                          style: TextStyle(
                                                                              fontSize: 12,
                                                                              color: Colors.grey[700]),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  GestureDetector(
                                                                    child: Icon(
                                                                      Icons
                                                                          .add_circle_outline_outlined,
                                                                      size: 18,
                                                                      color:
                                                                          primaryColor,
                                                                    ),
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        if (int.parse("${item?.quantity}") <=
                                                                            int.parse("${item?.qtyLimit}")) {
                                                                          productSize[index]
                                                                              .quantity++;
                                                                          item?.quantity++;

                                                                          setState(
                                                                              () {
                                                                            item?.productSizesList =
                                                                                jsonEncode(productSize);
                                                                            itemTotalPrice =
                                                                                itemTotalPrice + (int.parse("${productSize[index].price}") * productSize[index].quantity);
                                                                          });
                                                                          addProductInDb(item
                                                                              as ProductData);
                                                                        }
                                                                      });
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : SizedBox();
                                                }),
                                              ),
                                            )
                                          : SizedBox()*/
  String addOns(ProductData item, BuildContext context) {
    String text = "";

    item.getAddOnList().forEach((category) {
      print("${category?.addOns?.length}");
      //CustomSnackBar.showSnackbar(context: context, message: "${category?.addOns?.length}");
      if (category.addOnCategoryType == "multiple") {
        List<String> names = [];
        category.addOns?.forEach((addOn) {
          names.add(capitalizeFirstLetter("${addOn.name}"));
        });
        text = names.join(", ");
      } else {
        category.addOns?.forEach((addOn) {
          text = capitalizeFirstLetter("${addOn.name} ");
        });
      }
    });
    return text;
  }
}
