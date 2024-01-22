import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/core/util.dart';
import '/data/repositories/file_repository_impl.dart';
import '/data/repositories/profile_repository_impl.dart';
import '/data/sources/file_data_source.dart';
import '/data/sources/user_data_source.dart';
import '/domain/models/profile.dart';
import 'auth_provider.dart';

class UserProvider with ChangeNotifier {
  static final UserProvider _instance = UserProvider._internal();
  factory UserProvider() => _instance;
  UserProvider._internal() {
    loadUsers();
  }

  final ProfileRepositoryImpl _userRepository =
      ProfileRepositoryImpl(source: UserDataSource());
  final FileRepositoryImpl _mediaRepositoryImpl =
      FileRepositoryImpl(source: FileDataSouce());

  final List<Profile> _users = [];
  List<Profile> get users => _users;

  bool isLoading = false;

  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();
    var res = await _userRepository.all();
    res.fold(logger.e, (r) {
      _users.addAll(r);
    });
    isLoading = false;
    notifyListeners();
  }

  Future<Either<Failure, Profile>> saveUser(
      Profile profile, File? avatarImg) async {
    if (avatarImg != null) {
      final res =
          await _mediaRepositoryImpl.upload(avatarImg, "avatar", tenantId!);
      res.fold(logger.e, (key) {
        final name = basename(key);
        profile.avatarUrl = publicPath(name, "avatar");
      });
    }
    final res = await _userRepository.save(profile);
    res.fold(logger.e, (r) {
      if (profile.id != null) {
        _users.removeWhere((e) => e.id == profile.id);
      }
      _users.add(r);
      notifyListeners();
    });
    return res;
  }

  Future<Either<Failure, void>> deleteUser(Profile profile) async {
    final res = await _userRepository.delete(profile.id!);
    res.fold(logger.e, (r) {
      _users.removeWhere((e) => e.id == profile.id);
      notifyListeners();
    });
    return res;
  }
}
