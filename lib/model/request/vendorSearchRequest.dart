class VendorSearchRequest {
  String query;
  int vendorId;

  VendorSearchRequest({
    required this.query,
    required this.vendorId,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query, // Convert the customer object to JSON
      'vendor_id': vendorId, // Convert the customer object to JSON
    };
  }
}

