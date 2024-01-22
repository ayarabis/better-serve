import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/data/repositories/role_repository_impl.dart';
import '/data/sources/role_data_source.dart';
import '/domain/models/role.dart';

class RoleProvider with ChangeNotifier {
  static final RoleProvider _instance = RoleProvider._internal();
  factory RoleProvider() => _instance;
  RoleProvider._internal() {
    loadRoles();
  }

  final RoleRepositoryImpl roleRepository =
      RoleRepositoryImpl(source: RoleDataSource());

  final List<Role> _roles = [];
  List<Role> get roles => _roles;

  bool isLoading = false;

  Future<void> loadRoles() async {
    isLoading = true;
    notifyListeners();
    var res = await roleRepository.all();
    res.fold(logger.e, (r) {
      _roles.addAll(r);
      notifyListeners();
    });
    isLoading = false;
    notifyListeners();
  }

  Future<Either<Failure, Role>> updateRole(Role role, String name,
      String description, List<String> permissions) async {
    final result = await roleRepository.updateRole({
      "id": role.id,
      "name": name,
      "description": description,
      'permissions': permissions
    });
    result.fold(logger.e, (r) {
      _roles.removeWhere((e) => e.id == r.id);
      _roles.add(r);
      logger.i("Role ${r.name} updated successfully");
      notifyListeners();
    });
    return result;
  }

  Future<Either<Failure, Role>> saveRole(
      String name, String description, List<String> permissions) async {
    final result = await roleRepository.saveRole({
      "name": name,
      "description": description,
      'permissions': permissions,
    });
    result.fold(logger.e, (r) {
      _roles.add(r);
      logger.i("Role ${r.name} saved successfully");
      notifyListeners();
    });
    return result;
  }

  Future<Either<Failure, void>> deleteRole(Role role) async {
    final res = await roleRepository.deleteRole(role.id);
    res.fold(logger.e, (r) {
      _roles.removeWhere((e) => e.id == role.id);
      notifyListeners();
    });
    return res;
  }

  Future<Either<Failure, void>> deleteRoles(List<Role> roles) async {
    final res =
        await roleRepository.deleteRoles(roles.map((e) => e.id).toList());
    res.fold(logger.e, (r) {
      _roles.removeWhere((element) => roles.contains(element));
      notifyListeners();
    });
    return res;
  }
}
