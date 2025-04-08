class SuccessCallbackRequest {
  int orderId;
  String transactionId;
  String transactionStatus;
  bool isPaymentSuccessTrue;
  String customerId;

  SuccessCallbackRequest(
      {required this.orderId,
      required this.transactionId,
      required this.isPaymentSuccessTrue,
      required this.customerId,
      required this.transactionStatus});

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'transaction_id': transactionId,
      'customer_id': customerId,
      'transaction_status': transactionStatus,
      'is_payment_success_true': isPaymentSuccessTrue
    };
  }
}
