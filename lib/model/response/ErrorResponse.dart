class ErrorResponse {
  final String? message;
  final ErrorDetails error;

  ErrorResponse({required this.message, required this.error});

  // Factory method to create an instance from JSON
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'],
      error: ErrorDetails.fromJson(json['error']),
    );
  }

  // Convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'error': error.toJson(),
    };
  }

  @override
  String toString() {
    return 'ErrorResponse{message: $message, error: $error}';
  }
}

class ErrorDetails {
  final String? type;
  final String? code;
  final String? message;

  ErrorDetails({
    required this.type,
    required this.code,
    required this.message,
  });

  // Factory method to create an instance from JSON
  factory ErrorDetails.fromJson(Map<String, dynamic> json) {
    return ErrorDetails(
      type: json['type'],
      code: json['code'],
      message: json['message'],
    );
  }

  // Convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'code': code,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'ErrorDetails{type: $type, code: $code, message: $message}';
  }
}
