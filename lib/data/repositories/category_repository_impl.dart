import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sources/category_data_source.dart';
import '../models/failure.dart';
import '/domain/models/category.dart';
import '/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryDataSource source;

  CategoryRepositoryImpl({required this.source});

  @override
  Future<Either<Failure, List<Category>>> all() async {
    try {
      return Right(await source.getCategories());
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Category>> one(int id) async {
    try {
      return Right(await source.getCategory(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Category>> save(Map<String, dynamic> map) async {
    try {
      return Right(await source.saveCategory(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Category>> update(Map<String, dynamic> map) async {
    try {
      return Right(await source.updateCategory(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      return Right(await source.deleteCategory(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, int>> getLastOrder() async {
    try {
      return Right(await source.getLastOrder());
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
