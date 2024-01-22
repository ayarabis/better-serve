import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';
import '../models/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> all();
  Future<Either<Failure, Product>> one(int productId);
  Future<Either<Failure, Product>> save(Map<String, dynamic> data);
  Future<void> deleteProduct(int id);
  Future<Either<Failure, int>> saveVariation(Map<String, dynamic> data);
  Future<Either<Failure, void>> saveVariationOptions(
      List<Map<String, dynamic>> data);
  Future<Either<Failure, int>> savetAttributes(Map<String, dynamic> data);
  Future<Either<Failure, void>> saveAttributeOptions(
      List<Map<String, dynamic>> data);
  Future<Either<Failure, void>> removeAttributes(int productId);
  Future<Either<Failure, void>> removeVariation(int productId);
}
