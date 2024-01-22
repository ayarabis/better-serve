import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';

abstract class FileRepository {
  Future<Either<Failure, List<String>>> getFiles(String bucket, String path);
  Future<Either<Failure, String>> upload(File file, String bucket, String path);
  Future<Either<Failure, void>> delete(String bucket, List<String> paths);
}
