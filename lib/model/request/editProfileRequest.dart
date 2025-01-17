

class EditProfileRequest {
   String? firstName;
   String? lastName;
   String? phoneNumber;
   String? email;

   EditProfileRequest({
     this.email,
     this.firstName,
     this.phoneNumber,
     this.lastName,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'first_name': firstName,
      'phone_number': phoneNumber,
      'last_name': lastName,
    };
  }
}