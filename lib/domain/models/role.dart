import 'package:equatable/equatable.dart';

class Role extends Equatable {
  final int id;
  final String name;
  final String description;
  final List<String> permissions;
  final bool isManage;
  bool selected = false;

  Role(
      {required this.id,
      required this.name,
      required this.description,
      required this.permissions,
      this.isManage = true});

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
        id: map['id'],
        name: map['name'],
        description: map['description'] ?? "",
        permissions: map['permissions'] != null
            ? (map['permissions'] as List<dynamic>)
                .map((e) => e.toString())
                .toList()
            : [],
        isManage: map['is_manage']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
      'isManage': isManage,
    };
  }

  @override
  List<Object?> get props => [id, name, description, permissions];
}
