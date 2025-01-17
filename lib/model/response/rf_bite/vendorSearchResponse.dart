
import 'dart:convert';

import 'package:ChaatBar/model/response/rf_bite/productListResponse.dart';
import 'package:ChaatBar/model/response/rf_bite/vendorListResponse.dart';


class VendorSearchResponse {
  List<ProductData>? data;
  String? message;
  int? status;

  VendorSearchResponse({
    this.message,
    this.data,
    this.status,
  });

  factory VendorSearchResponse.fromJson(Map<String, dynamic> json) {

    var list = json['data'] as List;
    List<ProductData>? dataList = list?.map((i) => ProductData.fromJson(i)).toList();

    return VendorSearchResponse(
      data: dataList,
      message: json["message"] as String?,
      status: json["status"] as int?,
    );

  }
}

