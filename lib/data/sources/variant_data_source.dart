import '/constants.dart';
import '/domain/models/variation.dart';

class VariationDataSource {
  final table = "variants";

  Future<List<Variation>> getVariations() async {
    final data = await supabase.from(table).select();
    return data.map(Variation.fromMap).toList();
  }

  Future<Variation> getVariation(int id) async {
    final data = await supabase.from(table).select().single().limit(1);
    return Variation.fromMap(data);
  }

  Future<Variation> saveVariation(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .upsert(map, onConflict: 'id')
        .select()
        .single();
    return Variation.fromMap(data);
  }

  Future<Variation> updateVariation(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .update(map)
        .eq("id", map['id'])
        .select()
        .single();
    return Variation.fromMap(data);
  }

  Future<void> deleteVariation(int id) async {
    await supabase.from(table).delete().eq("id", id);
  }
}
