import 'package:better_serve/domain/models/profile.dart';
import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';

abstract class ProfileRepository {
  Future<Either<Failure, List<Profile>>> all();
  Future<Either<Failure, Profile>> save(Profile profile);
  Future<Either<Failure, void>> delete(String userId);
}
