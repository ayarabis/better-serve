import '/constants.dart';
import '/domain/models/addon.dart';

class AddonDataSource {
  final table = "addons";

  Future<List<Addon>> getAddons() async {
    final data = await supabase.from(table).select();
    return data.map(Addon.fromMap).toList();
  }

  Future<Addon> getAddon(int id) async {
    final data = await supabase.from(table).select().single().limit(1);
    return Addon.fromMap(data);
  }

  Future<Addon> saveAddon(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .upsert(map, onConflict: 'id')
        .select()
        .single();
    return Addon.fromMap(data);
  }

  Future<void> deleteAddon(int id) async {
    await supabase.from(table).delete().eq("id", id);
  }

  Future<void> deleteAddons(List<int> list) async {
    await supabase.from(table).delete().inFilter("id", list);
  }
}
