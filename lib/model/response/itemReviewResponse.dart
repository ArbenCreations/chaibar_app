class ItemReviewResponse {
  String? message;
  int? status;
  ReviewData? data;

  ItemReviewResponse({
    this.message,
    this.status,
    this.data,
  });

  factory ItemReviewResponse.fromJson(Map<String, dynamic> json) {
    return ItemReviewResponse(
      message: json["message"] as String?,
      status: json["status"] as int?,
      data: json["data"] != null ? ReviewData.fromJson(json["data"]) : null,
    );
  }
}

class ReviewData {
  int? productId;
  bool? isUpvote;
  int? customerId;
  int? id;
  DateTime? createdAt;

  ReviewData({
    this.productId,
    this.isUpvote,
    this.customerId,
    this.id,
    this.createdAt,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      productId: json["review"]?["product_id"] as int?,
      isUpvote: json["review"]?["is_upvote"] as bool?,
      customerId: json["review"]?["customer_id"] as int?,
      id: json["review"]?["id"] as int?,
      createdAt: json["review"]?["created_at"] != null
          ? DateTime.parse(json["review"]?["created_at"])
          : null,
    );
  }
}