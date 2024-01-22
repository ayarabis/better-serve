import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/failure.dart';
import '/data/sources/product_data_source.dart';
import '/domain/models/product.dart';
import '/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductDataSource source;

  ProductRepositoryImpl({
    required this.source,
  });

  @override
  Future<Either<Failure, List<Product>>> all() async {
    try {
      return Right(await source.getProducts());
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Product>> one(int id) async {
    try {
      return Right(await source.getProductById(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Product>> update(Map<String, dynamic> map) async {
    try {
      return Right(await source.updateProduct(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(int id) async {
    try {
      return Right(await source.deleteProduct(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Product>> save(Map<String, dynamic> map) async {
    try {
      return Right(await source.saveProduct(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttributes(int id) async {
    try {
      return Right(await source.deleteProductAttributes(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> saveVariation(Map<String, dynamic> map) async {
    try {
      return Right(await source.insertVariation(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveVariationOptions(
      List<Map<String, dynamic>> list) async {
    try {
      return Right(await source.insertVariationOptions(list));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, int>> savetAttributes(Map<String, dynamic> map) async {
    try {
      return Right(await source.insertAttributes(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveAttributeOptions(
      List<Map<String, dynamic>> list) async {
    try {
      return Right(await source.insertAttributeOptions(list));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVariation(int productId) async {
    try {
      return Right(await source.deleteVariation(productId));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, void>> deleteProducts(List<int> list) async {
    try {
      return Right(await source.deleteProducts(list));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, List<Product>>> batchUpdate(
      Map<String, int> map, List<int> list) async {
    try {
      return Right(await source.batchUpdate(map, list));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
