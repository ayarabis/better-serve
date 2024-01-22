import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sources/attribute_data_source.dart';
import '../models/failure.dart';
import '/domain/models/attribute.dart';
import '/domain/repositories/attribute_repository.dart';

class AttributeRepositoryImpl implements AttributeRepository {
  AttributeDataSource source;

  AttributeRepositoryImpl({required this.source});

  @override
  Future<Either<Failure, List<Attribute>>> all() async {
    try {
      return Right(await source.getAttributes());
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Attribute>> one(int id) async {
    try {
      return Right(await source.getAttribute(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Attribute>> save(Map<String, dynamic> map) async {
    try {
      return Right(await source.saveAttribute(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      return Right(await source.deleteAttribute(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
