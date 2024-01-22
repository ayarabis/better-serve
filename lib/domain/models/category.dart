import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final int? id;
  String name;
  String iconUrl;
  int order;
  final int productCount;

  Category({
    this.id,
    required this.name,
    required this.iconUrl,
    required this.order,
    this.productCount = 0,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      order: map['order'],
      iconUrl: map['icon_url'],
      productCount:
          map['products'] == null ? 0 : map['products'][0]?['count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) ...{'id': id},
      'name': name,
      'order': order,
      'icon_url': iconUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, order,iconUrl,];
}
