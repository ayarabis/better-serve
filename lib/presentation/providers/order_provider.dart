import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' show Either;
import 'package:supabase_flutter/supabase_flutter.dart';

import '/constants.dart';
import '/core/enums/order_status.dart';
import '/core/extenstions.dart';
import '../../data/models/failure.dart';
import '/data/models/discount.dart';
import '/data/repositories/order_repository_impl.dart';
import '/data/sources/order_data_source.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/coupon.dart';
import '/domain/models/order.dart';
import '/domain/models/sale.dart';
import '/presentation/providers/auth_provider.dart';

class OrderProvider with ChangeNotifier {
  static final OrderProvider _instance = OrderProvider._internal();
  factory OrderProvider() => _instance;
  OrderProvider._internal() {
    initialize();
  }

  OrderRepositoryImpl orderRepositoryImpl =
      OrderRepositoryImpl(source: OrderDataSouce());

  final List<Order> _ongoingOrders = [];
  List<Order> get ongoingOrders => _ongoingOrders;

  final List<Order> _onHoldOrders = [];
  List<Order> get onHoldOrders => _onHoldOrders;

  Future<void> initialize() async {
    await loadOrders();
    subscribeToStatusChange();
  }

  Future<void> loadOrders() async {
    _ongoingOrders.clear();
    _onHoldOrders.clear();

    final data = await orderRepositoryImpl.whereStatus([
      OrderStatus.pending.ordinal,
      OrderStatus.processing.ordinal,
      OrderStatus.onhold.ordinal,
    ]);

    data.fold(logger.e, (r) {
      _ongoingOrders.addAll(r.where((e) =>
          e.status == OrderStatus.pending.ordinal ||
          e.status == OrderStatus.processing.ordinal));
      _onHoldOrders
          .addAll(r.where((e) => e.status == OrderStatus.onhold.ordinal));
      notifyListeners();
    });
  }

  void subscribeToStatusChange() {
    final channel = supabase.channel(tenantId!);

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'orders',
          callback: (payload, [ref]) {
            loadOrders();
          },
        )
        .subscribe();
  }

  Future<Either<Failure, Order>> createOrder(List<CartItem> items,
      Discount? discount, double tenderAmount, Coupon? coupon,
      [bool hold = false]) async {
    final result = await orderRepositoryImpl.save(
        items, discount, tenderAmount, coupon, hold);
    result.fold(logger.e, (order) {
      logger.i("Order created: ${order.id}");
      _ongoingOrders.add(order);
    });
    return result;
  }

  Future<void> completeOrder(Order order) async {
    order.removing = true;
    notifyListeners();
    var res = await orderRepositoryImpl.update({
      'id': order.id,
      'status': 3,
    });

    res.fold((failure) {
      logger.e(failure.message);
      primaryContext.showErrorSnackBar(message: failure.message);
    }, (r) {
      _ongoingOrders.remove(order);
    });
    notifyListeners();
  }

  Future<Sale> getSalesReport(String range) async {
    final dateNow = DateTime.now();
    String? fromDate;
    switch (range) {
      case "today":
        fromDate = dateFormat.format(dateNow);
        break;
      case "week":
        fromDate = dateFormat.format(dateNow.subtract(const Duration(days: 7)));
        break;
      case "month":
        fromDate =
            dateFormat.format(dateNow.subtract(const Duration(days: 30)));
        break;
      case "year":
        fromDate =
            dateFormat.format(dateNow.subtract(const Duration(days: 365)));
        break;
      default:
        fromDate = dateFormat.format(dateNow);
    }
    var res = await orderRepositoryImpl.getSalesReport(fromDate);
    var empty =
        Sale(orderCount: 0, itemCount: 0, orderAmount: 0, grandTotal: 0);
    return res.fold((failure) {
      logger.e(failure.message);
      return empty;
    }, (r) {
      if (r.isEmpty) {
        return empty;
      }
      return r.reduce((value, element) {
        value.itemCount += element.itemCount;
        value.orderCount += element.orderCount;
        value.orderAmount += element.orderAmount;
        value.grandTotal += element.grandTotal;
        return value;
      });
    });
  }

  Stream<List<Order>> get ordersAsStream => orderRepositoryImpl.ordersAsStream;
  Stream<dynamic> get ordersCountAsStream =>
      orderRepositoryImpl.ordersCountAsStream;

  Future<void> deleteOrder(int id) async {
    await orderRepositoryImpl.delete(id);
    _onHoldOrders.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
