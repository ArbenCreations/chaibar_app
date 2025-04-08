class SignUpVerifyResponse {
  final SignUpCustomer? customer;
  final String? token;
  final String? message;
  final int? status;

  SignUpVerifyResponse(
      {this.customer,
      this.token,
      this.status,
      this.message,});

  factory SignUpVerifyResponse.fromJson(Map<String, dynamic> json) {
    return SignUpVerifyResponse(
      message: json['message']?.toString(), // ✅ Convert int to String safely
      status: json['status'] as int?,
      customer: json['data']?['customer'] != null
          ? SignUpCustomer.fromJson(json['data']['customer'])
          : null,
      token: json['data']?['token'] as String?,
    );
  }
}

class SignUpCustomer {
  final String? firstName;
  final String? lastName;
  final int? id;
  final String? phoneNumber;
  final String? createdAt;
  final String? updatedAt;
  final String? email;
  final int? totalPoints;

  SignUpCustomer(
      {this.firstName,
      this.lastName,
      this.id,
      this.phoneNumber,
      this.createdAt,
      this.totalPoints,
      this.updatedAt,
      this.email,});

  factory SignUpCustomer.fromJson(Map<String, dynamic> json) {
    return SignUpCustomer(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      id: json['id'] as int?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: json['created_at'] as String?,
      totalPoints: json['total_points'] as int?,
      updatedAt: json['updated_at'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['id'] = this.id;
    data['phone_number'] = this.phoneNumber;
    data['email'] = this.email;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }

  factory SignUpCustomer.fromPref(Map<String, dynamic> json) {
    return SignUpCustomer(
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      id: json['id'] as int?,
      phoneNumber: json['phone_number'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      email: json['email'] as String?,
    );
  }
}
