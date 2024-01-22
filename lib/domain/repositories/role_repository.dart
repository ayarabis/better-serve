import 'package:better_serve/domain/models/role.dart';
import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';

abstract class RoleRepository {
  Future<Either<Failure, List<Role>>> all();
  Future<Either<Failure, Role>> one(int roleId);
  Future<Either<Failure, Role>> saveRole(Map<String, dynamic> map);
  Future<Either<Failure, Role>> updateRole(Map<String, dynamic> map);
  Future<Either<Failure, void>> deleteRole(int id);
  Future<Either<Failure, void>> deleteRoles(List<int> ids);
}
