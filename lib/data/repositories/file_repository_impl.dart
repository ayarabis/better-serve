import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/file_repository.dart';
import '../sources/file_data_source.dart';
import '../models/failure.dart';

class FileRepositoryImpl extends FileRepository {
  FileDataSouce source;

  FileRepositoryImpl({
    required this.source,
  });

  @override
  Future<Either<Failure, List<String>>> getFiles(
      String bucket, String path) async {
    try {
      final res = await source.getFiles(bucket, path);
      return Right(res);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> upload(
      File file, String bucket, String path) async {
    try {
      return Right(await source.uploadFile(file, bucket, path));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> delete(
      String bucket, List<String> paths) async {
    try {
      return Right(await source.deleteFile(bucket, paths));
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
