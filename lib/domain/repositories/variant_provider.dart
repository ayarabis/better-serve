import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';
import '/domain/models/variation.dart';

abstract class VariantRepository {
  Future<Either<Failure, List<Variation>>> all();
  Future<Either<Failure, Variation>> one(int i);
  Future<Either<Failure, Variation>> save(Map<String, dynamic> map);
  Future<Either<Failure, void>> delete(int id);
}
