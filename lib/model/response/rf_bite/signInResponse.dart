import 'package:ChaatBar/model/response/rf_bite/signUpVerifyResponse.dart';

class SignInResponse {
  final SignUpCustomer? customer;
  final String? token;
  final bool? newUser;
  final String? message;
  final int? status;

  SignInResponse(
      {this.customer,
        this.token,
        this.newUser,
        this.status,
        this.message,});

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      return SignInResponse(
        message: json['message'] as String?,
        status: json['status'] as int?,);
    }
    return SignInResponse(
      message: json['message'] as String?,
      status: json['status'] as int?,
      customer: SignUpCustomer.fromJson(json['data']?['customer']),
      token: json['data']?['token'] as String?,
      newUser: json['data']?['new_user'] as bool?,
    );
  }
}
