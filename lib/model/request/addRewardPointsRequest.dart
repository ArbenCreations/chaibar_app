class AddRewardPointsRequest {
  double amountSpent;
  int orderId;
  int couponId;
  String couponCode;

  AddRewardPointsRequest({
    required this.amountSpent,
    required this.orderId,
    required this.couponId,
    required this.couponCode
  });

  Map<String, dynamic> toJson() {
    return {
      'amount_spent': amountSpent,
      'order_id': orderId,
      'coupon_id': couponId,
      'coupon_code': couponCode,

    };
  }
}

