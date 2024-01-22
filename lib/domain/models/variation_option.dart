class VariationOption {
  final int? id;
  double price;
  String value;
  bool isSelected;
  bool isDefault;

  VariationOption(
      {required this.id,
      required this.value,
      required this.price,
      required this.isSelected,
      this.isDefault = false});

  factory VariationOption.fromMap(Map<String, dynamic> map) => VariationOption(
        id: map['id'],
        value: map['value'],
        price: (map['price'] as num).toDouble(),
        isSelected: map['is_selected'],
        isDefault: map['is_selected'],
      );

  Map<String, dynamic> toMap() {
    return {
      if (id != null) ...{'id': id},
      'value': value,
      'price': price,
      'is_selected': isSelected,
    };
  }

  VariationOption clone() => VariationOption(
        id: id,
        value: value,
        price: price,
        isSelected: isSelected,
      );

  factory VariationOption.empty() => VariationOption(
        id: null,
        value: '',
        price: 0,
        isSelected: false,
      );
}
