import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sources/user_data_source.dart';
import '../models/failure.dart';
import '/domain/models/profile.dart';
import '/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final UserDataSource source;

  ProfileRepositoryImpl({
    required this.source,
  });

  @override
  Future<Either<Failure, List<Profile>>> all() async {
    try {
      var data = await source.getAllProfiles();
      return Right(data);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(String id) async {
    try {
      return Right(await source.deleteUser(id));
    } on PostgrestException catch (error) {
      return Left(Failure(error.message));
    }
  }

  @override
  Future<Either<Failure, Profile>> save(Profile profile) async {
    try {
      return Right(await source.saveProfile(profile));
    } on PostgrestException catch (error) {
      return Left(Failure(error.message));
    }
  }
}
