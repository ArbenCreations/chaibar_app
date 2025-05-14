class CreateOtpChangePassResponse {
  final int? status;
  final String? email;
  final String? message;

  CreateOtpChangePassResponse({
    this.status,
    this.email,
    this.message,
  });

  factory CreateOtpChangePassResponse.fromJson(Map<String, dynamic> json) {
    return CreateOtpChangePassResponse(
      message: json["message"] as String?,
      status: json["status"] as int?,
      email: json['data']?["email"] as String?,
    );
  }
}
