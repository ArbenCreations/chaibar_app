import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '/model/db/dataBaseDao.dart';
import '/model/response/productDataDB.dart';
import '/model/response/productListResponse.dart';
import '/utils/Helper.dart';
import '/utils/Util.dart';
import '../../../language/Languages.dart';
import '../../../model/db/db_service.dart';
import '../../../model/request/itemReviewRequest.dart';
import '../../../model/response/itemReviewResponse.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../theme/CustomAppColor.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomAlert.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/custom_circular_progress.dart';
import '../../component/session_expired_dialog.dart';
import '../../component/view_cart_container.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductData? data;

  ProductDetailScreen({Key? key, this.data}) : super(key: key);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late double mediaWidth;
  late double screenHeight;
  late bool isDarkMode;
  bool isProductAvailable = true;
  late List<ProductData> menuItems = [];
  late CartDataDao cartDataDao;
  late ProductsDataDao productsDataDao;
  int cartItemCount = 0;
  late int vendorId;
  List<ProductData> cartDBList = [];
  List<ProductData> cart = [];
  List<ProductSize> productSizeList = [];
  List<AddOnCategory> addOnList = [];
  List<AddOnCategory> cartAddOnList = [];
  List<AddOnDetails> addOnDetails = [];
  ProductData? selectedProduct;
  bool isLoading = false;
  bool? isVoteUp = false;
  bool? isVoteDown = false;
  bool _isVisible = false;
  late AnimationController _controller;
  late MainViewModel _mainViewModel;
  Color primaryColor = CustomAppColor.Primary;
  List<bool> checkedStates = [];

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      selectedProduct = widget.data!;
    }
    Helper.getVendorDetails().then((onValue) {
      setState(() {
        vendorId = int.parse("${onValue?.id}");
      });
    });

    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    initializeDatabase();
     setState(() {
      productSizeList = selectedProduct?.getProductSizeList() ?? [];
      checkedStates = List<bool>.filled(productSizeList.length, false);
      addOnList = selectedProduct?.getAddOnList() ?? [];
      addOnList.isNotEmpty
          ? selectedProduct?.addOnIdsList =
              jsonEncode(["${addOnList[0].addOns?[0].id}"])
          : SizedBox();
      addOnList.isNotEmpty
          ? selectedProduct?.addOnType = addOnList[0].addOnCategoryType
          : SizedBox();
      if (selectedProduct!.userVote != null && selectedProduct!.userVote! == "upvote") {
        isVoteUp = true;
      } else if (selectedProduct!.userVote != null &&
          selectedProduct!.userVote! == "downvote") {
        isVoteDown = true;
      }
    });
    addOnList.isNotEmpty
        ? cartDataDao
            .getMatchingCartItem(
                selectedProduct!.id.toString(),
                selectedProduct!.addOnType.toString(),
                jsonEncode(["${addOnList[0].addOns?[0].id}"]))
            .then((value) {
            setState(() {
              selectedProduct?.quantity = value?.quantity ?? 0;
            });
          })
        : SizedBox();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainViewModel = Provider.of<MainViewModel>(context, listen: false);
  }

  void _toggleContainer() {
    setState(() {
      if (_isVisible) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    mediaWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: false, // Disable back navigation on this page
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        // Navigate to the home view when back navigation is attempted
        Navigator.pushReplacementNamed(context, "/BottomNavigation",
            arguments: 1);
      },
      child: Scaffold(body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      //Image Detail Section
                      imageDetailSection(),

                      SafeArea(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FloatingActionButton(
                              mini: true,
                              shape: CircleBorder(),
                              elevation: 0,
                              backgroundColor: Colors.white,
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, "/BottomNavigation",
                                    arguments: 1);
                              },
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                                color: CustomAppColor.PrimaryAccent,
                              ),
                            ),
                            selectedProduct?.featured == true
                                ? Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
                                    margin: EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.green,
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        "Popular",
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.white),
                                      ),
                                    ),
                                  )
                                : SizedBox(),
                          ],
                        ),
                      ),

                      selectedProduct?.upvote_percentage == "null"
                          ? Positioned(
                              bottom: 6,
                              right: 8,
                              child: Column(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4),
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
                                              Icon(Icons.thumb_up, size: 14),
                                              SizedBox(width: 2),
                                              Text(
                                                  "${selectedProduct?.upvote_percentage ?? 0}%",
                                                  style:
                                                      TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                            )
                          : SizedBox(),
                    ],
                  ),
                  SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? CustomAppColor.DarkCardColor
                            : Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight * 0.8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 2.5,
                              width: 100,
                              margin: EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                  color: CustomAppColor.PrimaryAccent,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30))),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 18.0, right: 18, top: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Product Detail Section
                                  productDetailSection(),

                                  SizedBox(
                                    height: 20,
                                  ),

                                  //Add On Section
                                  addOnSection(),
                                ],
                              ),
                            ),
                            Container(
                              height: 0.3,
                              width: mediaWidth * 0.6,
                              color: Colors.grey,
                              margin: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ViewCartContainer(
                  cartItemCount: cartItemCount,
                  theme: "${selectedProduct?.theme}",
                  controller: _controller,
                  primaryColor: primaryColor),
            ),
            isLoading ? CustomCircularProgress() : SizedBox(),
          ],
        );
      })),
    );
  }

  Widget multipleAddOns(AddOnCategory result) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Wrap(
          spacing: 5,
          // Horizontal space between items
          children: List.generate(result.addOns?.length ?? 0, (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        capitalizeFirstLetter("${result.addOnCategory}")
                                    .contains("Tea") ||
                                capitalizeFirstLetter("${result.addOnCategory}")
                                    .contains("Select Size")
                            ? Image(
                                image: AssetImage("assets/glassIcon.png"),
                                width: 25,
                              )
                            : SizedBox(),
                        Text(
                            capitalizeFirstLetter(
                                '${result.addOns?[index].name}'),
                            style: TextStyle(
                              fontSize: 15,
                            )),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          capitalizeFirstLetter(
                              '(+\$${result.addOns?[index].price})'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    Checkbox(
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      side: BorderSide(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      visualDensity:
                          VisualDensity(vertical: -4, horizontal: -4),
                      value: result.addOns?[index].isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          result.addOns?[index].isSelected = value ?? false;
                          selectedProduct?.addOn = jsonEncode(addOnList);
                          getProductDataObject(selectedProduct!, vendorId);
                        });
                      },
                    ),
                  ]),
            );
          }).toList(),
        ));
  }

  Widget singleAddOns(AddOnCategory result) {
    return Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Wrap(
          spacing: 5,
          children: List.generate(result.addOns?.length ?? 0, (index) {
            return RadioListTile<int>(
              dense: true,
              controlAffinity: ListTileControlAffinity.trailing,
              autofocus: true,
              visualDensity: VisualDensity(vertical: -4, horizontal: -4),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  capitalizeFirstLetter("${result.addOnCategory}") == "Tea"
                      ? Image(
                          image: AssetImage("assets/glassIcon.png"),
                          width: 25,
                        )
                      : SizedBox(),
                  Text(
                    capitalizeFirstLetter("${result.addOns?[index].name}"),
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Text(
                    capitalizeFirstLetter(
                        '(+\$${result.addOns?[index].price})'),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  )
                ],
              ),
              value: int.parse("${result.addOns?[index].id}"),
              groupValue: result.selectedAddOnIdInSingleType,
              onChanged: (int? newValue) {
                setState(() {
                  result.selectedAddOnIdInSingleType = newValue;
                  selectedProduct?.addOn = jsonEncode(addOnList);

                  selectedProduct?.addOnIdsList = jsonEncode(["$newValue"]);

                  cartDataDao
                      .getMatchingCartItem(
                          selectedProduct!.id.toString(),
                          selectedProduct!.addOnType.toString(),
                          jsonEncode(["$newValue"]))
                      .then((value) {
                    setState(() {
                      selectedProduct?.quantity = value?.quantity ?? 0;
                    });
                  });
                });
              },
            );
          }).toList(),
        ));
  }

  Widget addOnSection() {
    return Column(
      children: [
        addOnList.isNotEmpty
            ? Row(
                children: [
                  Text(
                    "Add Extra Additional",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: CustomAppColor.PrimaryAccent),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                ],
              )
            : SizedBox(),
        Wrap(
          spacing: 6,
          runSpacing: 5,
          children: addOnList.map((result) {
            return Container(
              margin: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          capitalizeFirstLetter("${result.addOnCategory}"),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(width: 5),
                        Text(
                          result.addOnCategoryType == "multiple"
                              ? "Select 1 or more add ons"
                              : "Select any 1 add on",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.grey[400],
                              color: Colors.grey[600]),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 0.2, color: Colors.black54)),
                    child: result.addOnCategoryType == "multiple"
                        ? multipleAddOns(result)
                        : singleAddOns(result),
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget productDetailSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IntrinsicWidth(
                  child: Text(
                    capitalizeFirstLetter("${selectedProduct?.title}"),
                    maxLines: 2,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: selectedProduct?.quantity == 0
                                ? Colors.grey
                                : CustomAppColor.PrimaryAccent,
                            width: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(100)),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.remove,
                          size: 20,
                          color: selectedProduct?.quantity == 0
                              ? Colors.grey
                              : CustomAppColor.PrimaryAccent,
                        ),
                      ),
                    ),
                    onTap: () {
                      _handleRemoveToCart();
                    },
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "${selectedProduct?.quantity}",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  GestureDetector(
                    child: Card(
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: CustomAppColor.PrimaryAccent,
                            width: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(100)),
                      color: CustomAppColor.PrimaryAccent,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.add,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onTap: () {
                      _handleAddToCart();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "\$${selectedProduct?.price}",
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: CustomAppColor.PrimaryAccent),
            ),
            selectedProduct?.featured == false
                ? Row(
                    children: [
                      GestureDetector(
                          onTap: () {
                            _onItemReviewPressed(true, widget.data?.id);
                          },
                          child: Row(
                            children: [
                              Icon(
                                isVoteUp == true
                                    ? Icons.thumb_up
                                    : Icons.thumb_up_alt_outlined,
                                size: 20,
                              ),
                            ],
                          )),
                      SizedBox(width: 5),
                      GestureDetector(
                          onTap: () {
                            _onItemReviewPressed(false, widget.data?.id);
                          },
                          child: Row(
                            children: [
                              Icon(
                                isVoteDown == true
                                    ? Icons.thumb_down
                                    : Icons.thumb_down_alt_outlined,
                                size: 20,
                              ),
                            ],
                          ))
                    ],
                  )
                : SizedBox(),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizeFirstLetter(
                            "${selectedProduct?.shortDescription}"),
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey[800]),
                        overflow: TextOverflow.visible,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        capitalizeFirstLetter(
                            "${selectedProduct?.description}"),
                        style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.7)
                                : Colors.grey[500]),
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget imageDetailSection() {
    return selectedProduct?.imageUrl == "" || selectedProduct?.imageUrl == null
        ? Container(
            decoration: BoxDecoration(color: primaryColor),
            child: Image.asset(
              "assets/app_logo.png",
              height: screenHeight * 0.4,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ClipRRect(
              child: CachedNetworkImage(
                imageUrl: selectedProduct?.imageUrl ?? "",
                height: screenHeight * 0.4,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.white38,
                  highlightColor: Colors.grey,
                  child: Container(
                    height: screenHeight * 0.55,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  child: Image.asset(
                    "assets/app_logo.png",
                    height: screenHeight * 0.55,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
          );
  }

  void _updateCart(ProductData item) {
    if (item.quantity > 0) {
      if (!cart.contains(item) &&
          item.quantity <= int.parse("${item.qtyLimit}")) {
        setState(() {
          cart.add(item);
        });
      }
    } else {
      setState(() {
        cart.remove(item);
      });
    }
  }

  Future<void> getCartItemCountDB() async {
    List<ProductDataDB?> productsList = await cartDataDao.findAllCartProducts();
    if (mounted) {
      int totalCount = 0;
      if (productsList != null &&
          productsList.isNotEmpty &&
          productsList.length > 0) {
        productsList.forEach((item) {
          if (item != null) {
            totalCount = totalCount + int.parse("${item.quantity}");
          }
        });
        setState(() {
          cartItemCount = totalCount;
          if (cartItemCount == 0) {
            _isVisible = false;
          } else {
            _isVisible = true;
          }
          _toggleContainer();
        });
      } else {
        setState(() {
          cartItemCount = 0;
          if (cartItemCount == 0) {
            _isVisible = false;
          } else {
            _isVisible = true;
          }
          _toggleContainer();
        });
      }
    } else {
      setState(() {
        cartItemCount = 0;
        if (cartItemCount == 0) {
          _isVisible = false;
        } else {
          _isVisible = true;
        }
        _toggleContainer();
      });
    }
  }

  Future<void> addProductInDb(ProductData item) async {
    ProductDataDB data = getProductDataObject(item, vendorId);

    getSpecificCartProduct("${vendorId}", "${item.productCategoryId}",
        "${item.id}", cartDataDao, data);
    getCartItemCountDB();
  }

  Future<ProductDataDB?> getSpecificCartProduct(
      String vendorId,
      String categoryId,
      String productId,
      CartDataDao cartDataDao,
    ProductDataDB data,
  ) async {
    data.theme = selectedProduct?.theme;
    data.vendorName = selectedProduct?.vendorName;
    List<dynamic> currentAddOns = [];
    if (data.addOnIdsList != null && data.addOnIdsList!.isNotEmpty) {
      currentAddOns = jsonDecode(data.addOnIdsList!);
    }

    List<ProductDataDB?> productsList = await cartDataDao.findAllCartProducts();

    ProductDataDB? matchingProduct = productsList.firstWhere(
      (item) {
        if (item == null) return false;

        List<dynamic> existingAddOns = [];
        if (item.addOnIdsList != null && item.addOnIdsList!.isNotEmpty) {
          existingAddOns = jsonDecode(item.addOnIdsList!);
        }

        return item.vendorId == vendorId &&
            item.productCategoryId == categoryId &&
            item.productId == productId &&
            item.addOnType == data.addOnType &&
            listEquals(existingAddOns, currentAddOns);
      },
      orElse: () => null,
    );

    if (matchingProduct != null) {
      setState(() {
        data.quantity =
            selectedProduct?.quantity == 0 ? 1 : selectedProduct!.quantity + 1;
        selectedProduct?.quantity =
            selectedProduct?.quantity == 0 ? 1 : selectedProduct!.quantity + 1;
      });

      await cartDataDao.updateCartProduct(data);
      getCartItemCountDB();
      return matchingProduct;
    }

    bool isDifferentVendor = productsList
        .any((item) => item != null && item.vendorId != data.vendorId);
    if (mounted) {
      if (isDifferentVendor) {
        await cartDataDao.clearAllCartProduct();
        CustomAlert.showToast(
          context: context,
          message:
              "Removed items from cart and added latest item because you can only order from one restaurant at once.",
        );
      }
      setState(() {
        data.quantity =
            selectedProduct?.quantity == 0 ? 1 : selectedProduct!.quantity + 1;
        selectedProduct?.quantity =
            selectedProduct?.quantity == 0 ? 1 : selectedProduct!.quantity + 1;
      });
      await cartDataDao.insertCartProduct(data);
    }
    getCartItemCountDB();
    return null;
  }

  void deleteProductInDb(ProductData item) {
    ProductDataDB data = getProductDataObject(item, vendorId);
    if (item.quantity == 0) {
      cartDataDao.deleteCartProduct(data);
    } else {
      cartDataDao.updateCartProduct(data);
    }
    getCartItemCountDB();
  }

  Future<void> initializeDatabase() async {
    productsDataDao = DBService.instance.productDao;
    cartDataDao = DBService.instance.cartDao;
    getProductDataDB("${selectedProduct?.productCategoryId}");
  }

  Future<void> getCartData() async {
    List<ProductDataDB?> productsList = await cartDataDao.findAllCartProducts();
    List<ProductData> list = [];

    for (var item in productsList) {
      if (item != null) {
        list.add(getCartDataObject(item, vendorId));
      }
    }

    setState(() {
      cartDBList = list;

      cartAddOnList = cartDBList.expand((cart) => cart.getAddOnList()).toList();

      cartAddOnList.forEach((item) {
        if (item.addOnCategoryType == "single") {
          item.selectedAddOnIdInSingleType = item.addOns?.first.id;
        } else {
          item.addOns?.forEach((addOn) {
            addOnDetails.add(addOn);
          });
        }
      });

      addOnList.forEach((item) {
        if (item.addOnCategoryType == "single") {
          // Assume: selectedProduct.addOnIdsList is stored as a JSON string like "[3,5,7]"
          if (cartAddOnList.isNotEmpty &&
              selectedProduct?.addOnIdsList != null) {
            final Set<int> savedIds =
                (jsonDecode(selectedProduct!.addOnIdsList!) as List<dynamic>)
                    .map((e) => int.parse(e.toString()))
                    .toSet();

            for (final cartAddOn in cartAddOnList) {
              final int? id = cartAddOn.selectedAddOnIdInSingleType;

              // ✅ Check for match with saved add-on IDs
              final bool isMatch = id != null && savedIds.contains(id);
              // cartAddOn.isSelected = isMatch;
              print("hasAnyMatch $isMatch");
              // ✅ Only assign item.selectedAddOnIdInSingleType if matched
              if (isMatch) {
                item.selectedAddOnIdInSingleType = cartAddOn.addOns?.first.id;
              }else{
                item.selectedAddOnIdInSingleType = addOnList[0].addOns?.first.id;
              }
            }
          } else {
            item.selectedAddOnIdInSingleType = addOnList[0].addOns?.first.id;
          }
        } else {
          if (item.addOns != null && item.addOns!.isNotEmpty) {
            final hasCartAddOns = cartAddOnList.isNotEmpty;

            bool hasAnyMatch = false;

            for (var addOn in item.addOns!) {
              if (hasCartAddOns) {
                addOnDetails.clear();
                final isMatch = addOnDetails.any((cartAddOn) => cartAddOn.id == addOn.id);
                addOn.isSelected = isMatch;
                if (isMatch) hasAnyMatch = true;
              } else {
                addOn.isSelected = false;
              }
            }

            if (!hasAnyMatch) {
              item.addOns!.first.isSelected = true;
            }
          }
        }
      });
    });

    updateQuantity();
  }

  Future<void> getProductDataDB(String categoryId) async {
    List<ProductData?> localProductList =
        await productsDataDao.getProductsAccToCategory(int.parse(categoryId));
    if (localProductList.isNotEmpty) {
      setState(() {
        isProductAvailable = true;
        menuItems = [];
        menuItems.addAll(
            localProductList.where((item) => item != null).cast<ProductData>());
        getCartData();
      });
    } else {
      setState(() {
        isProductAvailable = false;
        menuItems = [];
      });
    }
  }

  Future<void> updateQuantity() async {
    outerLoop:
    for (var item in menuItems) {
      for (var dbItem in cartDBList) {
        if (item.id == dbItem.id &&
            item.productCategoryId == dbItem.productCategoryId &&
            dbItem.vendorId == vendorId &&
            item.addOnIdsList == dbItem.addOnIdsList &&
            selectedProduct?.title == dbItem.title) {
          setState(() {
            selectedProduct?.quantity = dbItem.quantity;
          });

          break outerLoop;
        }
      }
    }

    getCartItemCountDB();
  }

  void _onItemReviewPressed(isLike, itemId) async {
    setState(() {
      isLoading = true;
    });
    ItemReviewRequest request =
        ItemReviewRequest(review: Review(isUpvote: isLike), productId: itemId);

    await _mainViewModel
        .itemReviewRequestApi("api/v1/app/reviews", request);
    ApiResponse apiResponse =
        _mainViewModel.response;
    getItemReviewResponse(context, apiResponse, isLike);
  }

  void getItemReviewResponse(
      BuildContext context, ApiResponse apiResponse, isLike) async
  {
    ItemReviewResponse? response = apiResponse.data as ItemReviewResponse?;
    setState(()
    {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        break;
      case Status.COMPLETED:
        if (isLike) {
          setState(() {
            isVoteUp = true;
            isVoteDown = false;
          });
        } else {
          setState(() {
            isVoteUp = false;
            isVoteDown = true;
          });
        }
        CustomSnackBar.showSnackbar(
            context: context, message: "${response?.message}");
        break;
      case Status.ERROR:
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages.of(context)?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        } else {
          CustomSnackBar.showSnackbar(
              context: context, message: apiResponse.message);
        }
        break;
      case Status.INITIAL:
      default:
        SizedBox();
    }
  }

  void _handleAddToCart() {
    setState(() {
      if (int.parse("${selectedProduct?.quantity}") <
          int.parse("${selectedProduct?.qtyLimit}")) {
        if (selectedProduct?.addOn?.isNotEmpty == true) {
          List<AddOnCategory> addOnCategories = [];
          addOnList.forEach((item) {
            AddOnCategory addOnDetails = AddOnCategory(
                addOnCategory: item.addOnCategory,
                addOnCategoryType: item.addOnCategoryType);
            List<AddOnDetails> selectedAddOns = [];
            List<String> selectedAddOnIdList = [];
            if (item.addOnCategoryType == "multiple") {
              item.addOns?.forEach((addOn) {
                if (addOn.isSelected) {
                  selectedAddOns.add(addOn);
                }
              });
              selectedProduct?.addOnType = "multiple";
            } else {
              item.addOns?.forEach((addOn) {
                if (item.selectedAddOnIdInSingleType == addOn.id) {
                  selectedAddOns.add(addOn);
                  selectedAddOnIdList.add(addOn.id.toString());
                }
              });
              selectedProduct?.addOnType = "single";
            }
            addOnDetails.addOns = selectedAddOns;

            addOnCategories.add(addOnDetails);
          });
          selectedProduct?.addOn = jsonEncode(addOnCategories);
        }
        _updateCart(selectedProduct as ProductData);
        addProductInDb(selectedProduct as ProductData);
      }
    });
  }

  void _handleRemoveToCart() {
    setState(() {
      if (int.parse("${selectedProduct?.quantity}") > 0) {
        if (selectedProduct?.isBuy1Get1 != null &&
            selectedProduct?.isBuy1Get1 == true) {
          selectedProduct?.quantity =
              int.parse("${selectedProduct?.quantity}") - 2;
          _updateCart(selectedProduct as ProductData);
          deleteProductInDb(widget.data as ProductData);
        } else {
          selectedProduct?.quantity--;
          _updateCart(selectedProduct as ProductData);
          deleteProductInDb(widget.data as ProductData);
        }
      }
    });
  }
}
