class GetRewardPointsRequest {
  double pointsToRedeem;

  GetRewardPointsRequest({
    required this.pointsToRedeem
  });

  Map<String, dynamic> toJson() {
    return {
      'points_to_redeem': pointsToRedeem
    };
  }
}

