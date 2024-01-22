import '/core/enums/discount_type.dart';

class Discount {
  final int value;
  final DiscountType type;

  Discount(this.type, this.value);

  factory Discount.fromMap(Map<String, dynamic> map) {
    return Discount(
      DiscountType.fromValue(map['type']),
      map['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'value': value,
    };
  }
}
