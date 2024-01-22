import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/data/repositories/coupon_repository_impl.dart';
import '/data/sources/coupon_data_source.dart';
import '/domain/models/coupon.dart';

class CouponProvider with ChangeNotifier {
  static final CouponProvider _instance = CouponProvider._internal();
  factory CouponProvider() => _instance;
  CouponProvider._internal() {
    loadCoupons();
  }

  final CouponRepositoryImpl _couponRepository =
      CouponRepositoryImpl(source: CouponDataSource());

  List<Coupon> _coupons = [];
  List<Coupon> get coupons => _coupons;

  bool isLoading = false;

  Future<void> loadCoupons() async {
    isLoading = true;
    notifyListeners();
    final res = await _couponRepository.all();
    res.fold(logger.e, (r) {
      _coupons = r;
    });
    isLoading = false;
    notifyListeners();
  }

  Future<Either<Failure, void>> deleteCoupon(Coupon coupon) async {
    final res = await _couponRepository.delete(coupon.id!);
    res.fold(logger.e, (r) {
      _coupons.remove(coupon);
      notifyListeners();
    });
    return res;
  }

  Future<Either<Failure, Coupon>> saveCoupon(
    Coupon coupon,
  ) async {
    final res = await _couponRepository.save(coupon.toMap());
    res.fold(logger.e, (r) {
      if (coupon.id != null) {
        _coupons.removeWhere((e) => e.id == coupon.id);
      }
      _coupons.add(r);
      notifyListeners();
    });
    return res;
  }

  Future<Either<Failure, void>> deleteCoupons(List<Coupon> coupons) async {
    final result = await _couponRepository
        .deleteCoupons(coupons.map((e) => e.id!).toList());
    result.fold(logger.e, (r) {
      _coupons.removeWhere((element) => coupons.contains(element));
      logger.i("${coupons.length} addon(s) deleted successfully");
      notifyListeners();
    });
    return result;
  }
}
