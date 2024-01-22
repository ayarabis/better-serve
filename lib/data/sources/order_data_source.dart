import 'package:supabase_flutter/supabase_flutter.dart';

import '/constants.dart';
import '/core/enums/order_status.dart';
import '/domain/models/order.dart';
import '/domain/models/order_item.dart';
import '/domain/models/sale.dart';

class OrderDataSouce {
  final table = "orders";
  final tableOrderItems = "order_items";
  final tableOrderItemAttributes = "order_item_attributes";
  final tableOrderItemAddons = "order_item_addons";
  final tableOrderAddons = "order_addons";

  final String sql = '''
      *,order_items(*,product:product_id(*, category:category_id(*),
      variation:product_variations(*,options:product_variation_options(*)),
      attributes:product_attributes(*,options:product_attribute_options(*))),
      order_item_attributes(*),
      order_item_addons(*,addon:addon_id(*))),
      coupon:coupon_id(*)
''';

  Future<List<Order>> getOrders() async {
    final data = await supabase.from(table).select(sql);
    return data.map(Order.fromMap).toList();
  }

  Future<List<Order>> getOrdersByStatus(List<int> status) async {
    var builder = supabase.from(table).select(sql);

    builder = builder.inFilter('status', status);

    return (await builder).map(Order.fromMap).toList();
  }

  Future<Order> getOrderById(int id) async {
    final data =
        await supabase.from(table).select(sql).eq("id", id).limit(1).single();
    return Order.fromMap(data);
  }

  Future<Order> createOrder(Map<String, dynamic> map) async {
    final res = await supabase.from(table).insert(map).select(sql).single();
    return Order.fromMap(res);
  }

  Future<OrderItem> createOrderItem(Map<String, dynamic> map) async {
    final data =
        await supabase.from(tableOrderItems).insert(map).select().single();
    return OrderItem.fromMap(data);
  }

  Future<void> createOrderItemAttributes(
      List<Map<String, dynamic>> list) async {
    await supabase.from(tableOrderItemAttributes).insert(list);
  }

  Future<void> createOrderAddons(List<Map<String, dynamic>> list) async {
    await supabase.from(tableOrderItemAddons).insert(list);
  }

  Future<void> saveOrderCoupon(Map<String, dynamic> map) async {
    await supabase.from(tableOrderAddons).insert(map);
  }

  Future<void> updateOrderStatus(int id, OrderStatus status) async {
    await supabase.from(table).update({"status": status.ordinal}).eq("id", id);
  }

  Stream<List<Order>> get ordersAsStream => supabase
      .from(table)
      .select(sql)
      .eq("status", OrderStatus.done.ordinal)
      .asStream()
      .map((event) => event.map(Order.fromMap).toList());

  Stream<dynamic> get ordersCountAsStream => supabase
      .from("orders")
      .select("*")
      .eq("status", OrderStatus.done.ordinal)
      .count(CountOption.exact)
      .asStream();

  Future<Order> updateOrder(Map<String, dynamic> map) async {
    final data = await supabase
        .from(table)
        .update(map)
        .eq("id", map['id'])
        .select(sql)
        .single();
    return Order.fromMap(data);
  }

  Future<List<Sale>> getSalesReport(String fromDate) async {
    var data =
        await supabase.from("sales").select().gte("transaction_date", fromDate);
    return data.map(Sale.fromMap).toList();
  }

  Future<void> deleteOrder(int id) async {
    await supabase.from(table).delete().eq("id", id);
  }
}
