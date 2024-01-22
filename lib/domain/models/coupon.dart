import 'package:better_serve/data/models/discount.dart';
import 'package:equatable/equatable.dart';

import '/core/enums/discount_type.dart';

class Coupon extends Equatable {
  final int? id;
  final String code;
  final String description;
  final Discount discount;
  final int quantity;
  final int usageCount;
  DateTime? expiryDate;
  bool selected = false;

  Coupon({
    this.id,
    required this.code,
    required this.description,
    required this.discount,
    required this.quantity,
    required this.usageCount,
    this.expiryDate,
  });

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'],
      code: map['code'],
      description: map['description'],
      discount: Discount(
        DiscountType.fromValue(map['discount_type']),
        map['discount_value'],
      ),
      quantity: map['quantity'],
      usageCount: map['usage_count'],
      expiryDate: map['expiry_date'] == null
          ? null
          : DateTime.parse(map['expiry_date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) ...{'id': id},
      'code': code.toUpperCase(),
      'description': description,
      'discount_type': discount.type.name,
      'discount_value': discount.value,
      'quantity': quantity,
      'expiry_date': expiryDate,
      'usage_count': usageCount
    };
  }

  @override
  List<Object?> get props => [
        id,
        code,
        description,
        discount,
        quantity,
        usageCount,
        expiryDate,
      ];
}
