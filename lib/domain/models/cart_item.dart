import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'addon.dart';
import 'attribute.dart';
import 'product.dart';
import 'variation.dart';

class CartItem extends Equatable {
  String id;
  Product product;
  int quantity;
  Variation? variation;
  List<Attribute> attributes;
  List<Addon> addons;

  CartItem({
    required this.product,
    required this.quantity,
    required this.variation,
    required this.attributes,
    required this.addons,
  }) : id = const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      "product": product.toMap(),
      "quantity": quantity,
      "variation": variation?.toMap(),
      "attributes": attributes.map((e) => e.toMap()).toList(),
      "addons": addons.map((e) => e.toMap()).toList()
    };
  }

  CartItem.fromMap(dynamic json)
      : this(
          product: Product.fromMap(json["product"]),
          quantity: json["quantity"],
          variation: Variation.fromMap(json["variation"]),
          attributes: (json["attributes"] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .map(Attribute.fromMap)
              .toList(),
          addons: (json["addons"] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .map(Addon.fromMap)
              .toList(),
        );

  @override
  List<Object?> get props => [
        id,
        product,
        quantity,
        variation,
        attributes,
        addons,
      ];
}
