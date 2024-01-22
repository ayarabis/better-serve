import 'package:better_serve/domain/models/attribute_option.dart';
import 'package:equatable/equatable.dart';

class Attribute extends Equatable {
  final int? id;
  String name;
  String? label;
  bool isMultiple;
  List<AttributeOption> options;

  Attribute({
    required this.id,
    required this.name,
    required this.label,
    required this.isMultiple,
    required this.options,
  });

  factory Attribute.fromMap(Map<String, dynamic> map) => Attribute(
        id: map['id'],
        name: map['name'],
        label: map['label'],
        isMultiple: map['is_multiple'],
        options: List<AttributeOption>.from(
          (map['options'] as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e))
              .map(AttributeOption.fromMap),
        ),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) ...{'id': id},
        'name': name,
        'label': label,
        'is_multiple': isMultiple,
        'options': options.map((o) => o.toMap()).toList(),
      };

  Attribute clone() => Attribute(
        id: id,
        name: name,
        label: label,
        isMultiple: isMultiple,
        options: options.map((e) => e.clone()).toList(),
      );

  factory Attribute.empty() => Attribute(
        id: null,
        name: "",
        label: "",
        isMultiple: false,
        options: List.generate(2, (i) => AttributeOption.empty()),
      );

  @override
  List<Object?> get props => [id, name, label, isMultiple, options];
}
