import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../model/response/rf_bite/productListResponse.dart';
import '../../theme/AppColor.dart';
import '../../utils/Util.dart';

class CartProductComponent extends StatelessWidget {
  final ProductData item;
  final double screenWidth;
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
    required this.screenWidth,
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
    return Container(
        padding: EdgeInsets.only(bottom: 12),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    width: 0.1, color: Colors.black87))),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              item.imageUrl == "" || item.imageUrl == null
                  ? Container(
                decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(12.5),
                    color: primaryColor),
                child: Image.asset(
                  "assets/pizza_image.jpg",
                  height: 75,
                  width: 75,
                  fit: BoxFit.fitWidth,
                ),
              )
                  : Container(
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(12.5),
                  border: Border.all(
                      color: Theme.of(context).cardColor,
                      width: 0.3),
                  color: Colors.white,
                ),
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(12.5),
                  child: Image.network(
                    "${item.imageUrl}",
                    height: 75,
                    width: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (BuildContext context,
                        Object exception,
                        StackTrace? stackTrace) {
                      return Container(
                        child: Image.asset(
                          "assets/pizza_image.jpg",
                          height: 75,
                          width: 75,
                          fit: BoxFit.fitWidth,
                        ),
                      );
                    },
                    loadingBuilder: (BuildContext context,
                        Widget child,
                        ImageChunkEvent?
                        loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Shimmer.fromColors(
                          baseColor: Colors.white38,
                          highlightColor: Colors.grey,
                          child: Container(
                            height: 75,
                            width: 75,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.only( left: 12),
                child: Container(
                  width: screenWidth * 0.65,
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              item.isBuy1Get1 == true ?
                              Text("Buy 1 GET 1",style: TextStyle(fontSize: 9,fontWeight: FontWeight.bold,color: Colors.red),):SizedBox(),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Container(
                                    width: screenWidth*0.55,
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            capitalizeFirstLetter(
                                              "${item.title}",
                                            ),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight:
                                                FontWeight
                                                    .w600),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        /* item?.productSizesList ==
                                                                "[]" || item?.productSizesList?.isEmpty == true ? */
                                        Text(
                                            ' (\$${(item.price)})',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors
                                                    .grey[
                                                700]))
                                        //: SizedBox(),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: onRemoveTap,
                                      child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.close,
                                            color: primaryColor,
                                            size: 18,
                                          ))),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize:
                                    MainAxisSize.max,
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Container(
                                          width: screenWidth * 0.44,
                                          child: Text(
                                            item.getAddOnList()?.isEmpty == true ?
                                            capitalizeFirstLetter(
                                                "${item.shortDescription}") :
                                            addOns(item),
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: Colors
                                                    .grey[600]),
                                            overflow:
                                            TextOverflow
                                                .ellipsis,
                                            maxLines:item.getAddOnList()?.isEmpty == true ? 1: 2,
                                          )),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                              '\$${itemTotalPrice}',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight:
                                                  FontWeight
                                                      .w600)),
                                          item.getAddOnList()?.isEmpty == true ?
                                              SizedBox():
                                          Text(
                                              '+\$${addOnTotalPrice}',
                                              style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors
                                                      .grey[600])),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize:
                                    MainAxisSize.max,
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
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
                                              size: 22,
                                              color:
                                              AppColor.SECONDARY,
                                            ),
                                            onTap: onMinusTap,
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          Text(
                                            "${item.quantity.toString()}",
                                            style: TextStyle(
                                                fontSize:
                                                13,
                                                fontWeight:
                                                FontWeight
                                                    .bold),
                                          ),
                                          SizedBox(
                                            width: 4,
                                          ),
                                          GestureDetector(
                                            child: Icon(
                                              Icons
                                                  .add_circle_outlined,
                                              size: 22,
                                              color:
                                              AppColor.SECONDARY,
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
                      /*productSize.isNotEmpty
                                          ? Container(
                                              width: screenWidth * 0.48,
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
                                                          width: screenWidth *
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
                                                                                screenWidth * 0.173),
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  String addOns(ProductData item){
    String text ="Add Ons: ";
    item.getAddOnList().forEach((category){
      if(category.addOnCategoryType == "multiple") {
        category.addOns?.forEach((addOn) {
          text = text + capitalizeFirstLetter("+${addOn.name} ");
        });
      }
      else {
        category.addOns?.forEach((addOn) {
            text = text + capitalizeFirstLetter("+${addOn.name} ");

        });
      }
    });
    return text;
  }
}


