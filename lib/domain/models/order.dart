library better_serve_lib;

import 'package:equatable/equatable.dart';

import 'coupon.dart';
import 'order_item.dart';

class Order extends Equatable {
  final int id;
  final int itemCount;
  final double orderAmount;
  final double grandTotal;
  final double paymentAmount;
  final String paymentMethod;
  final String serverName;
  List<OrderItem> items;
  int? queueNumber;
  String orderDate;
  String orderTime;
  String? discountType;
  int? discountAmount;
  int? discountValue;
  Coupon? coupon;
  int status;

  bool removing = false;

  Order({
    required this.id,
    required this.itemCount,
    required this.orderAmount,
    required this.grandTotal,
    required this.status,
    required this.paymentAmount,
    required this.paymentMethod,
    required this.orderDate,
    required this.orderTime,
    required this.serverName,
    this.queueNumber,
    this.discountType,
    this.discountAmount,
    this.discountValue,
    this.coupon,
    this.items = const [],
  });

  Order.fromMap(Map<String, dynamic> map)
      : this(
          id: map["id"],
          itemCount: map["item_count"],
          orderAmount: (map["order_amount"] as num).toDouble(),
          paymentAmount: (map["payment_amount"] as num).toDouble(),
          paymentMethod: map["payment_method"],
          grandTotal: (map["grand_total"] as num).toDouble(),
          orderDate: map["order_date"],
          orderTime: map["order_time"],
          items: ((map["order_items"] ?? []) as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .map(OrderItem.fromMap)
              .toList(),
          status: map["status"],
          queueNumber: map["queue_number"],
          discountType: map["discount_type"],
          discountAmount: map["discount_amount"],
          discountValue: map["discount_value"],
          coupon:
              map["coupon_id"] != null ? Coupon.fromMap(map["coupon"]) : null,
          serverName: map["server_name"],
        );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "item_count": itemCount,
      "order_amount": orderAmount,
      "payment_amount": paymentAmount,
      "payment_method": paymentMethod,
      "grand_total": grandTotal,
      "order_date": orderDate,
      "order_time": orderTime,
      "status": status,
      "queue_number": queueNumber,
      "discount_type": discountType,
      "discount_amount": discountAmount,
      "discount_value": discountValue,
      "coupon_id": coupon?.id,
    };
  }

  @override
  List<Object?> get props => [
        id,
        itemCount,
        orderAmount,
        grandTotal,
        paymentAmount,
        paymentMethod,
        serverName,
        items,
        queueNumber,
        orderDate,
        orderTime,
        discountType,
        discountAmount,
        discountValue,
        coupon,
        status,
      ];
}
