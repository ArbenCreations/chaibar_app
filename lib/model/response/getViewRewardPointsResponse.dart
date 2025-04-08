class GetViewRewardPointsResponse {
  int? totalPoints;
  String? message;
  int? status;

  GetViewRewardPointsResponse({
     this.totalPoints,
     this.message,
     this.status,
  });

  factory GetViewRewardPointsResponse.fromJson(Map<String, dynamic> json) {
    return GetViewRewardPointsResponse(
      message: json["message"] as String?,
      status: json["status"] as int?,
      totalPoints:json["data"]?["total_points"] as int?,
    );

  }
}
