class ItemReviewRequest {
  final int productId;
  final Review review;

  ItemReviewRequest({required this.productId, required this.review});

  // Factory method to create an instance from JSON
  factory ItemReviewRequest.fromJson(Map<String, dynamic> json) {
    return ItemReviewRequest(
      productId: json['product_id'],
      review: Review.fromJson(json['review']),
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'review': review.toJson(),
    };
  }
}

class Review {
  final bool isUpvote;

  Review({required this.isUpvote});

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      isUpvote: json['is_upvote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_upvote': isUpvote,
    };
  }
}
