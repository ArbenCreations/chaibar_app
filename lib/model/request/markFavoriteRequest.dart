class MarkFavoriteRequest {
  int? productId;
  int? customerId;
  int vendorId;

  MarkFavoriteRequest({
     this.productId,
     this.customerId,
    required this.vendorId
  });
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'customer_id': customerId,
      'vendor_id': vendorId
    };
  }
}
