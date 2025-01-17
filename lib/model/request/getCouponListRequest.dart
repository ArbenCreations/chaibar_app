class GetCouponListRequest {
  int? vendorId;

  GetCouponListRequest({
    required this.vendorId,});

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
    };
  }
}
