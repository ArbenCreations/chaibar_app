class AddRewardPointsRequest {
  double amountSpent;
  int orderId;
  String couponCode;

  AddRewardPointsRequest({
    required this.amountSpent,
    required this.orderId,
    required this.couponCode
  });

  Map<String, dynamic> toJson() {
    return {
      'amount_spent': amountSpent,
      'order_id': orderId,
      'coupon_code': couponCode,

    };
  }
}

