import 'package:collection/collection.dart';
import 'package:fpdart/fpdart.dart' show Either, Left, Right;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/discount.dart';
import '/constants.dart';
import '/core/enums/discount_type.dart';
import '/core/enums/order_status.dart';
import '/core/extenstions.dart';
import '../models/failure.dart';
import '/data/sources/order_data_source.dart';
import '/domain/models/cart_item.dart';
import '/domain/models/coupon.dart';
import '/domain/models/order.dart';
import '/domain/models/order_item.dart';
import '/domain/models/sale.dart';
import '/domain/repositories/order_repository.dart';
import '/presentation/providers/auth_provider.dart';

class OrderRepositoryImpl extends OrderRepository {
  final OrderDataSouce source;

  OrderRepositoryImpl({
    required this.source,
  });

  @override
  Future<Either<Failure, List<Order>>> all() async {
    try {
      var data = await source.getOrders();
      return Right(data);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Order>> one(int orderId) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<Order>>> whereStatus(List<int> status) async {
    try {
      var data = await source.getOrdersByStatus(status);
      return Right(data);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Order>> save(List<CartItem> items, Discount? discount,
      double paymentAmount, Coupon? coupon, bool hold) async {
    try {
      double subTotal = items.fold(0, (v, e) => v + e.total);
      double? discountAmount = (discount != null
              ? discount.type == DiscountType.fixed
                  ? discount.value
                  : subTotal * (discount.value / 100)
              : null)
          ?.toDouble();
      double grandTotal = subTotal - (discount?.value ?? 0);
      grandTotal = grandTotal < 0 ? 0 : grandTotal;

      final now = DateTime.now();
      Order order = await source.createOrder({
        "item_count": items.length,
        "order_amount": subTotal,
        "grand_total": grandTotal,
        "payment_amount": paymentAmount,
        "discount_type": discount?.type.name,
        "discount_value": discount?.value,
        "discount_amount": discountAmount,
        "order_date": dateFormat.format(now),
        "order_time": timeFormat.format(now),
        "server_name": currentUser?.fullName,
        "user_id": currentUser?.id,
        "status": hold ? OrderStatus.onhold.index : OrderStatus.pending.index,
      });

      for (CartItem item in items) {
        OrderItem orderItem = await source.createOrderItem({
          "order_id": order.id,
          "quantity": item.quantity,
          "unit_price": item.price,
          "sub_total": item.total,
          "product_id": item.product.id,
          "product_name": item.product.name,
          "product_img_url": item.product.imgUrl,
          "variation_name": item.variation?.name,
          "variation_value": item.variation?.options
              .firstWhereOrNull((e) => e.isSelected)
              ?.value,
        });

        if (item.attributes.isNotEmpty) {
          await source.createOrderItemAttributes(item.attributes
              .map((e) => {
                    "order_item_id": orderItem.id,
                    "name": e.name,
                    "values": e.options
                        .where((opt) => opt.isSelected)
                        .map<String>((opt) => opt.value)
                        .toList()
                  })
              .toList());
        }

        if (item.addons.isNotEmpty) {
          await source.createOrderAddons(item.addons
              .map((e) => {
                    "order_item_id": orderItem.id,
                    "name": e.name,
                    "price": e.price,
                    "img_url": e.imgUrl,
                    "addon_id": e.id
                  })
              .toList());
        }

        if (coupon != null) {
          await source.saveOrderCoupon({
            "order_id": order.id,
            "coupon_data": coupon.toMap(),
          });
        }
      }

      order = await source.getOrderById(order.id);

      return Right(order);
    } on PostgrestException catch (error) {
      return Left(Failure(error.message));
    }
  }

  @override
  Future<Either<Failure, Order>> update(Map<String, dynamic> data) async {
    try {
      return Right(await source.updateOrder(data));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int orderId) async {
    try {
      return Right(await source.deleteOrder(orderId));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, List<Sale>>> getSalesReport(String fromDate) async {
    try {
      return Right(await source.getSalesReport(fromDate));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Stream<List<Order>> get ordersAsStream => source.ordersAsStream;
  Stream<dynamic> get ordersCountAsStream => source.ordersCountAsStream;
}
