class CreateOrderRequest {
  Order order;
  int? vendorId;

  CreateOrderRequest({required this.order,
    required this.vendorId,});

  Map<String, dynamic> toJson() {
    return {
      'order': order.toJson(), // Convert the customer object to JSON
      'vendor_id': vendorId, // Convert the customer object to JSON
    };
  }
}

class Order {
  String customerName;
  String customerEmail;
  String phoneNumber;
  String pickupDate;
  String pickupTime;
  int userId;
  int deliveryStatus;
  int status;
  int couponId;
  int customerId;
  bool isPaymentSuccessTrue;
  String couponCode;
  double totalAmount;
  double discountAmount;
  double payableAmount;
  double deliveryCharges;
  String orderNotes;
  int tip;
  List<Product> products;

  Order({
    required this.customerName,
    required this.customerEmail,
    required this.phoneNumber,
    required this.pickupDate,
    required this.pickupTime,
    required this.userId,
    required this.customerId,
    required this.deliveryStatus,
    required this.status,
    required this.couponId,
    required this.couponCode,
    required this.totalAmount,
    required this.discountAmount,
    required this.payableAmount,
    required this.deliveryCharges,
    required this.orderNotes,
    required this.isPaymentSuccessTrue,
    required this.tip,
    required this.products,
  });
  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'customer_email': customerEmail,
      'phone_number': phoneNumber,
      'pickup_date': pickupDate,
      'pickup_time': pickupTime,
      'user_id': userId,
      'customer_id': customerId,
      'delivery_status': deliveryStatus,
      'is_payment_success_true': isPaymentSuccessTrue,
      'status': status,
      'coupon_id': couponId,
      'coupon_code': couponCode,
      'total_amount': totalAmount,
      'discount_amount': discountAmount,
      'payable_amount': payableAmount,
      'delivery_charges': deliveryCharges,
      'order_notes': orderNotes,
      'tip': tip,
      'products':  products.map((item) => item.toJson()).toList(),
    };
  }
}

class Product {
  int productId;
  double? price;
  List<int> addOnIds;
  int quantity;

  Product({
    required this.productId,
    required this.price,
    required this.addOnIds,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId, // Convert the customer object to JSON
      'price': price, // Convert the customer object to JSON
      'addon_ids': addOnIds, // Convert the customer object to JSON
      'quantity': quantity, // Convert the customer object to JSON
    };
  }

}