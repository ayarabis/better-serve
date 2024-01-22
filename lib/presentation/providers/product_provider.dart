import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/constants.dart';
import '/core/extenstions.dart';
import '../../data/models/failure.dart';
import '/data/repositories/product_repository_impl.dart';
import '/data/sources/product_data_source.dart';
import '/domain/models/attribute.dart';
import '/domain/models/product.dart';
import '/domain/models/variation.dart';
import '/presentation/providers/auth_provider.dart';

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
    subscribeToProductsChange();
  }

  void subscribeToProductsChange() {
    final channel = supabase.channel(tenantId!);

    channel
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'products',
            callback: (payload, [ref]) {
              loadProducts();
            })
        .subscribe();
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
      String name,
      double price,
      int categoryId,
      Variation? variation,
      List<Attribute> attributes,
      String? imageUrl,
      bool allowAddon) async {
    double basePrice = variation?.basePrice ?? price;

    if (variation != null) {
      await insertVariation(null, variation);
    }

    final res = await _productRepository.save({
      "name": name,
      "category_id": categoryId,
      "base_price": basePrice,
      "img_url": imageUrl,
      "allow_addon": allowAddon
    });
    res.fold(logger.e, (r) async {
      await insertExtras(r.id, variation, attributes);
      _products.add(r);

      logger.i("Product saved successfully");

      notifyListeners();
    });
  }

  Future<void> updateProduct(
      int id,
      String name,
      double price,
      int categoryId,
      Variation? variation,
      List<Attribute> attributes,
      String? imageUrl,
      bool allowAddon) async {
    var basePrice = variation?.basePrice ?? price;
    if (variation != null) {
      await insertVariation(id, variation);
    }

    final res = await _productRepository.update({
      "id": id,
      "name": name,
      "category_id": categoryId,
      "base_price": basePrice,
      "img_url": imageUrl,
      "allow_addon": allowAddon
    });

    res.fold(logger.e, (r) async {
      await _productRepository.deleteAttributes(r.id);

      await insertExtras(id, variation, attributes);
      var index = _products.indexWhere((e) => e.id == id);
      _products[index] = r;

      logger.i("Product updated successfully");

      notifyListeners();
    });
  }

  Future<void> insertExtras(
      int productId, Variation? variation, List<Attribute> attributes) async {
    if (variation != null) {
      var index = 0;
      await _productRepository.saveVariationOptions(variation.options
          .map((e) => {
                "variation_id": variation.id,
                "value": e.value,
                "price": e.price,
                "is_selected": e.isSelected,
                "order": index++
              })
          .toList());
    }
    if (attributes.isNotEmpty) {
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
  }

  Future<int?> insertVariation(int? productId, Variation variation) async {
    if (productId != null) await deleteVariation(productId);

    final res = await _productRepository.saveVariation({
      "name": variation.name,
      'product_id': productId,
    });
    return await res.fold((l) => null, (id) async {
      await _productRepository.saveVariationOptions(variation.options
          .map((e) => {
                "variation_id": id,
                "value": e.value,
                "price": e.price,
                "is_selected": e.isSelected,
              })
          .toList());

      return id;
    });
  }

  Future<void> deleteVariation(int id) async {
    await _productRepository.deleteVariation(id);
  }

  Future<Either<Failure, void>> deleteProducts(List<Product> products) async {
    final result = await _productRepository
        .deleteProducts(products.map((e) => e.id).toList());

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
    }, items.map((e) => e.id).toList());

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
