import 'package:ChaiBar/model/response/createOrderResponse.dart';

class OrderDetailResponse {
  Data? data;
  int? status;
  bool? success;
  String? message;

  OrderDetailResponse({this.data, this.status, this.success, this.message});

  OrderDetailResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    status = json['status'];
    success = json['success'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['status'] = this.status;
    data['success'] = this.success;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  OrderDetails? order;

  Data({this.order});

  Data.fromJson(Map<String, dynamic> json) {
    order =
        json['order'] != null ? new OrderDetails.fromJson(json['order']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.order != null) {
      data['order'] = this.order!.toJson();
    }
    return data;
  }
}
