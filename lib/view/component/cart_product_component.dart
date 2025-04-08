import 'package:ChaiBar/theme/CustomAppColor.dart';
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
    return Dismissible(
      key: Key(item.id.toString()),
      // Ensure each item has a unique key
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onRemoveTap(); // Call the remove function when swiped
      },
      background: Container(
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              // Shadow color
              offset: Offset(0, 1),
              // Adjust X and Yoffset to match Figma
              blurRadius: 5,
              // Adjust this for more/less blur
              spreadRadius: 0.1, // Adjust spread if needed
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.only(top: 5),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
          width: mediaWidth,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.08),
                // Shadow color
                offset: Offset(0, 2),
                // Adjust X and Yoffset to match Figma
                blurRadius: 10,
                // Adjust this for more/less blur
                spreadRadius: 0.2, // Adjust spread if needed
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              item.imageUrl == "" || item.imageUrl == null
                  ? Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: primaryColor),
                      child: Image.asset(
                        "assets/app_logo.png",
                        height: 65,
                        width: 65,
                        fit: BoxFit.fitWidth,
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                            color: Theme.of(context).cardColor, width: 0.3),
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          "${item.imageUrl}",
                          height: 65,
                          width: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context,
                              Object exception, StackTrace? stackTrace) {
                            return Container(
                              child: Image.asset(
                                "assets/app_logo.png",
                                height: 65,
                                width: 65,
                                fit: BoxFit.fitWidth,
                              ),
                            );
                          },
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Shimmer.fromColors(
                                baseColor: Colors.white38,
                                highlightColor: Colors.grey,
                                child: Container(
                                  height: 65,
                                  width: 65,
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Container(
                  width: mediaWidth * 0.7,
                  child: Column(
                    children: [
                      Container(
                        //height: 90,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              item.isBuy1Get1 == true
                                  ? Text(
                                      "Buy 1 GET 1",
                                      style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red),
                                    )
                                  : SizedBox(),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: mediaWidth * 0.5,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            capitalizeFirstLetter(
                                              "${item.title}",
                                            ),
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        /* item?.productSizesList ==
                                                                "[]" || item?.productSizesList?.isEmpty == true ? */
                                        /*  Text(' (\$${(item.price)})',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[700]))*/
                                        //: SizedBox(),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Align(
                                      alignment: Alignment.topRight,
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Colors.black54,
                                        size: 14,
                                      )),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          width: mediaWidth * 0.5,
                                          child: Text(
                                            item.getAddOnList()?.isEmpty ==
                                                    true
                                                ? capitalizeFirstLetter(
                                                    "${item.shortDescription}")
                                                : addOns(item),
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey[700]),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: item
                                                        .getAddOnList()
                                                        ?.isEmpty ==
                                                    true
                                                ? 1
                                                : 2,
                                          )),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                              '\$${itemTotalPrice.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                          item.getAddOnList()?.isEmpty == true
                                              ? SizedBox()
                                              : Text(
                                                  '+\$${addOnTotalPrice.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey[600])),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      /* item?.productSizesList ==
                                                              "[]" || item?.productSizesList?.isEmpty == true ? */
                                      Row(
                                        children: [
                                          /*Text(
                                              'Quantity: ', style: TextStyle(fontSize: 12),),*/
                                          GestureDetector(
                                            child: Icon(
                                              Icons
                                                  .remove_circle_outline_rounded,
                                              size: 20,
                                              color: item.quantity == 0
                                                  ? Colors.grey
                                                  : Colors.grey,
                                            ),
                                            onTap: onMinusTap,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "${item.quantity.toString()}",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          GestureDetector(
                                            child: Icon(
                                              Icons.add_circle_outlined,
                                              size: 20,
                                              color: CustomAppColor
                                                  .ButtonBackColor,
                                            ),
                                            onTap: onAddTap,
                                          ),
                                        ],
                                      )
                                      /* : Text(
                                                            '${item?.quantity}',
                                                            style: TextStyle(
                                                                fontSize:
                                                                    12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),*/
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
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
  String addOns(ProductData item) {
    String text = "";
    item.getAddOnList().forEach((category) {
      if (category.addOnCategoryType == "multiple") {
        category.addOns?.forEach((addOn) {
          text = capitalizeFirstLetter("${addOn.name} ");
        });
      } else {
        category.addOns?.forEach((addOn) {
          text = capitalizeFirstLetter("${addOn.name} ");
        });
      }
    });
    return text;
  }
}
