class GetProductsRequest {
  String categoryId;

  GetProductsRequest({
    required this.categoryId
  });

  Map<String, dynamic> toJson() {
    return { // Convert the customer object to JSON
      'category_id': categoryId, // Convert the customer object to JSON
    };
  }
}

