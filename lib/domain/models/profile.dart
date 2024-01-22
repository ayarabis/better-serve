import 'package:equatable/equatable.dart';

import 'role.dart';

class Profile extends Equatable {
  final String? id;
  final String email;
  final String firstName;
  final String lastName;
  final String tenantId;
  final Role role;
  String? avatarUrl;

  Profile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.tenantId,
    required this.role,
    this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      avatarUrl: json['avatar'],
      tenantId: json['tenant_id'],
      role: Role.fromMap(json['role']),
    );
  }

  String get initials => (firstName[0] + lastName[0]).toUpperCase();

  Map<String, dynamic> toJson() => {
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'avatar': avatarUrl,
        'tenant_id': tenantId,
        'role': role,
      };

  @override
  List<Object?> get props => [id, firstName, lastName];
}
