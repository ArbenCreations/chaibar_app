class AddRewardPointsResponse {
  int? totalPoints;
  int? pointsEarned;
  String? message;
  int? status;

  AddRewardPointsResponse({
     this.pointsEarned,
     this.totalPoints,
     this.message,
     this.status,
  });

  factory AddRewardPointsResponse.fromJson(Map<String, dynamic> json) {
    return AddRewardPointsResponse(
      message: json["message"] as String?,
      status: json["status"] as int?,
      pointsEarned:json["data"]?["points_earned"] as int?,
      totalPoints: json["data"]?["total_points"] as int?,
    );

  }
}
