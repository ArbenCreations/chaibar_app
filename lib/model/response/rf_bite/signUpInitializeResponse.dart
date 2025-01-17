class SignUpInitializeResponse {
  final String? phoneNumber;
  final String? message;
  final int? status;

  SignUpInitializeResponse({
    this.phoneNumber,
    this.message,
    this.status,
  });

  factory SignUpInitializeResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return SignUpInitializeResponse(
        message: json['message'] as String?,
        status: json['status'] as int?,);
    }
    return SignUpInitializeResponse(
      message: json['message'] as String?,
      status: json['status'] as int?,
      phoneNumber: json['data']?['phone_number'] as String?,
    );
  }
}
