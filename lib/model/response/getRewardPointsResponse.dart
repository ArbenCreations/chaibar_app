class GetRewardPointsResponse {
  int? totalPoints;
  int? pointsRedeemed;
  double? discountAmount;
  String? message;
  int? status;

  GetRewardPointsResponse({
     this.pointsRedeemed,
     this.totalPoints,
     this.discountAmount,
     this.message,
     this.status,
  });

  factory GetRewardPointsResponse.fromJson(Map<String, dynamic> json) {
    return GetRewardPointsResponse(
      message: json["message"] as String?,
      status: json["status"] as int?,
      pointsRedeemed:json["data"]?["points_to_redeem"] as int?,
      discountAmount:json["data"]?["discount_amount"] as double?,
      totalPoints: json["data"]?["total_points"] as int?,
    );

  }
}
