import '/constants.dart';
import '/domain/models/setting.dart';

class SettingsDataSource {
  final table = "settings";

  Future<List<Setting>> getSetting() async {
    final data = await supabase.from(table).select();
    return data.map((e) => Setting.fromMap(e)).toList();
  }

  Future<List<Setting>> saveSetting(
      List<Map<String, dynamic>> list, String tenantId) async {
    list = list.map((e) {
      e["id"] ?? e.remove("id");
      return e;
    }).toList();
    final data =
        await supabase.from(table).upsert(list, onConflict: "id").select();
    return data.map((e) => Setting.fromMap(e)).toList();
  }
}
