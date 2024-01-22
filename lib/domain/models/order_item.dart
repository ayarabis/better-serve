import 'package:equatable/equatable.dart';

import 'addon.dart';
import 'product.dart';

class OrderItem extends Equatable {
  final int id;
  final int orderId;
  final String productName;
  final String imgUrl;
  final String? variationName;
  final String? variationValue;
  final int quantity;
  final int unitPrice;
  final int subTotal;

  Product? product;

  final List<OrderItemAttribute> attributes;
  final List<OrderItemAddon> addons;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.imgUrl,
    required this.quantity,
    required this.unitPrice,
    required this.subTotal,
    required this.attributes,
    required this.addons,
    this.variationName,
    this.variationValue,
    this.product,
  });

  OrderItem.fromMap(Map<String, dynamic> map)
      : this(
          id: map["id"],
          orderId: map["order_id"],
          productName: map["product_name"],
          imgUrl: map["product_img_url"],
          variationName: map["variation_name"],
          variationValue: map["variation_value"],
          quantity: map["quantity"],
          unitPrice: map["unit_price"],
          subTotal: map["sub_total"],
          attributes: ((map["order_item_attributes"] ?? []) as List<dynamic>)
              .map(OrderItemAttribute.fromMap)
              .toList(),
          addons: ((map["order_item_addons"] ?? []) as List<dynamic>)
              .map(OrderItemAddon.fromMap)
              .toList(),
          product:
              map["product"] != null ? Product.fromMap(map["product"]) : null,
        );

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "order_id": orderId,
      "product_name": productName,
      "img_url": imgUrl,
      "variation_name": variationName,
      "variation_value": variationValue,
      "quantity": quantity,
      "unit_price": unitPrice,
      "sub_total": subTotal
    };
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productName,
        imgUrl,
        variationName,
        variationValue,
        quantity,
        unitPrice,
        subTotal,
      ];
}

class OrderItemAttribute {
  final String name;
  final List<String> values;

  OrderItemAttribute({required this.name, required this.values});

  OrderItemAttribute.fromMap(dynamic json)
      : this(
            name: json["name"],
            values: (json["values"] as List<dynamic>)
                .map<String>((e) => e as String)
                .toList());
}

class OrderItemAddon {
  final String name;
  final int price;
  final String imgPath;
  Addon addon;

  OrderItemAddon({
    required this.name,
    required this.price,
    required this.imgPath,
    required this.addon,
  });

  OrderItemAddon.fromMap(dynamic json)
      : this(
          name: json["name"],
          price: json["price"],
          imgPath: json["img_url"],
          addon: Addon.fromMap(json["addon"]),
        );
}
