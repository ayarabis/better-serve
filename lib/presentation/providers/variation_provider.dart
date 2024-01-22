import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/data/repositories/variant_repository_impl.dart';
import '/data/sources/variant_data_source.dart';
import '/domain/models/variation.dart';

class VariationProvider with ChangeNotifier {
  static final VariationProvider _instance = VariationProvider._internal();
  factory VariationProvider() => _instance;
  VariationProvider._internal() {
    initService();
  }

  final VariationRepositoryImpl _variationRepositoryImpl =
      VariationRepositoryImpl(source: VariationDataSource());

  final List<Variation> _variations = [];
  List<Variation> get variations => _variations;

  bool isLoading = false;

  Future<void> initService() async {
    await loadVariations();
  }

  Future<void> loadVariations() async {
    isLoading = true;
    notifyListeners();
    _variations.clear();
    var result = await _variationRepositoryImpl.all();
    result.fold(logger.e, (r) => _variations.addAll(r));
    isLoading = false;
    notifyListeners();
  }

  Future<Either<Failure, Variation>> saveVariation(Variation variation) async {
    final result = await _variationRepositoryImpl.save(variation.toMap());
    result.fold(logger.e, (r) {
      if (variation.id != null) {
        _variations.removeWhere((e) => e.id == r.id);
      }
      _variations.add(r);
      logger.i("Variation ${r.name} saved successfully");
      notifyListeners();
    });
    return result;
  }

  Future<Either<Failure, void>> deleteVariation(int id) async {
    final result = await _variationRepositoryImpl.delete(id);
    result.fold(logger.e, (r) {
      _variations.removeWhere((e) => e.id == id);
      logger.i("Variation deleted successfully");
      notifyListeners();
    });
    return result;
  }

  void remove(Variation variation) {
    variations.remove(variation);
  }
}
