import 'package:equatable/equatable.dart';

import 'attribute.dart';
import 'category.dart';
import 'variation.dart';

class Product extends Equatable {
  int? id;
  final String name;
  final double basePrice;
  final String imgUrl;
  final bool allowAddon;
  Category category;
  List<Attribute> attributes;
  Variation? variation;

  Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.imgUrl,
    required this.category,
    required this.allowAddon,
    required this.attributes,
    required this.variation,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    final variation = (map['variation'] as List<dynamic>).firstOrNull;
    return Product(
      id: map['id'],
      name: map['name'],
      basePrice: (map['base_price'] as num).toDouble(),
      imgUrl: map['img_url'],
      category: Category.fromMap(map['category']),
      allowAddon: map['allow_addon'],
      attributes: List<Attribute>.from(
          (map['attributes'] as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e))
              .map(Attribute.fromMap),
          growable: true),
      variation: variation == null
          ? null
          : Variation.fromMap(variation as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) ...{'id': id},
      'name': name,
      'base_price': basePrice,
      'img_url': imgUrl,
      'category': category.toMap(),
      'allow_addon': allowAddon,
      'attributes': attributes.map((a) => a.toMap()).toList(),
      'variations': variation?.toMap(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        basePrice,
        imgUrl,
        allowAddon,
        category,
      ];
}
