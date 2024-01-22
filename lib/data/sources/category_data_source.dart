import '/constants.dart';
import '/domain/models/category.dart';

class CategoryDataSource {
  final table = "categories";
  final sql = "*,products(count)";

  Future<List<Category>> getCategories() async {
    final data = await supabase.from(table).select(sql);
    return data.map(Category.fromMap).toList();
  }

  Future<Category> getCategory(int id) async {
    final data = await supabase.from(table).select().single().limit(1);
    return Category.fromMap(data);
  }

  Future<Category> saveCategory(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .upsert(map, onConflict: 'id')
        .select()
        .single();
    return Category.fromMap(data);
  }

  Future<Category> updateCategory(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .update(map)
        .eq("id", map['id'])
        .select()
        .single();
    return Category.fromMap(data);
  }

  Future<void> deleteCategory(int id) async {
    await supabase.from(table).delete().eq("id", id);
  }

  Future<int> getLastOrder() async {
    final data = await supabase
        .from(table)
        .select("order")
        .order("order", ascending: false)
        .limit(1);
    if (data.isEmpty) return 0;
    return data[0]['order'];
  }
}
