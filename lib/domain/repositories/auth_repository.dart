import 'package:fpdart/fpdart.dart';

import '../models/profile.dart';
import '../../data/models/failure.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendOtp(String email);
  Future<Either<Failure, void>> signUp(String email);
  Future<Either<Failure, void>> login(String email, String token);
  Future<Either<Failure, Profile>> getProfile();
  Future<Either<Failure, void>> completeProfile(
      String firstName, String lastName);
  Future<Either<Failure, void>> signOut();
}
