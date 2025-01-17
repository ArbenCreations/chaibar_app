import 'dart:async';

import 'package:ChaatBar/model/db/dao.dart';
import 'package:ChaatBar/model/response/rf_bite/dashboardDataResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/productDataDB.dart';
import 'package:ChaatBar/model/response/rf_bite/productListResponse.dart';
import 'package:ChaatBar/utils/Helper.dart';
import 'package:ChaatBar/view/component/dashboard_category_component.dart';
import 'package:ChaatBar/view/component/dashboard_search_component.dart';
import 'package:ChaatBar/view/component/featured_product_component.dart';
import 'package:ChaatBar/view/component/no_item_available.dart';
import 'package:ChaatBar/view/component/product_component.dart';
import 'package:ChaatBar/view/component/toastMessage.dart';
import 'package:ChaatBar/view/screens/ChaatBar/vendor_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../languageSection/Languages.dart';
import '../../../model/apis/api_response.dart';
import '../../../model/db/ChaatBarDatabase.dart';
import '../../../model/request/markFavoriteRequest.dart';
import '../../../model/response/rf_bite/bannerListResponse.dart';
import '../../../model/response/rf_bite/categoryDataDB.dart';
import '../../../model/response/rf_bite/categoryListResponse.dart';
import '../../../model/response/rf_bite/favoriteListResponse.dart';
import '../../../model/response/rf_bite/markFavoriteResponse.dart';
import '../../../model/response/rf_bite/storeStatusResponse.dart';
import '../../../model/response/rf_bite/vendorListResponse.dart';
import '../../../theme/AppColor.dart';
import '../../../utils/Util.dart';
import '../../../view_model/main_view_model.dart';
import '../../component/circluar_profile_image.dart';
import '../../component/connectivity_service.dart';
import '../../component/my_navigator_observer.dart';
import '../../component/product_shimmer.dart';
import '../../component/promotion_offers_widget.dart';
import '../../component/shimmer_card.dart';
import '../../component/view_cart_container.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late double screenWidth;
  late double screenHeight;
  bool isDarkMode = false;
  late List<CategoryData> categories = [];
  late List<ProductData> featuredProduct = [];
  late List<ProductData> favoriteProducts = [];
  late List<ProductData> menuItems = [];
  List<ProductData> cart = [];
  List<ProductData> cartDBList = [];
  List<BannerData> bannerList = [];
  late ChaatBarDatabase database;
  late CartDataDao cartDataDao;
  late FavoritesDataDao favoritesDataDao;
  late CategoryDataDao categoryDataDao;
  late ProductsDataDao productsDataDao;
  late DashboardDao dashboardDao;
  int cartItemCount = 0;
  int customerId = 0;
  late int vendorId;
  VendorData? vendorData = VendorData();

  String selectedCategory = "";
  CategoryData? selectedCategoryDetail = CategoryData();

  bool isProductAvailable = true;
  bool isLoading = false;
  bool isProductsLoading = false;
  bool isBannerLoading = false;
  bool isFeaturedProductsLoading = false;
  bool isFavoriteProductsLoading = false;
  bool isMarkFavLoading = false;
  bool isCategoryLoading = true;
  bool isInternetConnected = true;
  bool isStoreOnline = true;
  bool _isVisible = false;
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  final TextEditingController queryController = TextEditingController();
  late AnimationController _controller;

  Color primaryColor = AppColor.PRIMARY;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];

  AnimationController? _animationController;
  Animation<Offset>? _animation;

  final List<String> hintTexts = [
    'Search "Pizza"',
    'Search "Burger"',
    'Search "Beverages"',
    'Search "Cold Coffee"',
    'Search "Noodles"',
    'Search "Wrap"',
    'Search "Pasta"',
  ];
  int hintIndex = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    Helper.getVendorDetails().then((onValue) {
      setState(() {
        vendorData = onValue;
        vendorId = int.parse("${onValue?.id}"); //?? VendorData();
      });
      // setThemeColor();
    });
    Helper.getProfileDetails().then((onValue) {
      setState(() {
        customerId = int.parse("${onValue?.id}"); //?? VendorData();
      });
      // setThemeColor();
    });
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = Tween<Offset>(begin: Offset(0, -1), end: Offset(0, 0)).animate(
        CurvedAnimation(
            parent: _animationController!, curve: Curves.easeInOut));
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      setState(() {
        hintIndex = (hintIndex + 1) % hintTexts.length;
      });
    });
    initializeDatabase();
    _fetchStoreStatus();
    //_fetchDashboardData();
    /*
    _fetchBannerData();
    _fetchFeaturedData();
    _fetchFavoritesData();*/
  }

  void _toggleContainer() {
    setState(() {
      if (_isVisible) {
        _controller.forward(); // Play the animation forward
      } else {
        _controller.reverse(); // Play the animation in reverse
      }
    });
  }

  @override
  void dispose() {
    _animationController!.dispose();
    _controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final observer = Navigator.of(context)
        .widget
        .observers
        .whereType<MyNavigatorObserver>()
        .first;
    observer.registerCallback('/DashboardScreen', _onReturnToScreen);
  }

  void _onReturnToScreen() {
    // setThemeColor();
    initializeDatabase();
    _fetchDashboardData();
    /*
    _fetchBannerData();
    _fetchFeaturedData();*/
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
          body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
            statusBarColor: AppColor.PRIMARY,
            statusBarIconBrightness: Brightness.light),
        child: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          return Stack(
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        SafeArea(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  children: [
                                    //Header
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: Row(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(right: 10),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                8)),
                                                    color: Colors.transparent),
                                                height: 35,
                                                width: 35,
                                                child:vendorData?.vendorImage == "" || vendorData?.vendorImage == null
                                                    ? Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8),
                                                      color: primaryColor),
                                                  child: Image.asset(
                                                    "assets/pizza_image.jpg",
                                                    height: 35,
                                                    width: 35,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                                    :ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    "${vendorData?.vendorImage}",
                                                    height: 35,
                                                    width: 35,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (BuildContext context,
                                                        Object exception, StackTrace? stackTrace) {
                                                      return Container(
                                                        child: Image.asset(
                                                          "assets/pizza_image.jpg",
                                                          height: 35,
                                                          width: 35,
                                                          fit: BoxFit.cover,
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
                                                            height: 35,
                                                            width: 35,
                                                            color: Colors.white,
                                                          ),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                )
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                capitalizeFirstLetter(
                                                    '${vendorData?.businessName}'),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              Text(
                                                isStoreOnline
                                                    ? "Online"
                                                    : "Offline",
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: isStoreOnline
                                                        ? AppColor.PRIMARY
                                                        : Colors.red),
                                              )
                                            ],
                                          ),
                                          Spacer(),
                                          GestureDetector(
                                            onTap: () {
                                              //Helper.clearAllSharedPreferences();
                                              Helper.saveVendorData(
                                                  VendorData());
                                              database.favoritesDao
                                                  .clearAllFavoritesProduct();
                                              database.cartDao
                                                  .clearAllCartProduct();
                                              database.categoryDao
                                                  .clearAllCategories();
                                              database.productDao
                                                  .clearAllProducts();
                                              database.dashboardDao
                                                  .clearAllData();
                                              Navigator.pushNamed(context,
                                                  "/VendorLocationScreen",
                                                  arguments: "edit");
                                            },
                                            child: Row(
                                              children: [
                                                //SizedBox(width: 25,),
                                                Icon(
                                                  Icons.location_on_rounded,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  "${capitalizeFirstLetter("${vendorData?.localityName}")}",
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5.0),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    size: 16,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    DashboardSearchComponent(
                                      screenWidth: screenWidth,
                                      screenHeight: screenHeight,
                                      onTap: () {
                                        _showTopSheet();
                                      },
                                      primaryColor: primaryColor,
                                      queryController: queryController,
                                      hintTexts: hintTexts,
                                      hintIndex: hintIndex,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      child: BannerListWidget(
                                        data: bannerList,
                                        isInternetConnected:
                                            isInternetConnected,
                                        isLoading: isBannerLoading,
                                          isDarkMode: isDarkMode
                                      ),
                                    ),
                                    categories.length > 0
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4.0,
                                                          vertical: 4),
                                                      child: Text(
                                                        "Categories",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15),
                                                      ),
                                                    )),
                                                GestureDetector(
                                                  onTap: () {
                                                    VendorData? data =
                                                        vendorData;
                                                    data?.detailType =
                                                        "category";
                                                    Navigator.pushNamed(
                                                        context, "/MenuScreen",
                                                        arguments: data);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        "View All",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Colors.blue),
                                                      ),
                                                      Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          size: 12,
                                                          color: Colors.blue)
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                    Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 12),
                                        alignment: Alignment.center,
                                        constraints: BoxConstraints(
                                            maxWidth: screenWidth,
                                            maxHeight: isCategoryLoading
                                                ? screenHeight * 0.135
                                                : categories.isEmpty
                                                    ? 0
                                                    : 110),
                                        child: isCategoryLoading
                                            ? ListView.builder(
                                                itemCount: 3,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 9, vertical: 2),
                                                itemBuilder: (context, index) {
                                                  return Shimmer.fromColors(
                                                    baseColor: Colors.white38,
                                                    highlightColor: Colors.grey,
                                                    child: Container(
                                                      margin: EdgeInsets.all(6),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(80),
                                                      ),
                                                      height: 50,
                                                      width: 60,
                                                    ),
                                                  );
                                                })
                                            : categories.isEmpty
                                                ? SizedBox()
                                                : DashboardCategoryComponent(
                                                    categories: categories,
                                                    screenWidth: screenWidth,
                                                    screenHeight: screenHeight,
                                                    isDarkMode: isDarkMode,
                                                    primaryColor: primaryColor,
                                                    vendorData: vendorData)),
                                    isFeaturedProductsLoading
                                        ? SizedBox(
                                            height: 18,
                                          )
                                        : featuredProduct.length > 0
                                            ? Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 8),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      4.0),
                                                          child: Text(
                                                            "Featured",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15),
                                                          ),
                                                        )),
                                                    GestureDetector(
                                                      onTap: () {
                                                        VendorData? data =
                                                            vendorData;
                                                        data?.detailType =
                                                            "featured";
                                                        Navigator.pushNamed(
                                                            context,
                                                            "/MenuScreen",
                                                            arguments: data);
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "View All",
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.blue,
                                                            ),
                                                          ),
                                                          Icon(
                                                              Icons
                                                                  .arrow_forward_ios,
                                                              size: 12,
                                                              color:
                                                                  Colors.blue)
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            : SizedBox(),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                  "assets/back.png",
                                                ),
                                                fit: BoxFit.fill,
                                                opacity: 0.8)
                                            /* gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            // Start point of the gradient
                                            end: Alignment.bottomRight,
                                            // End point of the gradient
                                            colors: [
                                              AppColor.PRIMARY,
                                              Color(0xFF116011),
                                            ],
                                          ),*/
                                            ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        width: screenWidth,
                                        child: Column(
                                          children: [
                                            Container(
                                              alignment: Alignment.center,
                                              constraints: BoxConstraints(
                                                  maxWidth: screenWidth,
                                                  maxHeight:
                                                      screenHeight * 0.16),
                                              child: isFeaturedProductsLoading
                                                  ? ListView.builder(
                                                      itemCount: 3,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 9,
                                                              vertical: 2),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return ShimmerCard();
                                                      })
                                                  : ListView.builder(
                                                      itemCount: featuredProduct
                                                          .length,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemBuilder:
                                                          (context, index) {
                                                        return GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                Navigator.pushNamed(
                                                                    context,
                                                                    "/ProductDetailScreen",
                                                                    arguments:
                                                                        featuredProduct[
                                                                            index]);
                                                              });
                                                            },
                                                            child: _buildFeaturedCard(
                                                                featuredProduct[
                                                                    index],
                                                                index + 1));
                                                      },
                                                    ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      child: Column(
                                        children: [
                                          Align(
                                              alignment: Alignment.centerLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: favoriteProducts.length >
                                                        0
                                                    ? Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8.0,
                                                                    vertical:
                                                                        4),
                                                                child: Text(
                                                                  "Favorites",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          15),
                                                                ),
                                                              )),
                                                          GestureDetector(
                                                            onTap: () {
                                                              VendorData? data =
                                                                  vendorData;
                                                              data?.detailType =
                                                                  "favorites";
                                                              Navigator.pushNamed(
                                                                  context,
                                                                  "/MenuScreen",
                                                                  arguments:
                                                                      data);
                                                            },
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  "View All",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .blue),
                                                                ),
                                                                Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    size: 12,
                                                                    color: Colors
                                                                        .blue)
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : SizedBox(),
                                              )),
                                          Container(
                                              //height: screenHeight,
                                              child: isFavoriteProductsLoading
                                                  ? ProductShimmer()
                                                  : isProductAvailable
                                                      ? Padding(
                                                        padding: EdgeInsets.only(bottom: _isVisible ? 52.0 : 0),
                                                        child: Wrap(
                                                            spacing: 10,
                                                            // Horizontal space between items
                                                            runSpacing: 5,
                                                            // Vertical space between lines
                                                            children:
                                                                favoriteProducts
                                                                    .map((item) {
                                                              return GestureDetector(
                                                                  onTap: () {
                                                                    Navigator.pushNamed(
                                                                        context,
                                                                        "/ProductDetailScreen",
                                                                        arguments:
                                                                            item);
                                                                  },
                                                                  child:
                                                                      _buildItemCard(
                                                                          item));
                                                            }).toList()),
                                                      )
                                                      : NoItemAvailable(
                                                          screenHeight:
                                                              screenHeight)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 5,
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
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: ViewCartContainer(
                    cartItemCount: cartItemCount,
                    theme: "${vendorData?.theme}",
                    controller: _controller,
                    primaryColor: primaryColor),
              ),
              isMarkFavLoading
                  ? Stack(
                      children: [
                        // Block interaction
                        ModalBarrier(
                            dismissible: false,
                            color: Colors.black.withOpacity(0.02)),
                        // Loader indicator
                      ],
                    )
                  : SizedBox(),
            ],
          );
        }),
      )),
    );
  }

  Widget _buildItemCard(ProductData item) {
    return ProductComponent(
        item: item,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        showFavIcon : true,
        isDarkMode: isDarkMode,
        onAddTap: () {
          if ((item.productSizesList == "[]" ||
                  item.productSizesList == null) &&
              (item.addOn == "[]" || item.addOn == null) &&
              item.isBuy1Get1 == false) {
            setState(() {
              if (item.quantity <= int.parse("${item.qtyLimit}")) {
                item.quantity++;
                addProductInDb(item);
              }
            });
          } else {
            Navigator.pushNamed(context, "/ProductDetailScreen",
                arguments: item);
          }
        },
        onMinusTap: () {
          if ((item.productSizesList == "[]" ||
                  item.productSizesList == null) &&
              (item.addOn == "[]" || item.addOn == null) &&
              item.isBuy1Get1 == false) {
            setState(() {
              if (item.quantity > 0) {
                item.quantity--;
                deleteCartProductInDb(item);
              }
            });
          } else {
            Navigator.pushNamed(context, "/ProductDetailScreen",
                arguments: item);
          }
        },
        onPlusTap: () {
          if ((item.productSizesList == "[]" ||
                  item.productSizesList == null) &&
              (item.addOn == "[]" || item.addOn == null) &&
              item.isBuy1Get1 == false) {
            setState(() {
              if (item.quantity <= int.parse("${item.qtyLimit}")) {
                item.quantity++;
                addProductInDb(item);
              }
            });
          } else {
            Navigator.pushNamed(context, "/ProductDetailScreen",
                arguments: item);
          }
        },
        onFavoriteTap: () {
          addOrRemoveFavorites(item);
        },
        primaryColor: primaryColor);
  }

  void _fetchCategoryData() async {
    setState(() {
      isLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${Languages.of(context)?.labelNoInternetConnection}'),
            duration: maxDuration,
          ),
        );
      });
    } else {
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .fetchCategoriesList(
              "/api/v1/app/products/get_products", vendorData?.id);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getCategoryList(context, apiResponse);
    }
  }

  void _fetchDashboardData() async {
    setState(() {
      isLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${Languages.of(context)?.labelNoInternetConnection}'),
            duration: maxDuration,
          ),
        );
      });
    } else {
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .fetchDashboardData(
              "/api/v1/app/customers/dashboard_data", vendorData?.id);
      //.fetchCategoriesList("/api/v1/products/${vendorData?.id}/customer_products");
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getDashboardData(context, apiResponse);
    }
  }

  void _setFavorite(int? productId) async {
    setState(() {
      isLoading = true;
      isMarkFavLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${Languages.of(context)?.labelNoInternetConnection}'),
            duration: maxDuration,
          ),
        );
      });
    } else {
      MarkFavoriteRequest request = MarkFavoriteRequest(
          customerId: customerId,
          productId: productId ?? 0,
          vendorId: vendorId);
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .markFavoriteData("/api/v1/app/products/mark_favourites", request);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getMarkFavoriteResponse(context, apiResponse);
    }
  }

  void _removeFavorite(int? productId) async {
    setState(() {
      isLoading = true;
      isMarkFavLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${Languages.of(context)?.labelNoInternetConnection}'),
            duration: maxDuration,
          ),
        );
      });
    } else {
      MarkFavoriteRequest request = MarkFavoriteRequest(customerId: customerId,
          productId: int.parse("${productId}"), vendorId: vendorId);
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .removeFavoriteData(
              "/api/v1/app/products/remove_favourites", request);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getRemoveFavoriteResponse(context, apiResponse);
    }
  }

  void _fetchFavoritesData() async {
    setState(() {
      isLoading = true;
      isFavoriteProductsLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${Languages.of(context)?.labelNoInternetConnection}'),
            duration: maxDuration,
          ),
        );
      });
    } else {
      MarkFavoriteRequest request = MarkFavoriteRequest(vendorId: vendorId);
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .fetchFavoritesProductList(
              "/api/v1/app/products/get_favourites", request);
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getFavoriteProductList(context, apiResponse);
    }
  }

  void _fetchStoreStatus() async {
    setState(() {
      isLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${Languages.of(context)?.labelNoInternetConnection}'),
            duration: maxDuration,
          ),
        );
      });
    } else {
      await Future.delayed(Duration(milliseconds: 2));
      await Provider.of<MainViewModel>(context, listen: false)
          .fetchStoreStatus(
              "/api/v1/vendors/get_store_status?vendor_id=$vendorId");
      ApiResponse apiResponse =
          Provider.of<MainViewModel>(context, listen: false).response;
      getStoreStatusResponse(context, apiResponse);
    }
  }

  Widget getStoreStatusResponse(
      BuildContext context, ApiResponse apiResponse) {
    StoreStatusResponse? storeStatusResponse =
        apiResponse.data as StoreStatusResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        setState(() {
          if(storeStatusResponse?.storeStatus == "offline")
            isStoreOnline = false;
          else if(storeStatusResponse?.storeStatus == "online")
            isStoreOnline = true;
        });
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        return Center(
          child: Text('Please try again later!!!'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }

  Widget getMarkFavoriteResponse(
      BuildContext context, ApiResponse apiResponse) {
    MarkFavoriteResponse? featuredListResponse =
        apiResponse.data as MarkFavoriteResponse?;
    setState(() {
      isLoading = false;
      isMarkFavLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        _fetchFavoritesData();
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        return Center(
          child: Text('Please try again later!!!'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }

  Widget getRemoveFavoriteResponse(
      BuildContext context, ApiResponse apiResponse) {
    MarkFavoriteResponse? featuredListResponse =
        apiResponse.data as MarkFavoriteResponse?;
    setState(() {
      isLoading = false;
      isMarkFavLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        _fetchFavoritesData();
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        return Center(
          child: Text('Please try again later!!!'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }

  Widget getFavoriteProductList(BuildContext context, ApiResponse apiResponse) {
    FavoriteListResponse? favoriteListResponse =
        apiResponse.data as FavoriteListResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        setState(() {
          favoriteProducts = favoriteListResponse?.products ?? [];
          updateQuantity(favoriteProducts);
          isFavoriteProductsLoading = false;
        });
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        return Center(
          child: Text('Please try again later!!!'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }

  Widget getCategoryList(BuildContext context, ApiResponse apiResponse) {
    CategoryListResponse? categoryListResponse =
        apiResponse.data as CategoryListResponse?;
    setState(() {
      isLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        setState(() {
          updateCategoriesDetails(categoryListResponse?.data);
        });
        return Container();
      case Status.ERROR:
        return Center(
          child: Text('Please try again later!!!'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }

  Widget getDashboardData(BuildContext context, ApiResponse apiResponse) {
    DashboardDataResponse? dashboardDataResponse =
        apiResponse.data as DashboardDataResponse?;
    setState(() {
      isLoading = false;
      isFavoriteProductsLoading = false;
      isFeaturedProductsLoading = false;
      isBannerLoading = false;
      isCategoryLoading = false;
    });
    switch (apiResponse.status) {
      case Status.LOADING:
        return Center(child: CircularProgressIndicator());
      case Status.COMPLETED:
        setState(() {
          favoriteProducts =
              dashboardDataResponse?.getFavoritesList() as List<ProductData>;
          updateQuantity(favoriteProducts);

          featuredProduct =
              dashboardDataResponse?.getFeaturedList() as List<ProductData>;
          updateQuantity(featuredProduct);

          bannerList =
              dashboardDataResponse?.getBannerList() as List<BannerData>;

          categories = dashboardDataResponse?.getCategoryList() ?? [];
        });
        updateDashboardDataInDB(dashboardDataResponse);
        return Container();
      case Status.ERROR:
        return Center(
          child: Text('Please try again later!!!'),
        );
      case Status.INITIAL:
      default:
        return Center(
          child: Text(''),
        );
    }
  }

  Future<void> getCartItemCountDB() async {
    List<ProductDataDB?> productsList = await cartDataDao.findAllCartProducts();
    if (mounted) {
      int totalCount = 0;
      if (productsList.isNotEmpty &&
          productsList.length > 0 &&
          productsList != null) {
        // Use forEach instead of map to perform an action
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
    ProductDataDB data = ProductDataDB(
        description: item.description,
        imageUrl: item.imageUrl,
        //addOnIds: [],
        categoryName: item.categoryName,
        //addOnType: item.addOnType,
        deposit: item.deposit,
        price: item.price,
        productCategoryId: item.productCategoryId,
        productId: item.id,
        qtyLimit: item.qtyLimit,
        salePrice: "",
        isBuy1Get1: item.isBuy1Get1,
        shortDescription: item.shortDescription,
        status: item.status,
        title: item.title,
        franchiseId: item.franchiseId,
        vendorId: vendorId,
        quantity: item.quantity,
        vendorName: vendorData?.businessName,
        theme: vendorData?.theme,
        addedToCartAt: "${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
        addOnIdsList: '',
        favorite: item.favorite,
        productSizesList: '');
    print(
        "vendorId ${item.vendorId}  :: productCategoryId  ${item.productCategoryId}  :: id   ${item.id}");
    print("quantity ${item.quantity}");

    getSpecificCartProduct("${vendorId}", "${item.productCategoryId}",
        "${item.id}", cartDataDao, data);
    getCartItemCountDB();
  }

  Future<ProductDataDB?> getSpecificCartProduct(
      String vendorId,
      String categoryId,
      String productId,
      CartDataDao cartDataDao,
      ProductDataDB data) async {
    data.theme = vendorData?.theme;
    data.vendorName = vendorData?.businessName;
    final product = await cartDataDao.getSpecificCartProduct(
        vendorId, categoryId, productId);

    if (product == null) {
      print("Product is null $product");
      List<ProductDataDB?> productsList =
          await cartDataDao.findAllCartProducts();
      print("productsList length: ${productsList.length}");

      print("theme : ${data.theme} :: vendorName : ${data.vendorName} ");
      productsList.add(data);

      if (mounted) {
        if (productsList.isNotEmpty) {
          // Use forEach instead of map to perform an action
          productsList.forEach((item) {
            if (item != null) {
              print("Inserting item: $item");
              if (data.vendorId != item.vendorId) {
                cartDataDao.clearAllCartProduct();
                cartDataDao.insertCartProduct(item);
                ToastComponent.showToast(
                    context: context,
                    message:
                        "Removed items from cart and added latest item because you can only order from one restaurant at once.");
              } else {
                cartDataDao.insertCartProduct(item);
              }
            }
          });
        } else {
          print("Inserting single product: $data");
          cartDataDao.clearAllCartProduct();
          await cartDataDao.insertCartProduct(data);
        }
      }
      getCartItemCountDB();
      return null;
    } else {
      print("Product exists: $product");
      await cartDataDao.updateCartProduct(data); // Update the existing product
    }
    getCartItemCountDB();
    return product;
  }

  void deleteCartProductInDb(ProductData item) {
    ProductDataDB data = ProductDataDB(
        description: item.description,
        imageUrl: item.imageUrl,
        //addOnIds: item.addOnIds,
        categoryName: item.categoryName,
        //addOnType: item.addOnType,
        deposit: item.deposit,
        price: item.price,
        productCategoryId: item.productCategoryId,
        productId: item.id,
        qtyLimit: item.qtyLimit,
        isBuy1Get1: item.isBuy1Get1,
        salePrice: item.salePrice,
        shortDescription: item.shortDescription,
        status: item.status,
        title: item.title,
        franchiseId: item.franchiseId,
        vendorId: vendorId,
        quantity: item.quantity,
        theme: item.theme,
        vendorName: item.vendorName,
        addedToCartAt: "${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
        addOnIdsList: '',
        favorite: item.favorite,
        productSizesList: '');
    if (item.quantity == 0) {
      cartDataDao.deleteCartProduct(data);
    } else {
      cartDataDao.updateCartProduct(data);
    }
    getCartItemCountDB();
  }

  Future<void> initializeDatabase() async {
    database = await $FloorChaatBarDatabase
        .databaseBuilder('basic_structure_database.db')
        .build();

    cartDataDao = database.cartDao;
    favoritesDataDao = database.favoritesDao;
    categoryDataDao = database.categoryDao;
    productsDataDao = database.productDao;
    dashboardDao = database.dashboardDao;

    setState(() {
      isFeaturedProductsLoading = true;
      isBannerLoading = true;
      isFavoriteProductsLoading = true;
    });
    getCartData();
    _fetchCategoryData();
    getDashboardDataDB();
  }

  Future<void> getCartData() async {
    List<ProductDataDB?> productsList = await cartDataDao.findAllCartProducts();

    setState(() {
      List<ProductData> list = [];
      productsList.forEach((item) {
        if (item != null) {
          list.add(ProductData(
              quantity: int.parse("${item.quantity}"),
              vendorId: vendorId,
              franchiseId: item.franchiseId,
              title: item.title,
              status: item.status,
              shortDescription: item.shortDescription,
              salePrice: item.salePrice,
              qtyLimit: item.qtyLimit,
              isBuy1Get1: item.isBuy1Get1,
              productCategoryId: item.productCategoryId,
              price: item.price,
              deposit: item.deposit,
              // addOnType: [],
              categoryName: item.categoryName,
              // addOnIds: [],
              imageUrl: item.imageUrl,
              description: item.description,
              createdAt: "",
              environmentalFee: "",
              featured: false,
              gst: null,
              id: item.productId,
              theme: item.theme,
              vendorName: item.vendorName,
              pst: null,
              updatedAt: "",
              favorite: item.favorite,
              vpt: null,
              addOnIdsList: '',
              productSizesList: ''));
          cartDBList = list;
        }
      });
    });
    updateQuantity(menuItems);
  }

  Future<void> getDashboardDataDB() async {
    try {
      DashboardDataResponse? dashboardData = await dashboardDao.findData();
      if (dashboardData != null) {
        setState(() {
          favoriteProducts = dashboardData.getFavoritesList();
          updateQuantity(favoriteProducts);
          isFavoriteProductsLoading = false;

          featuredProduct = dashboardData.getFeaturedList();
          isFeaturedProductsLoading = false;
          updateQuantity(featuredProduct);

          bannerList = dashboardData.getBannerList();
          isBannerLoading = false;

          isCategoryLoading = false;
          categories = dashboardData.getCategoryList();
        });
        _fetchDashboardData();
      } else {
        setState(() {
          isLoading = true;
          isBannerLoading = true;
          isFeaturedProductsLoading = true;
          isFavoriteProductsLoading = true;
        });
        _fetchDashboardData();
      }
    } catch (e) {
      _fetchDashboardData();
    }
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
        updateQuantity(menuItems);
        isProductsLoading = false;
      });
    } else {
      setState(() {
        isProductAvailable = false;
        menuItems = [];
      });
    }
  }

  Future<void> updateQuantity(List<ProductData> itemList) async {
    itemList.forEach((item) {
      cartDBList.forEach((dbItem) {
        if (item.id == dbItem.id &&
            item.productCategoryId == dbItem.productCategoryId &&
            item.title == dbItem.title) {
          setState(() {
            item.quantity = dbItem.quantity;
          });
        }
      });
    });
    getCartItemCountDB();
  }

  Future<void> updateDashboardDataInDB(DashboardDataResponse? data) async {
    dashboardDao.insertData(data ?? DashboardDataResponse());
    //getDashboardDataDB();
  }

  Future<void> updateCategoriesDetails(List<CategoryData>? categoryList) async {
    if (categoryList?.isNotEmpty == true) {
      List<CategoryDataDB?> localCategoryList =
          await categoryDataDao.findAllCategories();
      if (mounted) {
        for (var categoryData in categoryList ?? []) {
          bool categoryExists = localCategoryList
              .any((localData) => localData?.id == categoryData.id);
          CategoryDataDB data = CategoryDataDB(
            menuImgUrl: categoryData.menuImgUrl,
            categoryImage: categoryData.categoryImage,
            status: categoryData.status,
            categoryName: categoryData.categoryName,
            createdAt: categoryData.createdAt,
            id: categoryData.id,
            updatedAt: categoryData.updatedAt,
            vendorId: vendorId,
            franchiseId: categoryData.vendorId,
          );
          if (!categoryExists) {
            categoryDataDao.insertCategory(data);
          } else {
            categoryDataDao.updateCategory(data);
          }
          updateProductsDetails(categoryData.products);
        }
      }
      for (var localData in localCategoryList) {
        bool? productInNewList = categoryList
            ?.any((categoryData) => categoryData.id == localData?.id);
        if (!(productInNewList == true)) {
          categoryDataDao.deleteCategory(localData ?? CategoryDataDB());
        }
      }
    }
  }

  Future<void> updateProductsDetails(List<ProductData>? productList) async {
    if (productList?.isNotEmpty == true) {
      List<ProductData?> localProductList =
          await productsDataDao.findAllProducts();
      if (mounted) {
        for (var productsData in productList ?? []) {
          bool productExists = localProductList
              .any((localData) => localData?.id == productsData.id);
          if (!productExists) {
            productsData.vendorId = vendorId;
            productsDataDao.insertProduct(productsData);
          } else {
            productsData.vendorId = vendorId;
            productsDataDao.updateProduct(productsData);
          }
        }
      }
      List<ProductData?> localProductListInCategory = await productsDataDao
          .getProductsAccToCategory(productList?[0].productCategoryId ?? 0);
      for (var localData in localProductListInCategory) {
        bool? productInNewList = productList
            ?.any((productsData) => productsData.id == localData?.id);
        if (!(productInNewList == true)) {
          productsDataDao.deleteProduct(localData ?? ProductData(quantity: 0));
        }
      }
    }
    // getProductDataDB("${selectedCategoryDetail?.id}");
  }

  void setThemeColor() {
    if (vendorData?.theme == "blue") {
      setState(() {
        primaryColor = Colors.blue.shade900;
        secondaryColor = Colors.blue[100];
        lightColor = Colors.blue[50];
      });
    }
  }

  Widget _buildFeaturedCard(ProductData data, int index) {
    return FeaturedProductComponent(
      data: data,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      onAddTap: () {
        if ((data.productSizesList == "[]" || data.productSizesList == null) &&
            (data.addOn == "[]" || data.addOn == null) &&
            data.isBuy1Get1 == false) {
          setState(() {
            if (data.quantity <= int.parse("${data.qtyLimit}")) {
              data.quantity++;
              addProductInDb(data);
            }
          });
        } else {
          Navigator.pushNamed(context, "/ProductDetailScreen", arguments: data);
        }
      },
      onMinusTap: () {
        if ((data.productSizesList == "[]" || data.productSizesList == null) &&
            (data.addOn == "[]" || data.addOn == null) &&
            data.isBuy1Get1 == false) {
          setState(() {
            if (data.quantity > 0) {
              data.quantity--;
              deleteCartProductInDb(data);
            }
          });
        } else {
          Navigator.pushNamed(context, "/ProductDetailScreen", arguments: data);
        }
      },
      onPlusTap: () {
        if ((data.productSizesList == "[]" || data.productSizesList == null) &&
            (data.addOn == "[]" || data.addOn == null) &&
            data.isBuy1Get1 == false) {
          setState(() {
            if (data.quantity <= int.parse("${data.qtyLimit}")) {
              data.quantity++;
              addProductInDb(data);
            }
          });
        } else {
          Navigator.pushNamed(context, "/ProductDetailScreen", arguments: data);
        }
      },
      primaryColor: primaryColor,
      index: index,
      isDarkMode: isDarkMode,
    );
  }

  Future<void> addOrRemoveFavorites(ProductData item) async {
    print("item.favorite ${item.favorite}");
    print("item.id ${item.favorite}");
    if (item.favorite == false) {
      _setFavorite(item.id);
    } else {
      _removeFavorite(item.id);
    }
    /*setState(() {

      if (item.favorite == true) {
        favoriteVal = false;
        _setFavorite(favoriteVal, item.id);
      } else {
        favoriteVal = true;
        _setFavorite(favoriteVal, item.id);
      }

    });*/

    /*  FavoritesDataDb data = FavoritesDataDb(
        description: item.description,
        imageUrl: item.imageUrl,
        //addOnIds: [],
        categoryName: item.categoryName,
        //addOnType: item.addOnType,
        deposit: item.deposit,
        price: item.price,
        productCategoryId: item.productCategoryId,
        productId: item.id,
        qtyLimit: item.qtyLimit,
        salePrice: "",
        shortDescription: item.shortDescription,
        status: item.status,
        title: item.title,
        vendorId: item.vendorId,
        quantity: item.quantity,
        vendorName: vendorData.businessName,
        theme: vendorData.theme,
        addedToFavoritesAt:
            "${DateFormat('yyyy-MM-dd').format(DateTime.now())}",
        addOnIdsList: '',
        productSizesList: item.productSizesList);
    final product = await favoritesDataDao.getSpecificFavoritesProduct(
        "${item.vendorId}", "${item.productCategoryId}", "${item.id}");

    if (product == null) {
      List<FavoritesDataDb?> favoritesList =
          await favoritesDataDao.findAllFavoritesProducts();
      favoritesList.add(data);

      if (mounted) {
        if (favoritesList.isNotEmpty) {
          // Use forEach instead of map to perform an action
          favoritesList.forEach((item) {
            if (item != null) {
              print("Inserting item: $item");
              favoritesDataDao.insertFavoritesProduct(item);
            }
          });
        } else {
          print("Inserting single product: $data");
          favoritesDataDao.clearAllFavoritesProduct();
          await favoritesDataDao.insertFavoritesProduct(data);
        }
      }
      return null;
    } else {
      print("Product exists: $product");
      await favoritesDataDao
          .deleteFavoritesProduct(data); // Update the existing product
    }
    return product;*/
  }

  void _showTopSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, animation1, animation2, widget) {
        return SlideTransition(
          position: _animation!,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: isDarkMode
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark,
            child: Align(
              alignment: Alignment.topCenter,
              child: Material(
                elevation: 10,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
                child: Container(
                  height: 200, // Top sheet height
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                                queryController.text = "";
                              },
                              child: Icon(Icons.arrow_back_rounded)),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            'Search for dishes ',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: TextField(
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                          obscureText: false,
                          obscuringCharacter: "*",
                          autofocus: true,
                          controller: queryController,
                          onChanged: (value) async {
                            if (queryController.text.length >= 4) {
                              print("queryController${queryController.text}");
                              showSearch(
                                context: context,
                                delegate: VendorSearchDelegate(
                                    initialQuery: queryController.text,
                                    isDarkMode: isDarkMode),
                              );
                            }
                          },
                          onSubmitted: (value) {},
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: AppColor.PRIMARY, width: 0.8)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: AppColor.PRIMARY, width: 0.7)),
                            hintText: "Search..",
                            suffixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      pageBuilder: (context, animation1, animation2) => Container(),
    );
    _animationController!.forward();
  }
}
