import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '/constants.dart';
import '/core/extenstions.dart';
import '/data/models/failure.dart';
import '/data/repositories/product_repository_impl.dart';
import '/data/sources/product_data_source.dart';
import '/domain/models/attribute.dart';
import '/domain/models/product.dart';
import '/domain/models/variation.dart';

class ProductProvider with ChangeNotifier {
  static final ProductProvider _instance = ProductProvider._internal();
  factory ProductProvider() => _instance;
  ProductProvider._internal() {
    initService();
  }

  final ProductRepositoryImpl _productRepository =
      ProductRepositoryImpl(source: ProductDataSource());

  bool isLoading = true;
  final List<Product> _products = [];
  List<Product> get products => _products;

  Future<void> initService() async {
    await loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading = true;
    notifyListeners();
    _products.clear();
    var res = await _productRepository.all();
    res.fold((l) {
      throw l;
    }, (r) {
      _products.addAll(r);
    });
    isLoading = false;
    notifyListeners();
  }

  Future<void> saveProduct(
      int? id,
      String name,
      double price,
      int categoryId,
      Variation? variation,
      List<Attribute> attributes,
      String? imageUrl,
      bool allowAddon) async {
    double basePrice = variation?.basePrice ?? price;

    (await _productRepository.save({
      if (id != null) ...{'id': id},
      "name": name,
      "category_id": categoryId,
      "base_price": basePrice,
      "img_url": imageUrl,
      "allow_addon": allowAddon
    }))
        .fold(logger.e, (product) async {
      await Future.wait<dynamic>([
        if (id != null) _productRepository.removeAttributes(id),
        if (id != null) _productRepository.removeVariation(id),
        saveVariation(product.id!, variation),
        saveAttributes(product.id!, attributes),
      ]);

      final res = await _productRepository.one(product.id!);
      res.fold(logger.e, (r) {
        _products.add(r);
      });

      logger.i("Product saved successfully");

      notifyListeners();
    });
  }

  Future<void> saveAttributes(int productId, List<Attribute> attributes) async {
    if (attributes.isEmpty) return;

    for (Attribute attr in attributes.toList()) {
      final res = await _productRepository.savetAttributes({
        "product_id": productId,
        "name": attr.name,
        "is_multiple": attr.isMultiple
      });
      await res.fold((l) => null, (r) async {
        int index = 0;
        await _productRepository.saveAttributeOptions(attr.options
            .map((e) => {
                  "attribute_id": r,
                  "value": e.value,
                  "is_selected": e.isSelected,
                  "order": index++
                })
            .toList());
      });
    }
  }

  Future<void> saveVariation(int productId, Variation? variation) async {
    if (variation == null) return;

    final res = await _productRepository.saveVariation({
      "name": variation.name,
      'product_id': productId,
    });
    await res.fold((l) => null, (id) async {
      await _productRepository.saveVariationOptions(variation.options
          .map((e) => {
                "variation_id": id,
                "value": e.value,
                "price": e.price,
                "is_selected": e.isSelected,
              })
          .toList());
    });
  }

  Future<Either<Failure, void>> deleteProducts(List<Product> products) async {
    final result = await _productRepository
        .deleteProducts(products.map((e) => e.id!).toList());

    result.fold(logger.e, (r) async {
      for (var element in products) {
        _products.removeWhere((e) => e.id == element.id);
      }
      notifyListeners();
    });
    return result;
  }

  Future<Either<Failure, List<Product>>> changeCategory(
      List<Product> items, int categoryId) async {
    var res = await _productRepository.batchUpdate({
      "category_id": categoryId,
    }, items.map((e) => e.id!).toList());

    res.fold(logger.e, (r) {
      for (var product in r) {
        var index = _products.indexWhere((e) => e.id == product.id);
        _products.removeAt(index);
        _products.insert(index, product);
      }
      notifyListeners();
    });
    return res;
  }
}
