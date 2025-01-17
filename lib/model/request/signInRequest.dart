class SignInRequest {
  CustomerSignIn? customer;

  SignInRequest({this.customer});

  Map<String, dynamic> toJson() {
    return {
      'customer': customer?.toJson(), // Convert the customer object to JSON
    };
  }
}

class CustomerSignIn {
  String email;
  String password;
  String deviceToken;

  CustomerSignIn({required this.email, required this.password,required this.deviceToken});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'device_token': deviceToken
    };
  }
}