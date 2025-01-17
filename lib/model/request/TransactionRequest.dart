class TransactionRequest {
  final double amount;
  final String currency;
  final String source;

  TransactionRequest(
      {required this.amount, required this.currency, required this.source});

  // Factory constructor to create an instance from JSON
  factory TransactionRequest.fromJson(Map<String, dynamic> json) {
    return TransactionRequest(
        amount: json['amount'],
        currency: json['currency'],
        source: json['source']);
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {'amount': amount, 'currency': currency, 'source': source};
  }
}
