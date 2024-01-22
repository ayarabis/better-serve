import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sources/role_data_source.dart';
import '../models/failure.dart';
import '/domain/models/role.dart';
import '/domain/repositories/role_repository.dart';

class RoleRepositoryImpl implements RoleRepository {
  RoleDataSource source;

  RoleRepositoryImpl({required this.source});

  @override
  Future<Either<Failure, List<Role>>> all() async {
    try {
      return Right(await source.getRoles());
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Role>> one(int id) async {
    try {
      return Right(await source.getRole(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Role>> saveRole(Map<String, dynamic> map) async {
    try {
      return Right(await source.createRole(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Role>> updateRole(Map<String, dynamic> map) async {
    try {
      return Right(await source.updateRole(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRole(int id) async {
    try {
      return Right(await source.deleteRole(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRoles(List<int> list) async {
    try {
      return Right(await source.deleteRoles(list));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
