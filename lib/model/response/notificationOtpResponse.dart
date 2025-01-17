class NotificationOtpResponse {
  final String? otp;
  final String? notificationType;

  NotificationOtpResponse({
    this.otp,
    this.notificationType
  });

  factory NotificationOtpResponse.fromJson(Map<String, dynamic> json) {
    return NotificationOtpResponse(
      otp: json['otp'] as String?,
      notificationType: json['notification_type'] as String?
    );
  }
}
