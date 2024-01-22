import 'package:fpdart/fpdart.dart' show Either;

import '../../data/models/failure.dart';
import '../models/cart_item.dart';
import '../models/coupon.dart';
import '../../data/models/discount.dart';
import '../models/order.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<Order>>> all();
  Future<Either<Failure, List<Order>>> whereStatus(List<int> status);
  Future<Either<Failure, Order>> one(int orderId);
  Future<Either<Failure, Order>> save(List<CartItem> items, Discount? discount,
      double paymentAmount, Coupon? coupon, bool hold);
  Future<Either<Failure, Order>> update(Map<String, dynamic> data);
  Future<Either<Failure, void>> delete(int orderId);
}
