class SignUpRequest {
  CustomerSignUp? customer;

  SignUpRequest({ this.customer});

  Map<String, dynamic> toJson() {
    return {
      'temp_customer': customer?.toJson(), // Convert the customer object to JSON
    };
  }
}

class CustomerSignUp {
   String? firstName;
   String? lastName;
   String? phoneNumber;
   String? password;
   String? deviceToken;
   String? email;

  CustomerSignUp({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.deviceToken,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'device_token': deviceToken,
      'phone_number': phoneNumber,
    };
  }
}