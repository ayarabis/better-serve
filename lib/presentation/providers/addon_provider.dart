import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/data/repositories/addon_repository_impl.dart';
import '/data/sources/addon_data_source.dart';
import '/domain/models/addon.dart';

class AddonProvider with ChangeNotifier {
  static final AddonProvider _instance = AddonProvider._internal();
  factory AddonProvider() => _instance;
  AddonProvider._internal() {
    initService();
  }

  final AddonRepositoryImpl _addonRepositoryImpl =
      AddonRepositoryImpl(source: AddonDataSource());

  final List<Addon> _addons = [];
  List<Addon> get addons => _addons;

  bool isLoading = false;

  Future<void> initService() async {
    await loadAddons();
  }

  Future<void> loadAddons() async {
    isLoading = true;
    notifyListeners();
    _addons.clear();
    var result = await _addonRepositoryImpl.all();
    result.fold(logger.e, (r) => _addons.addAll(r));
    isLoading = false;
    notifyListeners();
  }

  Future<Either<Failure, Addon>> saveAddon(Addon addon) async {
    final result = await _addonRepositoryImpl.save(addon.toMap());
    result.fold(logger.e, (r) {
      if (addon.id != null) {
        _addons.removeWhere((e) => e.id == r.id);
      }
      _addons.add(r);
      logger.i("Addon ${r.name} saved successfully");
      notifyListeners();
    });
    return result;
  }

  Future<Either<Failure, void>> deleteAddons(List<Addon> addons) async {
    final result = await _addonRepositoryImpl
        .deleteMany(addons.map((e) => e.id!).toList());
    result.fold(logger.e, (r) {
      _addons.removeWhere((element) => addons.contains(element));
      logger.i("${addons.length} addon(s) deleted successfully");
      notifyListeners();
    });
    return result;
  }
}
