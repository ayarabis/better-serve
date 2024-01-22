import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sources/variant_data_source.dart';
import '../models/failure.dart';
import '/domain/models/variation.dart';
import '/domain/repositories/variant_provider.dart';

class VariationRepositoryImpl implements VariantRepository {
  VariationDataSource source;

  VariationRepositoryImpl({required this.source});

  @override
  Future<Either<Failure, List<Variation>>> all() async {
    try {
      return Right(await source.getVariations());
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Variation>> one(int id) async {
    try {
      return Right(await source.getVariation(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, Variation>> save(Map<String, dynamic> map) async {
    try {
      return Right(await source.saveVariation(map));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      return Right(await source.deleteVariation(id));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
