import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/data/repositories/attribute_repository_impl.dart';
import '/data/sources/attribute_data_source.dart';
import '/domain/models/attribute.dart';

class AttributeProvider with ChangeNotifier {
  static final AttributeProvider _instance = AttributeProvider._internal();
  factory AttributeProvider() => _instance;
  AttributeProvider._internal() {
    initService();
  }

  final AttributeRepositoryImpl _attributeRepositoryImpl =
      AttributeRepositoryImpl(source: AttributeDataSource());

  final List<Attribute> _attributes = [];
  List<Attribute> get attributes => _attributes;

  bool isLoading = false;

  Future<void> initService() async {
    await loadAttributes();
  }

  Future<void> loadAttributes() async {
    isLoading = true;
    notifyListeners();
    _attributes.clear();
    var result = await _attributeRepositoryImpl.all();
    result.fold(logger.e, (r) => _attributes.addAll(r));
    isLoading = false;
    notifyListeners();
  }

  Future<Either<Failure, Attribute>> saveAttribute(Attribute attribute) async {
    final result = await _attributeRepositoryImpl.save(attribute.toMap());
    result.fold(logger.e, (r) {
      if (attribute.id != null) {
        _attributes.removeWhere((e) => e.id == r.id);
      }
      _attributes.add(r);
      logger.i("Attribute ${r.name} saved successfully");
      notifyListeners();
    });
    return result;
  }

  Future<Either<Failure, void>> deleteAttribute(int id) async {
    final result = await _attributeRepositoryImpl.delete(id);
    result.fold(logger.e, (r) {
      _attributes.removeWhere((e) => e.id == id);
      logger.i("Attribute deleted successfully");
      notifyListeners();
    });
    return result;
  }

  void remove(Attribute attribute) {
    attributes.remove(attribute);
  }
}
