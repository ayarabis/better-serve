import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sources/coupon_data_source.dart';
import '/core/extenstions.dart';
import '../models/failure.dart';
import '/domain/models/coupon.dart';
import '/domain/repositories/coupon_repository.dart';

class CouponRepositoryImpl implements CouponRepository {
  final CouponDataSource source;

  CouponRepositoryImpl({
    required this.source,
  });

  @override
  Future<Either<Failure, List<Coupon>>> all() async {
    try {
      return Right(await source.getCoupons());
    } on PostgrestException catch (error) {
      return Left(Failure(error.message));
    }
  }

  @override
  Future<Either<Failure, Coupon?>> one(String code) async {
    try {
      final coupon = await source.getCouponByCode(code);
      if (coupon == null) {
        return const Left(Failure("Coupon not found"));
      } else if (coupon.expired) {
        return const Left(Failure("Coupon expired"));
      } else if (!coupon.available) {
        return const Left(Failure("Coupon invalid"));
      }
      return Right(coupon);
    } on PostgrestException catch (error) {
      return Left(Failure(error.message));
    }
  }

  @override
  Future<Either<Failure, Coupon>> save(Map<String, dynamic> map) async {
    try {
      return Right(await source.saveCoupon(map));
    } on PostgrestException catch (error) {
      return Left(Failure(error.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      return Right(await source.deleteCoupon(id));
    } on PostgrestException catch (error) {
      return Left(Failure(error.message));
    }
  }

  Future<Either<Failure, void>> deleteCoupons(List<int> list) async {
    try {
      return Right(await source.deleteCoupons(list));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
