import 'package:equatable/equatable.dart';

class AttributeOption extends Equatable {
  final int? id;
  String value;
  int order;
  bool isSelected;
  bool isDefault;

  AttributeOption({
    required this.id,
    required this.value,
    required this.isSelected,
    this.isDefault = false,
    this.order = 0,
  });

  factory AttributeOption.fromMap(Map<String, dynamic> map) => AttributeOption(
        id: map['id'],
        value: map['value'],
        order: map['order'],
        isSelected: map['is_selected'],
        isDefault: map['is_selected'],
      );

  Map<String, dynamic> toMap() => {
        if (id != null) ...{'id': id},
        'value': value,
        'order': order,
        'is_selected': isSelected,
      };

  AttributeOption clone() => AttributeOption(
        id: id,
        value: value,
        order: order,
        isSelected: isSelected,
      );

  @override
  List<Object?> get props => [
        id,
        value,
        order,
        isSelected,
      ];

  factory AttributeOption.empty() => AttributeOption(
        id: null,
        value: '',
        isSelected: false,
      );
}
