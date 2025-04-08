
import 'dart:convert';

class CouponDetailsResponse {
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
  String? message;
  String? expire_at;
  String? coupon_type;
  int? status;

  CouponDetailsResponse({
     this.discount,
     this.id,
     this.message,
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
     this.status,
  });

  factory CouponDetailsResponse.fromJson(Map<String, dynamic> json) {
    final data = json["data"];

    return CouponDetailsResponse(
      message: json["message"] as String?,
      status: json["status"] as int?,
      discount: data != null ? data["discount"] as int? : null,
      id: data != null ? data["id"] as int? : null,
      minCartAmt: data != null ? data["min_cart_amount"] as String? : null,
      maxCouponUse: data != null ? data["max_coupon_use"] as int? : null,
      maxDiscountAmt: data != null ? data["max_discount_amount"] as String? : null,
      minCartAmountStatus: data != null ? data["min_cart_amount_status"] as bool? : null,
      maxDisStatus: data != null ? data["max_dis_status"] as bool? : null,
      updatedAt: data != null ? data["updated_at"] as String? : null,
      createdAt: data != null ? data["created_at"] as String? : null,
      expire_at: data != null ? data["expire_at"] as String? : null,
      description: data != null ? data["description"] as String? : null,
      coupon_type: data != null ? data["coupon_type"] as String? : null,
      couponCode: data != null ? data["coupon_code"] as String? : null,
    );
  }
}
