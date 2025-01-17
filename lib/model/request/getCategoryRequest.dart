class GetCategoryRequest {
  int? vendorId;

  GetCategoryRequest({
    required this.vendorId
  });

  Map<String, dynamic> toJson() {
    return {
      'vendor_id': vendorId,
    };
  }
}
