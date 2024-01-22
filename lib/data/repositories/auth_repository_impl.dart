import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/failure.dart';
import '/data/sources/auth_data_source.dart';
import '/domain/models/profile.dart';
import '/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource source;

  AuthRepositoryImpl({
    required this.source,
  });

  @override
  Future<Either<Failure, void>> sendOtp(String email) async {
    try {
      final res = await source.sendOtp(email);
      return Right(res);
    } on AuthException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> login(
      String email, String token) async {
    try {
      final res = await source.login(email, token);
      return Right(res);
    } on AuthException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Profile>> getProfile() async {
    User? user = await source.getCurrentUser();
    try {
      Profile profile = await source.getProfile(user!.id);
      return Right(profile);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signUp(String email) async {
    try {
      final res = await source.signUp(email);
      return Right(res);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Profile>> completeProfile(
      String firstName, String lastName) async {
    try {
      final res = await source.completeProfile(firstName, lastName);
      return Right(res);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await source.signOut();
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
