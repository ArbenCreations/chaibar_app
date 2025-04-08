class SignUpInitializeResponse {
  final String? phoneNumber;
  final String? message;
  final String? data;
  final int? status;

  SignUpInitializeResponse({
    this.phoneNumber,
    this.message,
    this.data,
    this.status,
  });

  factory SignUpInitializeResponse.fromJson(Map<String, dynamic> json) {
    String? parsedMessage = json['message']?.toString();
    String? phone;
    String? dataMessage;

    if (json['data'] is String) {
      dataMessage = json['data'] as String;
    } else if (json['data'] is Map<String, dynamic>) {
      phone = json['data']?['phone_number'] as String?;
    }

    return SignUpInitializeResponse(
      status: json['status'] as int?,
      message: parsedMessage,
      data: dataMessage,
      phoneNumber: phone,
    );
  }

  @override
  String toString() {
    return 'Status: $status\nMessage: $message\nData: $data\nPhone Number: $phoneNumber';
  }
}
