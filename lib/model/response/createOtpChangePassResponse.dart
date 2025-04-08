

class CreateOtpChangePassResponse {
  int? status;
  String? email;
  String? message;

  CreateOtpChangePassResponse({
    required this.status,
    required this.email,
    required this.message,
  });

  factory CreateOtpChangePassResponse.fromJson(Map<String, dynamic> json) {
    return CreateOtpChangePassResponse(
      message: json["message"] as String?,
      status: json["status"] as int?,
      email: json['data']?["email"] as String?,

    );
  }
}
