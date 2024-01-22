import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/data/repositories/auth_repository_impl.dart';
import '/data/sources/auth_data_source.dart';
import '/domain/models/profile.dart';

User? get currentUser => supabase.auth.currentUser;
String? get tenantId => currentUser?.userMetadata?["tenant_id"];
List<String> get permissions {
  final list = currentUser?.userMetadata?["permissions"] as List<dynamic>;
  return list.map((e) => e.toString()).toList();
}

class AuthProvider with ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();
  factory AuthProvider() => _instance;
  AuthProvider._internal();

  final AuthRepositoryImpl _authRepository =
      AuthRepositoryImpl(source: AuthDataSource());

  final List<Profile> _users = [];
  List<Profile> get users => _users;

  bool isLoading = false;

  Future<Either<Failure, AuthResponse>> login(
      String email, String token) async {
    var res = await _authRepository.login(email, token);
    return res;
  }

  Future<Either<Failure, void>> signUp(String email) async {
    var res = await _authRepository.signUp(email);
    return res;
  }

  Future<Either<Failure, void>> completeProfile(
      String firstName, String lastName) async {
    final res = await _authRepository.completeProfile(firstName, lastName);
    return res;
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<void> sendOtp(String email) async {
    await _authRepository.sendOtp(email);
  }
}
