import 'package:equatable/equatable.dart';

class Addon extends Equatable {
  final int? id;
  String name;
  double price;
  String imgUrl;

  Addon({
    this.id,
    required this.name,
    required this.price,
    required this.imgUrl,
  });

  factory Addon.fromMap(Map<String, dynamic> map) {
    return Addon(
      id: map['id'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      imgUrl: map['img_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) ...{'id': id},
      'name': name,
      'price': price,
      'img_url': imgUrl,
    };
  }

  Addon clone() => Addon(id: id, name: name, price: price, imgUrl: imgUrl);

  @override
  List<Object?> get props => [id, name, price, imgUrl];
}
