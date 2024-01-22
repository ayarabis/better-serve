import 'package:supabase_flutter/supabase_flutter.dart';

import '/constants.dart';
import '/domain/models/profile.dart';

class AuthDataSource {
  final sql = "*,role:roles(id,name,permissions,is_manage)";

  Future<void> sendOtp(String email) async {
    return await supabase.auth
        .signInWithOtp(email: email, shouldCreateUser: false);
  }

  Future<AuthResponse> login(String email, String token) async {
    return await supabase.auth
        .verifyOTP(email: email, token: token, type: OtpType.email);
  }

  Future<Profile> getProfile(String id) async {
    PostgrestMap data = await supabase
        .from("profiles")
        .select(sql)
        .eq("id", id)
        .single()
        .limit(1);
    return Profile.fromJson(data);
  }

  Future<User?> getCurrentUser() async {
    return supabase.auth.currentUser;
  }

  Future<void> signUp(String email) async {
    return await supabase.auth.signInWithOtp(
      email: email,
    );
  }

  Future<Profile> completeProfile(String firstName, String lastName) async {
    final user = supabase.auth.currentUser!;
    final data = await supabase
        .from("profiles")
        .update({
          "first_name": firstName,
          "last_name": lastName,
        })
        .eq("id", user.id)
        .select(sql)
        .single();

    await supabase.auth.refreshSession();
    return Profile.fromJson(data);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
