import 'dart:convert';

import '/model/db/listConverter.dart';
import 'package:floor/floor.dart';

class ProductListResponse {
  List<ProductData>? products;
  String message;
  int status;

  ProductListResponse({
    required this.products,
    required this.message,
    required this.status,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;

    List<ProductData>? productList = list.map((i) => ProductData.fromJson(i))
        .toList();

    return ProductListResponse(
      products: productList,
      message: json["message"] as String,
      status: json["status"] as int,
    );
  }
}

@TypeConverters([ListConverter, ProductSizeListConverter])
@entity
class ProductData {
  @primaryKey
  int? id;
  String? title;

  String? shortDescription;

  String? description;

  int? gst;
  String? createdAt;
  String? updatedAt;
  int? vendorId;
  int? franchiseId;
  double? price;
  int? productCategoryId;
  int? pst;
  int? vpt;
  String? deposit;
  bool? featured;
  bool? status;
  bool? isBuy1Get1;
  bool? favorite;
  String? userVote;
  String? environmentalFee;
  String? addOnIdsList;
  String? salePrice;
  int? qtyLimit;
  String? addOnType;
  String? imageUrl;
  String? addOn;
  String? categoryName;
  int quantity;
  double? upvote_percentage;
  double? downvote_percentage;
  String? vendorName;
  String? theme;
  //String? review;
  String? productSizesList;

  ProductData({
    this.id,
    this.title,
    this.shortDescription,
    this.description,
    this.gst,
    this.favorite,
    this.userVote,
    this.price,
    this.productCategoryId,
    this.createdAt,
    this.updatedAt,
    this.vendorId,
    this.franchiseId,
    this.isBuy1Get1,
    this.upvote_percentage,
    this.downvote_percentage,
    this.pst,
    this.vpt,
    this.deposit,
    this.environmentalFee,
    this.addOnIdsList,
    this.featured,
    this.status,
    this.salePrice,
    this.qtyLimit,
    this.addOnType,
    this.imageUrl,
    this.addOn,
    this.categoryName,
    this.productSizesList,
    required this.quantity,
    this.vendorName,
    //this.review,
    this.theme,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: json["id"] as int?,
      shortDescription: json["short_description"] as String?,
      description: json["description"] as String?,
      title: json["title"] as String?,
      productCategoryId: json["product_category_id"] as int?,
      gst: json["gst"] as int?,
      createdAt: json["created_at"] as String?,
      updatedAt: json["updated_at"] as String?,
      vendorId: json["vendor"] as int?,
      franchiseId: json["vendor_id"] as int?,
      pst: json["pst"] as int?,
      vpt: json["vpt"] as int?,
      deposit: json["deposit"] as String?,
      environmentalFee: json["environmental_fee"] as String?,
      addOnIdsList: _convertToString(json["add_on_ids"]),
      featured: json["featured"] as bool?,
      favorite: json["favourite"] as bool?,
      userVote: json["user_vote"] as String?,
      isBuy1Get1: json["is_buy_1_get_1"] as bool?,
      price: (json["price"] is int) ? (json["price"] as int).toDouble() : json["price"] as double?,
      upvote_percentage: (json["upvote_percentage"] is int) ? (json["upvote_percentage"] as int).toDouble() : json["upvote_percentage"] as double?,
      downvote_percentage: (json["downvote_percentage"] is int) ? (json["downvote_percentage"] as int).toDouble() : json["downvote_percentage"] as double?,

      status: json["status"] as bool?,
      salePrice: json["sale_price"] as String?,
      qtyLimit: json["qty_limit"] as int?,
      addOnType: json["add_on_type"] as String?,
      addOn: _convertToString(json["add_on"]),
      imageUrl: json["image1"] as String?,
      categoryName: json["category_name"] as String?,
      quantity: 0,
      vendorName: json["vendor_name"] as String?,
      //review: _convertReviewString(json["review"]),
      theme: json["theme"] as String?,
      productSizesList: _convertToString(json['product_sizes']),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = this.id;
    data['short_description'] = this.shortDescription;
    data['description'] = this.description;
    data['title'] = this.title;
    data['product_category_id'] = this.productCategoryId;
    data['price'] = this.price;
    data['gst'] = this.gst;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['vendor'] = this.vendorId;
    data['vendor_id'] = this.franchiseId;
    data['pst'] = this.pst;
    data['vpt'] = this.vpt;
    data['deposit'] = this.deposit;
    data['environmental_fee'] = this.environmentalFee;
    data['add_on_ids'] = this.addOnIdsList;
    data['featured'] = this.featured;
    data['favourite'] = this.favorite;
    data['user_vote'] = this.userVote;
    data['is_buy_1_get_1'] = this.isBuy1Get1;
    data['upvote_percentage'] = this.upvote_percentage;
    data['downvote_percentage'] = this.downvote_percentage;
    data['status'] = this.status;
    data['sale_price'] = this.salePrice;
    data['qty_limit'] = this.qtyLimit;
    data['add_on_type'] = this.addOnType;
    data['add_on'] = this.addOn;
    data['image1'] = this.imageUrl;
    data['category_name'] = this.categoryName;
    data['vendor_name'] = this.vendorName;
    data['theme'] = this.theme;
    data['product_sizes'] = this.productSizesList;
    //data['review'] = this.review;

    return data;
  }


  List<int> getIntList() {
    if (jsonDecode("${addOnIdsList}") != null) {
      return (jsonDecode("${addOnIdsList}") as List<dynamic>).cast<int>();
    } else {
      return [];
    }
  }

  List<ProductSize> getProductSizeList() {
    if (productSizesList?.length != 0) {
      if (jsonDecode("${productSizesList}") != null) {
        final decoded = jsonDecode("${productSizesList}") as List<dynamic>;
        return decoded.map((item) =>
            ProductSize.fromJson(item as Map<String, dynamic>)).toList();
      } else
        return [];
    }
    else
      return [];
  }

/*  ReviewProduct getProductReview() {
    if (review != null && review!.isNotEmpty) {
      final decoded = jsonDecode(review!) as Map<String, dynamic>;
      return ReviewProduct.fromJson(decoded); // ✅ Correct way to convert a Map to Review
    } else {
      return ReviewProduct(); // ✅ Return an empty Review object if null
    }
  }*/

  List<AddOnCategory> getAddOnList() {
    if (addOn?.length != 0) {
      if (jsonDecode("${addOn}") != null) {
        final decoded = jsonDecode("${addOn}") as List<dynamic>;
        return decoded.map((item) =>
            AddOnCategory.fromJson(item as Map<String, dynamic>)).toList();
      } else
        return [];
    }
    else
      return [];
  }

  static String? _convertToString(dynamic value) {
    if (value == null) {
      return '[]'; // Return an empty JSON array as string
    } else if (value is String) {
      return value; // Return as is
    } else if (value is List) {
      return jsonEncode(value); // Convert List to JSON String
    } else {
      throw Exception("Invalid type for intList or productSizeList: ${value
          .runtimeType}. Expected String or List.");
    }
  }

  static String? _convertReviewString(dynamic value) {
    if (value == null) {
      return '{}'; // Return an empty JSON object as a string for single objects like Review
    } else if (value is String) {
      return value; // Return as is if already a JSON string
    } else if (value is Map<String, dynamic>) {
      return jsonEncode(value); // Convert Map (JSON object) to JSON string
    } else {
      throw Exception(
          "Invalid type for Review: ${value.runtimeType}. Expected String or Map.");
    }
  }

}

class ProductSize {
  int quantity;
  String? size;
  String? price;

  ProductSize({
    this.size,
    required this.quantity,
    this.price,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      size: json["size"] as String?,
      quantity: json["quantity"] as int,
      price: json["price"] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['size'] = this.size;
    data['price'] = this.price;
    data['quantity'] = this.quantity;
    return data;
  }
}

class ReviewProduct {
  bool? is_upvote;

  ReviewProduct({
    this.is_upvote,
  });

  factory ReviewProduct.fromJson(Map<String, dynamic> json) {
    return ReviewProduct(
      is_upvote: json["is_upvote"] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['is_upvote'] = this.is_upvote;
    return data;
  }
}

class AddOnCategory {
  String? addOnCategory;
  String? addOnCategoryType;
  int? selectedAddOnIdInSingleType;
  List<AddOnDetails>? addOns;

  AddOnCategory({
    this.addOnCategory,
    this.addOnCategoryType,
    this.selectedAddOnIdInSingleType,
    this.addOns,
  });

  factory AddOnCategory.fromJson(Map<String, dynamic> json) {
    var list = json['addons'] as List?;
    List<AddOnDetails>? addOnList =
    list?.map((i) => AddOnDetails.fromJson(i)).toList();
    return AddOnCategory(
      addOnCategory: json["add_on_category"] as String?,
      addOnCategoryType: json["addon_category_type"] as String?,
      addOns: json['addons'] != null
          ? addOnList
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['add_on_category'] = this.addOnCategory;
    data['addon_category_type'] = this.addOnCategoryType;
    data['addons'] = this.addOns;
    return data;
  }
}

class AddOnDetails {
  int? id;
  String? name;
  String? price;
  bool? status;
  bool isSelected = false;
  String? createdAt;
  String? updatedAt;
  int? addonCategoryId;

  AddOnDetails({
    this.name,
    this.id,
    this.status,
    this.updatedAt,
    this.createdAt,
    required this.isSelected,
    this.addonCategoryId,
    this.price,
  });

  factory AddOnDetails.fromJson(Map<String, dynamic> json) {
    return AddOnDetails(
        name: json["name"] as String?,
        id: json["id"] as int?,
        price: json["price"] as String?,
        status: json["status"] as bool?,
        createdAt: json["created_at"] as String?,
        updatedAt: json["updated_at"] as String?,
        addonCategoryId: json["addon_category_id"] as int?,
        isSelected: false
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['name'] = this.name;
    data['price'] = this.price;
    data['id'] = this.id;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['addon_category_id'] = this.addonCategoryId;
    return data;
  }
}