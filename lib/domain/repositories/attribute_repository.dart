import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';
import '/domain/models/attribute.dart';

abstract class AttributeRepository {
  Future<Either<Failure, List<Attribute>>> all();
  Future<Either<Failure, Attribute>> one(int i);
  Future<Either<Failure, Attribute>> save(Map<String, dynamic> map);
  Future<Either<Failure, void>> delete(int id);
}
