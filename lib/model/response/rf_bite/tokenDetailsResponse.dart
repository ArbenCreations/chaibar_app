class TokenDetailsResponse {
  //final String? message;
  //final ErrorDetails error;
  final String? id;
  final String? object;
  final String? message;
  final CardDetails card;

  TokenDetailsResponse({
   // required this.message,
    //required this.error,
    required this.id,
    required this.object,
    required this.card,
    required this.message,
  });

  // Factory constructor to create an instance from JSON
  factory TokenDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TokenDetailsResponse(
      //message: json['message'],
      //error: ErrorDetails.fromJson(json['error']),
      message: json['message'],
      id: json['id'],
      object: json['object'],
      card: CardDetails.fromJson(json['card']),
    );
  }

  // Method to convert an instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'object': object,
      'card': card.toJson(),
    };
  }
}

class CardDetails {
  final String? expMonth;
  final String? expYear;
  final String? first6;
  final String? last4;
  final String? brand;

  CardDetails({
    required this.expMonth,
    required this.expYear,
    required this.first6,
    required this.last4,
    required this.brand,
  });

  // Factory constructor to create an instance from JSON
  factory CardDetails.fromJson(Map<String, dynamic> json) {
    return CardDetails(
      expMonth: json['exp_month'],
      expYear: json['exp_year'],
      first6: json['first6'],
      last4: json['last4'],
      brand: json['brand'],
    );
  }

  // Method to convert an instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'exp_month': expMonth,
      'exp_year': expYear,
      'first6': first6,
      'last4': last4,
      'brand': brand,
    };
  }
}

class ErrorDetails {
  final String code;
  final String message;

  ErrorDetails({
    required this.code,
    required this.message,
  });

  // Factory constructor to create an instance from JSON
  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      code: json['code'],
      message: json['message'],
    );
  }

  // Method to convert an instance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}