class GetCouponDetailsRequest {
  String couponCode;
  int? vendorId;

  GetCouponDetailsRequest({
    required this.couponCode,
    required this.vendorId
  });

  Map<String, dynamic> toJson() {
    return {
      'coupon_code': couponCode, // Convert the customer object to JSON
      'vendor_id': vendorId, // Convert the customer object to JSON
    };
  }
}

