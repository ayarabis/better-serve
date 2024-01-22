import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';
import '../models/coupon.dart';

abstract class CouponRepository {
  Future<Either<Failure, List<Coupon>>> all();
  Future<Either<Failure, Coupon?>> one(String code);
  Future<Either<Failure, Coupon>> save(Map<String, dynamic> data);
  Future<Either<Failure, void>> delete(int couponId);
}
