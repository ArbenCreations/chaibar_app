class CreateOtpChangePassRequest {
  String email;

  CreateOtpChangePassRequest({
    required this.email,
  });
  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
