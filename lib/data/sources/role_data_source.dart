import '/constants.dart';
import '/domain/models/role.dart';

class RoleDataSource {
  final table = "roles";

  Future<List<Role>> getRoles() async {
    final data = await supabase.from(table).select();
    return data.map(Role.fromMap).toList();
  }

  Future<Role> getRole(int id) async {
    final data = await supabase.from(table).select().single().limit(1);
    return Role.fromMap(data);
  }

  Future<Role> createRole(Map<String, dynamic> map) async {
    final data = await supabase.from(table).insert(map).select().single();
    return Role.fromMap(data);
  }

  Future<Role> updateRole(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .update(map)
        .eq("id", map['id'])
        .select()
        .single();
    return Role.fromMap(data);
  }

  Future<void> deleteRole(int id) async {
    await supabase.from(table).delete().eq("id", id);
  }

  Future<void> deleteRoles(List<int> list) async {
    await supabase.from(table).delete().inFilter("id", list);
  }
}
