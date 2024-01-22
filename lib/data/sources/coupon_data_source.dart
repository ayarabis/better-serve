import '/constants.dart';
import '/domain/models/coupon.dart';

class CouponDataSource {
  final table = "coupons";

  Future<List<Coupon>> getCoupons() async {
    final data = await supabase.from(table).select();
    return data.map(Coupon.fromMap).toList();
  }

  Future<Coupon?> getCouponByCode(String code) async {
    final data = await supabase.from(table).select().eq("code", code);
    if (data.isNotEmpty) {
      return Coupon.fromMap(data.first);
    }
    return null;
  }

  Future<Coupon> saveCoupon(Map<String, dynamic> map) async {
    if (map['id'] == null) map.remove('id');
    final data = await supabase
        .from(table)
        .upsert(map, onConflict: 'id')
        .select()
        .single();

    return Coupon.fromMap(data);
  }

  Future<void> deleteCoupon(int id) async {
    await supabase.from(table).delete().eq("id", id);
  }

  Future<void> deleteCoupons(List<int> ids) async {
    await supabase.from(table).delete().inFilter("id", ids);
  }
}
