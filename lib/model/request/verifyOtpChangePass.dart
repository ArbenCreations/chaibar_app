
class VerifyOtChangePassRequest {
  String? password;
  String? email;
  String? mobileOtp;


  VerifyOtChangePassRequest({
     this.password,
     this.email,
     this.mobileOtp,
  });
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'otp': mobileOtp,

    };
  }
}
