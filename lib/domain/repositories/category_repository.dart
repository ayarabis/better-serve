import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';
import '../models/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> all();
  Future<Either<Failure, Category>> one(int categoryId);
  Future<Either<Failure, Category>> save(Map<String, dynamic> data);
  Future<Either<Failure, Category>> update(Map<String, dynamic> data);
  Future<Either<Failure, void>> delete(int categoryId);
}
