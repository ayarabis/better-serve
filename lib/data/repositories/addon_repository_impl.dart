import 'package:better_serve/data/models/failure.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sources/addon_data_source.dart';
import '/domain/models/addon.dart';
import '/domain/repositories/addon_repository.dart';

class AddonRepositoryImpl implements AddonRepository {
  AddonDataSource source;

  AddonRepositoryImpl({required this.source});

  @override
  Future<Either<Failure, List<Addon>>> all() async {
    try {
      return Right(await source.getAddons());
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Addon>> one(int id) async {
    try {
      return Right(await source.getAddon(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Addon>> save(Map<String, dynamic> map) async {
    try {
      return Right(await source.saveAddon(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      return Right(await source.deleteAddon(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMany(List<int> list) async {
    try {
      return Right(await source.deleteAddons(list));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
