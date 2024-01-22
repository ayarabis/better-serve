import '/constants.dart';
import '/domain/models/product.dart';

class ProductDataSource {
  final table = "products";
  final tableProductAttributes = "product_attributes";
  final tableProductVarations = "product_variations";
  final tableProductVariationOptions = "product_variation_options";
  final tableProductAttributeOptions = "product_attribute_options";

  final String sql = '''
      *,
      category:category_id(*),
      variation:product_variations(*, options:product_variation_options(*)),
      attributes:product_attributes(*, options:product_attribute_options(*))
''';

  Future<List<Product>> getProducts() async {
    final products =
        (await supabase.from(table).select(sql)).map(Product.fromMap).toList();
    return products;
  }

  Future<Product> getProductById(int id) async {
    final data = await supabase.from(table).select(sql).single().limit(1);
    return Product.fromMap(data);
  }

  Future<Product> saveProduct(Map<String, dynamic> map) async {
    final data = await supabase.from(table).insert(map).select(sql).single();

    return Product.fromMap(data);
  }

  Future updateProduct(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .update(map)
        .eq("id", map['id'])
        .select(sql)
        .single();

    return Product.fromMap(data);
  }

  Future<void> deleteProduct(int id) async {
    await supabase.from(table).delete().eq("id", id);
  }

  Future<void> deleteProductAttributes(int id) async {
    await supabase.from(tableProductAttributes).delete().eq("product_id", id);
  }

  Future<void> insertVariationOptions(List<Map<String, dynamic>> list) async {
    await supabase.from(tableProductVariationOptions).insert(list);
  }

  Future<int> insertAttributes(Map<String, dynamic> map) async {
    final res = await supabase
        .from(tableProductAttributes)
        .insert(map)
        .select()
        .single();
    return res['id'];
  }

  Future<void> insertAttributeOptions(List<Map<String, dynamic>> list) async {
    await supabase.from(tableProductAttributeOptions).insert(list);
  }

  Future<void> deleteVariation(int productId) async {
    await supabase
        .from(tableProductVarations)
        .delete()
        .eq("product_id", productId);
  }

  Future<int> insertVariation(Map<String, dynamic> map) async {
    final data = await supabase
        .from(tableProductVarations)
        .insert(map)
        .select()
        .single();
    return data['id'];
  }

  Future<void> deleteProducts(List<int> list) async {
    await supabase.from(table).delete().inFilter("id", list);
  }

  Future<List<Product>> batchUpdate(
      Map<String, int> map, List<int> list) async {
    final data =
        await supabase.from(table).update(map).inFilter("id", list).select(sql);

    return data.map(Product.fromMap).toList();
  }
}
