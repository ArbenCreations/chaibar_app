class SignUpWithGoogleRequest {
  CustomerSignUpWithGoogle? customer;

  SignUpWithGoogleRequest({ this.customer});

  Map<String, dynamic> toJson() {
    return {
      'customer': customer?.toJson(), // Convert the customer object to JSON
    };
  }
}

class CustomerSignUpWithGoogle {
   String? firstName;
   String? lastName;
   String? phoneNumber;
   String? loginType;
   String? idToken;
   String? deviceToken;
   String? email;

   CustomerSignUpWithGoogle({
    required this.email,
    required this.idToken,
    required this.firstName,
    required this.lastName,
    required this.deviceToken,
    required this.loginType,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'login_type': loginType,
      'first_name': firstName,
      'last_name': lastName,
      'device_token': deviceToken,
      'id_token': idToken,
      'phone_number': phoneNumber,
    };
  }
}