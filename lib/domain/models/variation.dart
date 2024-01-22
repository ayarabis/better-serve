import 'package:equatable/equatable.dart';

import 'variation_option.dart';

class Variation extends Equatable {
  final int? id;
  String name;
  String? label;
  List<VariationOption> options;

  Variation({
    required this.id,
    required this.name,
    required this.options,
    this.label,
  });

  factory Variation.fromMap(Map<String, dynamic> map) {
    return Variation(
      id: map['id'],
      name: map['name'],
      label: map['label'],
      options: List<VariationOption>.from(
        (map['options'] as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e))
            .map(VariationOption.fromMap),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) ...{'id': id},
      'name': name,
      'label': label,
      'options': options.map((o) => o.toMap()).toList(),
    };
  }

  Variation clone() => Variation(
        id: null,
        name: name,
        label: label,
        options: options.map((e) => e.clone()).toList(),
      );

  factory Variation.empty() => Variation(
        id: null,
        name: "",
        label: "",
        options: List.generate(2, (i) => VariationOption.empty()),
      );

  @override
  List<Object?> get props => [id, name, label];
}
