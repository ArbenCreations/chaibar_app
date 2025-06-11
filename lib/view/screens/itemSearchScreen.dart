import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/language/Languages.dart';
import '/model/request/vendorSearchRequest.dart';
import '/model/response/productListResponse.dart';
import '/model/response/vendorSearchResponse.dart';
import '/theme/CustomAppColor.dart';
import '/utils/Util.dart';
import '/view/component/product_component.dart';
import '../../model/viewModel/mainViewModel.dart';
import '../../utils/Helper.dart';
import '../../utils/apiHandling/api_response.dart';
import '../component/CustomSnackbar.dart';
import '../component/connectivity_service.dart';
import '../component/custom_circular_progress.dart';

class ItemSearchScreen extends SearchDelegate {
  late String initialQuery;
  late bool isDarkMode;

  ItemSearchScreen({
    required this.initialQuery,
    required this.isDarkMode,
  }) {
    print("initialQuery${initialQuery}");
    query = initialQuery; // Set the initial query
  }

  List<ProductData> _productResults = [];
  List<dynamic> _vendorResults = [];
  int vendorId = 0;

  List<dynamic> _searchResults = [];
  final ConnectivityService _connectivityService = ConnectivityService();
  static const maxDuration = Duration(seconds: 2);
  String? _lastQuery;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          FocusScope.of(context).unfocus();
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResultList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Helper.getVendorDetails().then((onValue) {
      vendorId = int.parse("${onValue?.id}");
    });
    if (query.isEmpty) {
      query = initialQuery;
      if (query.isNotEmpty) {
        Future.microtask(() => showSuggestions(context));
        initialQuery = '';
      }
    }

    if (query.isNotEmpty && query.length >= 3) {
      return FutureBuilder<List<dynamic>>(
        future: fetchSearchResults(query, context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomCircularProgress());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No suggestions.'));
          } else {
            _productResults.clear();
            _vendorResults.clear();

            snapshot.data!.forEach((result) {
              if (result != null) {
                ProductData productData = result;
                _productResults.add(productData);
              }
            });

            return _buildSearchResultList(context);
          }
        },
      );
    } else {
      return Center(child: Text('Search'));
    }
  }

  Widget _buildSearchResultList(BuildContext context) {
    print("${_productResults.length}");
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_productResults.isNotEmpty) ...[
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 1.2,
                      color: Colors.grey[300],
                    ),
                    Text(
                      "PRODUCTS",
                      style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                          color: Colors.grey[600]),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: 1.2,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Wrap(
                spacing: 10,
                runSpacing: 5,
                children: _productResults.map(
                  (item) {
                    final product = item;
                    return _buildProductCard(product, context);
                  },
                ).toList(),
              ),
              SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductData result, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: GestureDetector(
        onTap: () {
          hideKeyBoard();
          Future.delayed(Duration(milliseconds: 150), () {
            result.vendorId = vendorId;
            Navigator.pushReplacementNamed(context, "/ProductDetailScreen",
                arguments: result);
          });

        },
        child: ProductComponent(
            item: result,
            isDarkMode: isDarkMode,
            mediaWidth: MediaQuery.of(context).size.width,
            screenHeight: MediaQuery.of(context).size.height,
            showFavIcon: true,
            onAddTap: () {
              jumpToNewPage(context, result);
            },
            onMinusTap: () {
              jumpToNewPage(context, result);
            },
            onPlusTap: () {
              jumpToNewPage(context, result);
            },
            onFavoriteTap: () {
              jumpToNewPage(context, result);
            },
            primaryColor: CustomAppColor.Primary),
      ),
    );
  }

  void jumpToNewPage(BuildContext context, ProductData result) {
    hideKeyBoard();
    Future.delayed(Duration(milliseconds: 150), () {
      result.vendorId = vendorId;
      Navigator.pushReplacementNamed(context, "/ProductDetailScreen",
          arguments: result);
    });
  }
  Future<List<ProductData>> fetchSearchResults(
      String query, BuildContext context) async {
    if (query == _lastQuery) return _productResults;
    _lastQuery = query;
    bool isConnected = await _connectivityService.isConnected();
    if (!isConnected) {
      CustomSnackBar.showSnackbar(context: context, message: '${Languages.of(context)?.labelNoInternetConnection}');
      return [];
    } else {
      final request = VendorSearchRequest(query: query, vendorId: vendorId!);
      final viewModel = Provider.of<MainViewModel>(context, listen: false);
      await viewModel.fetchVendorSearchResults(
        "/api/v1/app/products/search_filter",
        request,
      );

      final apiResponse = viewModel.response;
      return getProductList(context, apiResponse) ?? [];
    }
  }

  List<ProductData>? getProductList(
      BuildContext context, ApiResponse apiResponse) {
    VendorSearchResponse? vendorSearchResponse =
        apiResponse.data as VendorSearchResponse?;
    var message = apiResponse.message.toString();
    switch (apiResponse.status) {
      case Status.LOADING:
        return vendorSearchResponse?.data;
      case Status.COMPLETED:
        return vendorSearchResponse
            ?.data; // Return an empty container as you'll navigate away
      case Status.ERROR:
        return vendorSearchResponse?.data;
      case Status.INITIAL:
      default:
        return vendorSearchResponse?.data;
    }
  }
}
