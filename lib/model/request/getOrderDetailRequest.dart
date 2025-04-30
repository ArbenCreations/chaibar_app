class GetOrderDetailRequest {
  int? orderId;

  GetOrderDetailRequest({
    this.orderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
    };
  }
}
