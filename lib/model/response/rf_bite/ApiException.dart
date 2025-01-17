class ApiException implements Exception {
  final String type;
  final String code;
  final String message;

  ApiException({required this.type, required this.code, required this.message});

  @override
  String toString() => 'ApiException(type: $type, code: $code, message: $message)';
}
