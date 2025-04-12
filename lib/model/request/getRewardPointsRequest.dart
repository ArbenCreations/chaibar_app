class GetRewardPointsRequest {
  double pointsToRedeem;
  int orderId;

  GetRewardPointsRequest({
    required this.pointsToRedeem,
    required this.orderId
  });

  Map<String, dynamic> toJson() {
    return {
      'points_to_redeem': pointsToRedeem,
      'order_id': orderId
    };
  }
}

