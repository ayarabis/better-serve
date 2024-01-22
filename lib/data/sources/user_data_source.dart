import 'package:supabase_flutter/supabase_flutter.dart';

import '/constants.dart';
import '/domain/models/profile.dart';

class UserDataSource {
  Future<List<Profile>> getAllProfiles() async {
    final res = await supabase
        .from("profiles")
        .select("*,role:roles(id,name,permissions,is_manage)")
        .not("id", "eq", supabase.auth.currentUser!.id);
    return res.map(Profile.fromJson).toList();
  }

  Future<Profile> saveProfile(Profile profile) async {
    AdminUserAttributes attr = AdminUserAttributes(
        email: profile.email,
        password: "12345678",
        emailConfirm: true,
        userMetadata: {
          'first_name': profile.firstName,
          'last_name': profile.lastName,
          'tenant_id': profile.tenantId,
          'avatar': profile.avatarUrl,
          'permissions': profile.role.permissions
        });
    final res = await supabase.functions.invoke("upsert-user", headers: {
      "Content-Type": "application/json",
    }, body: {
      "id": profile.id,
      "attributes": attr.toJson(),
      "profile": {
        'id': profile.id,
        'first_name': profile.firstName,
        'last_name': profile.lastName,
        'role': profile.role.name,
        'avatar': profile.avatarUrl
      }
    });
    if (res.data['error'] != null) {
      throw PostgrestException.fromJson(res.data['error']);
    }
    final user = res.data['profile'] as Map<String, dynamic>;
    return Profile.fromJson(user);
  }

  Future<void> deleteUser(String? id) async {
    final res = await supabase.functions.invoke("delete-user", headers: {
      "Content-Type": "application/json",
    }, body: {
      "id": id,
    });
    if (res.data['error'] != null) {
      throw PostgrestException.fromJson(res.data['error']);
    }
  }
}
