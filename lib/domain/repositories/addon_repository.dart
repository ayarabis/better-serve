import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';
import '../models/addon.dart';

abstract class AddonRepository {
  Future<Either<Failure, List<Addon>>> all();
  Future<Either<Failure, Addon>> one(int id);
  Future<Either<Failure, Addon>> save(Map<String, dynamic> map);
  Future<Either<Failure, void>> delete(int id);
  Future<Either<Failure, void>> deleteMany(List<int> ids);
}
