import 'dart:async';

import 'package:ChaiBar/view/screens/order/vendor_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../component/status_badge_widget.dart';
import '/model/db/dataBaseDao.dart';
import '/model/response/dashboardDataResponse.dart';
import '/model/response/productDataDB.dart';
import '/model/response/productListResponse.dart';
import '/utils/Helper.dart';
import '/view/component/dashboard_category_component.dart';
import '/view/component/dashboard_search_component.dart';
import '/view/component/featured_product_component.dart';
import '/view/component/product_component.dart';
import '../../../../language/Languages.dart';
import '../../../../model/request/markFavoriteRequest.dart';
import '../../../../model/response/bannerListResponse.dart';
import '../../../../model/response/categoryDataDB.dart';
import '../../../../model/response/categoryListResponse.dart';
import '../../../../model/response/favoriteListResponse.dart';
import '../../../../model/response/markFavoriteResponse.dart';
import '../../../../model/response/storeStatusResponse.dart';
import '../../../../model/response/vendorListResponse.dart';
import '../../../../theme/CustomAppColor.dart';
import '../../../../utils/Util.dart';
import '../../../model/db/db_service.dart';
import '../../../model/viewModel/mainViewModel.dart';
import '../../../utils/apiHandling/api_response.dart';
import '../../component/CustomAlert.dart';
import '../../component/CustomSnackbar.dart';
import '../../component/connectivity_service.dart';
import '../../component/my_navigator_observer.dart';
import '../../component/promotion_offers_widget.dart';
import '../../component/session_expired_dialog.dart';
import '../../component/shimmer_card.dart';

class HomeScreen extends StatefulWidget {
  final Function(int?)? onOrderCountFetched;

  const HomeScreen({this.onOrderCountFetched, Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late double mediaWidth;
  late double screenHeight;
  bool isDarkMode = false;
  late List<CategoryData> categories = [];
  late List<ProductData> featuredProduct = [];
  late List<ProductData> favoriteProducts = [];
  late List<ProductData> menuItems = [];
  List<ProductData> cart = [];
  List<ProductData> cartDBList = [];
  List<BannerData> bannerList = [];
  late CartDataDao cartDataDao;
  late FavoritesDataDao favoritesDataDao;
  late CategoryDataDao categoryDataDao;
  late ProductsDataDao productsDataDao;
  late DashboardDao dashboardDao;
  int cartItemCount = 0;
  int customerId = 0;
  late int vendorId;
  VendorData? vendorData = VendorData();
  late MainViewModel _mainViewModel;
  String selectedCategory = "";
  CategoryData? selectedCategoryDetail = CategoryData();

  bool isProductAvailable = true;
  bool isLoading = false;
  bool isProductsLoading = false;
  bool isBannerLoading = false;
  bool isFeaturedProductsLoading = false;
  bool isFavoriteProductsLoading = false;
  bool isMarkFavLoading = false;
  bool isCategoryLoading = false;
  bool isInternetConnected = true;
  bool isStoreOnline = true;
  bool _isVisible = false;
  var _connectivityService = ConnectivityService();
  final TextEditingController queryController = TextEditingController();

  Color primaryColor = CustomAppColor.Primary;
  Color? secondaryColor = Colors.red[100];
  Color? lightColor = Colors.red[50];

  late AnimationController? animationController;
  late AnimationController _controller;
  late AnimationController? _animationController;
  late Animation<Offset>? _animation;

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
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);

    Helper.getVendorDetails().then((onValue) {
      setState(() {
        vendorData = onValue;
        vendorId = int.parse("${onValue?.id ?? 0}");
      });
    });

    Helper.getProfileDetails().then((onValue) {
      setState(() {
        customerId = int.parse("${onValue?.id ?? 0}");
      });
    });

    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _animation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInBack),
    );

    productsDataDao = DBService.instance.productDao;
    cartDataDao = DBService.instance.cartDao;
    favoritesDataDao = DBService.instance.favoritesDao;
    categoryDataDao = DBService.instance.categoryDao;
    dashboardDao = DBService.instance.dashboardDao;

    setState(() {
      isFeaturedProductsLoading = true;
      isBannerLoading = true;
      isFavoriteProductsLoading = true;
    });

    getCartData();
    _fetchCategoryData();
    getDashboardDataDB();
    _fetchStoreStatus();
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
    animationController?.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mainViewModel = Provider.of<MainViewModel>(context, listen: false);
    final observer = Navigator
        .of(context)
        .widget
        .observers
        .whereType<MyNavigatorObserver>()
        .first;
    observer.registerCallback('/HomeScreen', _onReturnToScreen);
  }

  void _onReturnToScreen() {
    setState(() {
      isFeaturedProductsLoading = true;
      isBannerLoading = true;
      isFavoriteProductsLoading = true;
    });
    CustomSnackBar.showSnackbar(context: context, message: "_onReturnToScreen");
    getCartData();
    _fetchCategoryData();
    getDashboardDataDB();

    _fetchDashboardData();
    setThemeColor();
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    mediaWidth = MediaQuery
        .of(context)
        .size
        .width;
    screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        SystemNavigator.pop();
      },
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            systemOverlayStyle:
            SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
          ),
          body: LayoutBuilder(builder:
              (BuildContext context, BoxConstraints viewportConstraints) {
            return Stack(
              children: [
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: CustomAppColor.Background,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(14),
                                  bottomLeft: Radius.circular(14))),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 6),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        StatusBadgeWidget(
                                          status:  isStoreOnline ? "Open" : "Closed",
                                          color: isStoreOnline
                                              ? Colors.green
                                              : Colors.red
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Helper.clearAllSharedPreferences();
                                            Helper.saveVendorData(VendorData());
                                            favoritesDataDao
                                                .clearAllFavoritesProduct();
                                            cartDataDao.clearAllCartProduct();
                                            categoryDataDao
                                                .clearAllCategories();
                                            productsDataDao.clearAllProducts();
                                            dashboardDao.clearAllData();
                                            Navigator.pushNamed(
                                                context, "/VendorsListScreen");
                                          },
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on_rounded,
                                                color: Colors.black54,
                                                size: 14,
                                              ),
                                              SizedBox(
                                                width: 1,
                                              ),
                                              Text(
                                                "${capitalizeFirstLetter(
                                                    "${vendorData
                                                        ?.localityName}")}",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54),
                                              ),
                                              Padding(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 2.0),
                                                child: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: Colors.black54,
                                                  size: 20,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 180,
                                          child: Text(
                                            capitalizeFirstLetter(
                                                '${vendorData?.businessName}'),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                                letterSpacing: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            // color: Colors.white,
                                            shape: BoxShape.circle,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: cartItemCount > 0
                                                      ? CustomAppColor.Primary
                                                      .withOpacity(0.4)
                                                      : Colors.grey.shade300,
                                                  offset: const Offset(0, 1),
                                                  blurRadius: 8.0),
                                            ],
                                          ),
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pushNamed("/MyCartScreen");
                                            },
                                            icon: const Icon(
                                              Icons.shopping_cart,
                                              size: 24,
                                              color:
                                              CustomAppColor.PrimaryAccent,
                                            ),
                                            style: ButtonStyle(
                                                shape: WidgetStatePropertyAll(
                                                    CircleBorder()),
                                                backgroundColor:
                                                WidgetStatePropertyAll(
                                                    Colors.white)),
                                          ),
                                        ),
                                        if (cartItemCount >
                                            0) // Show badge only if cartCount > 0
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 20,
                                                minHeight: 20,
                                              ),
                                              child: Text(
                                                '$cartItemCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              DashboardSearchComponent(
                                mediaWidth: mediaWidth,
                                screenHeight: screenHeight,
                                onTap: () {
                                  _showTopSheet();
                                },
                                primaryColor: primaryColor,
                                queryController: queryController,
                                hintIndex: hintIndex,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: BannerListWidget(
                              data: bannerList,
                              isInternetConnected: isInternetConnected,
                              isLoading: isBannerLoading,
                              isDarkMode: isDarkMode),
                        ),

                        /*     categories.length > 0
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "Categories",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    VendorData? data = vendorData;
                                    data?.detailType = "categories";
                                    Navigator.pushNamed(
                                        context, "/MenuScreen",
                                        arguments: data);
                                  },
                                  child: Text(
                                    "See All",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Colors.green),
                                  ),
                                )
                              ],
                            ),
                          )
                        : SizedBox(),*/
                        SizedBox(height: 10),
                        Container(
                          margin: EdgeInsets.only(left: 5),
                          // No unnecessary margins
                          alignment: Alignment.center,
                          constraints: BoxConstraints(
                            maxWidth: mediaWidth,
                            maxHeight: isCategoryLoading
                                ? screenHeight * 0.15
                                : categories.isEmpty
                                ? 0
                                : 80,
                          ),
                          child: isCategoryLoading
                              ? ListView.builder(
                            itemCount: 3,
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            itemBuilder: (context, index) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                // Softer shimmer base
                                highlightColor: Colors.white70,
                                // Softer shimmer highlight
                                child: Container(
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(
                                        10), // Softer rounded edges
                                  ),
                                  height: 60,
                                  // Increased size for better balance
                                  width: 85,
                                ),
                              );
                            },
                          )
                              : categories.isEmpty
                              ? const SizedBox()
                              : DashboardCategoryComponent(
                            categories: categories,
                            mediaWidth: mediaWidth,
                            screenHeight: screenHeight,
                            isDarkMode: isDarkMode,
                            primaryColor: primaryColor,
                            categoryData: selectedCategoryDetail,
                            onCategoryTap: (categoryData) {
                              if (!isProductsLoading) {
                                getProductDataDB(categoryData);
                              }
                            },
                            vendorData: vendorData,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 12.0, top: 4, bottom: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Products",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  )),
                              GestureDetector(
                                onTap: () {
                                  VendorData? data = vendorData;
                                  data?.detailType = "menu";
                                  Navigator.pushNamed(context, "/MenuScreen",
                                      arguments: data);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "See All",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 5),
                            constraints: BoxConstraints(maxWidth: mediaWidth),
                            child: menuItems.isEmpty
                                ? ListView.builder(
                                itemCount: 1,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 2),
                                itemBuilder: (context, index) {
                                  return ShimmerCard();
                                })
                                : ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: 190),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                // Enables horizontal scrolling
                                itemCount: menuItems.length,
                                itemBuilder: (context, index) {
                                  final int count = menuItems.length > 4
                                      ? 10
                                      : menuItems.length;
                                  final Animation<double> animation =
                                  Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(CurvedAnimation(
                                      parent:
                                      animationController!,
                                      curve: Interval(
                                          (1 / count) * index,
                                          1.0,
                                          curve: Curves
                                              .fastOutSlowIn)));
                                  animationController?.forward();

                                  return AnimatedBuilder(
                                      animation: animationController!,
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                "/ProductDetailScreen",
                                                arguments: menuItems[index],
                                              );
                                            },
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: Transform(
                                                transform: Matrix4
                                                    .translationValues(
                                                    100 *
                                                        (1.0 -
                                                            animation!
                                                                .value),
                                                    0.0,
                                                    0.0),
                                                child: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5),
                                                  // Spacing between items
                                                  child: _buildItemCard(
                                                      menuItems[index]),
                                                ),
                                              ),
                                            ));
                                      });
                                },
                              ),
                            )),
                        featuredProduct.length > 0
                            ? Padding(
                          padding: const EdgeInsets.only(
                              left: 12.0, right: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Suggested For you",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15),
                                  )),
                            ],
                          ),
                        )
                            : SizedBox(),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 5),
                            constraints: BoxConstraints(maxWidth: mediaWidth),
                            child: isFeaturedProductsLoading
                                ? ListView.builder(
                                itemCount: 3,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 2),
                                itemBuilder: (context, index) {
                                  return ShimmerCard();
                                })
                                : SizedBox(
                              height: 190, // Adjust height as needed
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                // Enables horizontal scrolling
                                itemCount: featuredProduct.length,
                                itemBuilder: (context, index) {
                                  final int count =
                                  featuredProduct.length > 4
                                      ? 10
                                      : featuredProduct.length;
                                  final Animation<double> animation =
                                  Tween<double>(begin: 0.0, end: 1.0)
                                      .animate(
                                    CurvedAnimation(
                                      parent: animationController!,
                                      curve: Interval(
                                          (1 / count) * index, 1.0,
                                          curve: Curves.fastOutSlowIn),
                                    ),
                                  );
                                  animationController?.forward();
                                  return AnimatedBuilder(
                                      animation: animationController!,
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                "/ProductDetailScreen",
                                                arguments:
                                                menuItems[index],
                                              );
                                            },
                                            child: FadeTransition(
                                              opacity: animation!,
                                              child: Transform(
                                                  transform: Matrix4
                                                      .translationValues(
                                                      0.0,
                                                      50 *
                                                          (1.0 -
                                                              animation!
                                                                  .value),
                                                      0.0),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        "/ProductDetailScreen",
                                                        arguments:
                                                        featuredProduct[
                                                        index],
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal:
                                                          5),
                                                      // Spacing between items
                                                      child: _buildFeaturedCard(
                                                          featuredProduct[
                                                          index],
                                                          index + 1),
                                                    ),
                                                  )),
                                            ));
                                      });
                                },
                              ),
                            )),
                        SizedBox(
                          height: cartItemCount > 0 ? 110 : 100,
                        )
                      ],
                    ),
                  ),
                ),
                //isLoading ? CustomCircularProgress() : SizedBox()
              ],
            );
          })),
    );
  }


  Widget _buildItemCard(ProductData item) {
    return ProductComponent(
        item: item,
        mediaWidth: mediaWidth,
        screenHeight: screenHeight,
        showFavIcon: true,
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
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages
                .of(context)
                ?.labelNoInternetConnection}');
      });
    } else {
      await Future.delayed(Duration(milliseconds: 2));
      if (mounted) {
        await _mainViewModel.fetchCategoriesList(
            "api/v1/app/products/get_products", vendorData?.id);
        if (mounted) {
          ApiResponse apiResponse = _mainViewModel.response;
          getCategoryList(context, apiResponse);
        }
      }
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
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages
                .of(context)
                ?.labelNoInternetConnection}');
      });
    } else {
      await Future.delayed(Duration(milliseconds: 2));
      if (mounted) {
        await _mainViewModel.fetchDashboardData(
            "/api/v1/app/customers/dashboard_data", vendorData?.id);
        if (mounted) {
          ApiResponse apiResponse = _mainViewModel.response;
          getDashboardData(context, apiResponse);
        }
      }
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
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages
                .of(context)
                ?.labelNoInternetConnection}');
      });
    } else {
      MarkFavoriteRequest request = MarkFavoriteRequest(
          customerId: customerId,
          productId: productId ?? 0,
          vendorId: vendorId);
      await Future.delayed(Duration(milliseconds: 2));
      await _mainViewModel.markFavoriteData(
          "/api/v1/app/products/mark_favourites", request);
      ApiResponse apiResponse = _mainViewModel.response;
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
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages
                .of(context)
                ?.labelNoInternetConnection}');
      });
    } else {
      MarkFavoriteRequest request = MarkFavoriteRequest(
          customerId: customerId,
          productId: int.parse("${productId}"),
          vendorId: vendorId);
      await Future.delayed(Duration(milliseconds: 2));
      await _mainViewModel.removeFavoriteData(
          "/api/v1/app/products/remove_favourites", request);
      ApiResponse apiResponse = _mainViewModel.response;
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
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages
                .of(context)
                ?.labelNoInternetConnection}');
      });
    } else {
      MarkFavoriteRequest request = MarkFavoriteRequest(vendorId: vendorId);
      await Future.delayed(Duration(milliseconds: 2));
      await _mainViewModel.fetchFavoritesProductList(
          "/api/v1/app/products/get_favourites", request);
      ApiResponse apiResponse = _mainViewModel.response;
      getFavoriteProductList(context, apiResponse);
    }
  }

  void _fetchStoreStatus() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });

    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      setState(() {
        isLoading = false;
        CustomSnackBar.showSnackbar(
            context: context,
            message: '${Languages
                .of(context)
                ?.labelNoInternetConnection}');
      });
    } else {
      await _mainViewModel.fetchStoreStatus(
          "api/v1/app/orders/get_store_status?vendor_id=$vendorId");
      if (mounted) {
        ApiResponse apiResponse = _mainViewModel.response;
        getStoreStatusResponse(context, apiResponse);
      }
    }
  }

  Widget getStoreStatusResponse(BuildContext context, ApiResponse apiResponse) {
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
          if (storeStatusResponse?.storeStatus == "offline")
            isStoreOnline = false;
          else if (storeStatusResponse?.storeStatus == "online")
            isStoreOnline = true;
        });
        return Container(); // Return an empty container as you'll navigate away
      case Status.ERROR:
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages
                    .of(context)
                    ?.labelInvalidAccessToken}") ||
            nonCapitalizeString("${apiResponse.message}") ==
                nonCapitalizeString(
                    "${Languages
                        .of(context)
                        ?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        }
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

  Widget getMarkFavoriteResponse(BuildContext context,
      ApiResponse apiResponse) {
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

  Widget getRemoveFavoriteResponse(BuildContext context,
      ApiResponse apiResponse) {
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
          isProductsLoading = true;
          updateCategoriesDetails(categoryListResponse?.data);
        });
        return Container();
      case Status.ERROR:
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages
                    .of(context)
                    ?.labelInvalidAccessToken}")) {
          SessionExpiredDialog.showDialogBox(context: context);
        } else {
          CustomAlert.showToast(context: context, message: apiResponse.message);
        }
        return Center(
          //child: Text('Please try again later!!!'),
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
          Helper.saveActiveOrderCounts(
              dashboardDataResponse?.activeOrderCounts ?? 0);
          if (widget.onOrderCountFetched != null) {
            widget.onOrderCountFetched!(
                dashboardDataResponse?.activeOrderCounts); // Notify parent
          }
          favoriteProducts =
          dashboardDataResponse?.getFavoritesList() as List<ProductData>;
          updateQuantity(favoriteProducts);

          featuredProduct =
          dashboardDataResponse?.getFeaturedList() as List<ProductData>;
          updateQuantity(featuredProduct);

          bannerList =
          dashboardDataResponse?.getBannerList() as List<BannerData>;

          categories = dashboardDataResponse?.getCategoryList() ?? [];
          selectedCategoryDetail?.categoryName == null
              ? selectedCategoryDetail =
          categories.isNotEmpty ? categories.first : null
              : SizedBox();
        });

        updateDashboardDataInDB(dashboardDataResponse);
        return Container();
      case Status.ERROR:
        if (nonCapitalizeString("${apiResponse.message}") ==
            nonCapitalizeString(
                "${Languages
                    .of(context)
                    ?.labelInvalidAccessToken}")) {
          //SessionExpiredDialog.showDialogBox(context: context);
        }
        return SizedBox();
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
        "vendorId ${item.vendorId}  :: productCategoryId  ${item
            .productCategoryId}  :: id   ${item.id}");
    print("quantity ${item.quantity}");

    getSpecificCartProduct("${vendorId}", "${item.productCategoryId}",
        "${item.id}", cartDataDao, data);
    getCartItemCountDB();
  }

  Future<ProductDataDB?> getSpecificCartProduct(String vendorId,
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

      print("vendorName : ${data.vendorName} ");
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
                CustomAlert.showToast(
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

  Future<void> getCartData() async {
    List<ProductDataDB?> productsList =
    await DBService.instance.cartDao.findAllCartProducts();

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
      DashboardDataResponse? dashboardData =
      await DBService.instance.dashboardDao.findData();
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

  Future<void> getProductDataDB(CategoryData? categoryId) async {
    List<ProductData?> localProductList = await productsDataDao
        .getProductsAccToCategory(int.parse(categoryId?.id.toString() ?? "1"));
    if (localProductList.isNotEmpty) {
      setState(() {
        isProductAvailable = true;
        menuItems = [];
        selectedCategoryDetail = categoryId;
        menuItems.addAll(
            localProductList.where((item) => item != null).cast<ProductData>());
        isProductsLoading = false;
      });
      getCartData();
      updateQuantity(menuItems);
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
          updateProductsDetails(categoryData.products, selectedCategoryDetail);
        }
        //selectedCategoryDetail = categoryList?.first;
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

  Future<void> updateProductsDetails(List<ProductData>? productList,
      CategoryData? selectedCategoryDetail) async {
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
    //print("updateProductsDetails :: ${selectedCategoryDetail?.id}");
    if (selectedCategoryDetail != null) {
      getProductDataDB(selectedCategoryDetail);
    }
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
      mediaWidth: mediaWidth,
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
  }

  void _showTopSheet() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation1, animation2) => Container(),
      // Required but unused
      transitionBuilder: (context, animation1, animation2, child) {
        // Combined Slide + Fade animation
        final curvedAnimation = CurvedAnimation(
          parent: animation1,
          curve: Curves.easeOutBack,
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, -1),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: Align(
              alignment: Alignment.topCenter,
              child: Material(
                elevation: 12,
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(25)),
                child: Container(
                  height: 200,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                              queryController.text = "";
                            },
                            child: Icon(Icons.arrow_back_rounded),
                          ),
                          SizedBox(width: 15),
                          Text(
                            'Search for Items',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        height: 40,
                        child: TextField(
                          style: TextStyle(fontSize: 16.0),
                          autofocus: true,
                          controller: queryController,
                          onChanged: (value) {
                            if (value.length >= 4) {
                              showSearch(
                                context: context,
                                delegate: VendorSearchDelegate(
                                  initialQuery: value,
                                  isDarkMode: isDarkMode,
                                ),
                              );
                              queryController.text = "";
                            }
                          },
                          decoration: InputDecoration(
                            hintText: "Search..",
                            suffixIcon: Icon(Icons.search, color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: CustomAppColor.Primary,
                                width: 0.8,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                color: CustomAppColor.Primary,
                                width: 0.7,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}