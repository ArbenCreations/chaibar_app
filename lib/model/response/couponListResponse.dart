

import 'package:ChaatBar/model/response/rf_bite/getCouponDetailsResponse.dart';

class CouponListResponse {
  List<PrivateCouponDetailsResponse>? couponsResponse;
  String message;
  int status;

  CouponListResponse({
    required this.couponsResponse,
    required this.message,
    required this.status,
  });

  factory CouponListResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;

    List<PrivateCouponDetailsResponse>? couponResponseList =
        list.map((i) => PrivateCouponDetailsResponse.fromJson(i)).toList();

    return CouponListResponse(
      couponsResponse: couponResponseList,
      message: json["message"] as String,
      status: json["status"] as int,
    );
  }
}


class PrivateCouponDetailsResponse {
  int? discount;
  int? id;
  String? maxDiscountAmt;
  int? maxCouponUse;
  String? minCartAmt;
  bool? maxDisStatus;
  bool? minCartAmountStatus;
  String? createdAt;
  String? updatedAt;
  String? description;
  String? couponCode;
  String? expire_at;
  String? coupon_type;

  PrivateCouponDetailsResponse({
    this.discount,
    this.id,
    this.maxDiscountAmt,
    this.couponCode,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.maxCouponUse,
    this.maxDisStatus,
    this.minCartAmountStatus,
    this.minCartAmt,
    this.expire_at,
    this.coupon_type,
  });

  factory PrivateCouponDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PrivateCouponDetailsResponse(
      discount:json["discount"] as int?,
      id: json["id"] as int?,
      minCartAmt: json["min_cart_amount"] as String?,
      maxCouponUse: json["max_coupon_use"] as int?,
      maxDiscountAmt: json["max_discount_amount"] as String?,
      minCartAmountStatus: json["min_cart_amount_status"] as bool?,
      maxDisStatus: json["max_dis_status"] as bool?,
      updatedAt: json["updated_at"] as String?,
      createdAt: json["created_at"] as String?,
      expire_at: json["expire_at"] as String?,
      description: json["description"] as String?,
      coupon_type: json["coupon_type"] as String?,
      couponCode: json["coupon_code"] as String?,
    );

  }
}
