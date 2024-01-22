import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/data/repositories/category_repository_impl.dart';
import '/data/sources/category_data_source.dart';
import '/domain/models/category.dart';
import '/presentation/providers/auth_provider.dart';

class CategoryProvider with ChangeNotifier {
  static final CategoryProvider _instance = CategoryProvider._internal();
  factory CategoryProvider() => _instance;
  CategoryProvider._internal() {
    initService();
  }

  final CategoryRepositoryImpl _categoryRepositoryImpl =
      CategoryRepositoryImpl(source: CategoryDataSource());

  final List<Category> _categories = [];
  List<Category> get categories => _categories;

  Category? activeCategory;
  bool isLoading = true;

  Future<void> initService() async {
    await loadCategories();
    subscribeToProductsChange();
  }

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();
    _categories.clear();
    final result = await _categoryRepositoryImpl.all();
    result.fold(logger.e, (r) {
      _categories.addAll(r);
      _categories.sort((a, b) => a.order.compareTo(b.order));
    });
    isLoading = false;
    notifyListeners();
  }

  void subscribeToProductsChange() {
    final channel = supabase.channel(tenantId!);

    channel
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'products',
            callback: (payload, [ref]) {
              loadCategories();
            })
        .subscribe();
  }

  Future<void> saveCategory(Category category) async {
    final result = await _categoryRepositoryImpl.save(category.toMap());
    result.fold(logger.e, (category) {
      if (category.id != null) {
        _categories.removeWhere((e) => e.id == category.id);
      }
      _categories.add(category);
      logger.i("Category ${category.name} saved successfully");
      notifyListeners();
    });
  }

  Future<Either<Failure, void>> deleteCategory(Category category) async {
    final result = await _categoryRepositoryImpl.delete(category.id!);
    result.fold(logger.e, (_) {
      _categories.removeWhere((element) => element.id == category.id);
      logger.i("Category ${category.name} deleted successfully");
      notifyListeners();
    });
    return result;
  }

  Future<void> swapOrder(int oldIndex, int newIndex) async {
    Category category = categories[oldIndex];

    categories.removeAt(oldIndex);
    categories.insert(newIndex, category);
    notifyListeners();

    for (int i = 0; i < categories.length; i++) {
      await _categoryRepositoryImpl
          .update({"id": categories[i].id, "order": i});
    }
  }

  void setActiveCategory(Category? category) {
    activeCategory = category;
    notifyListeners();
  }
}
