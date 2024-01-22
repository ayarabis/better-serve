import '/constants.dart';
import '/domain/models/attribute.dart';

class AttributeDataSource {
  final table = "attributes";

  Future<List<Attribute>> getAttributes() async {
    final data = await supabase.from(table).select();
    return data.map(Attribute.fromMap).toList();
  }

  Future<Attribute> getAttribute(int id) async {
    final data = await supabase.from(table).select().single().limit(1);
    return Attribute.fromMap(data);
  }

  Future<Attribute> saveAttribute(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .upsert(map, onConflict: 'id')
        .select()
        .single();
    return Attribute.fromMap(data);
  }

  Future<Attribute> updateAttribute(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .update(map)
        .eq("id", map['id'])
        .select()
        .single();
    return Attribute.fromMap(data);
  }

  Future<void> deleteAttribute(int id) async {
    await supabase.from(table).delete().eq("id", id);
  }
}
