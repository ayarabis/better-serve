import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/core/util.dart';
import '/data/repositories/file_repository_impl.dart';
import '/data/sources/file_data_source.dart';
import 'auth_provider.dart';

class FileProvider with ChangeNotifier {
  static final FileProvider _instance = FileProvider._internal();
  factory FileProvider() => _instance;
  FileProvider._internal() {
    initService();
  }

  FileRepositoryImpl mediaRepository =
      FileRepositoryImpl(source: FileDataSouce());
  AuthProvider authProvider = AuthProvider();

  bool isLoading = false;

  final List<String> _images = [];
  List<String> get images => _images;

  Future<void> initService() async {
    await loadMedia();
  }

  Future<void> loadMedia() async {
    isLoading = true;
    notifyListeners();

    _images.clear();
    var productsMedia = await mediaRepository.getFiles("images", tenantId!);

    productsMedia.fold(logger.e, (r) => _images.addAll(r));

    isLoading = false;
    notifyListeners();
  }

  Future<Either<Failure, String>> upload(File pickedFile) async {
    final result =
        await mediaRepository.upload(pickedFile, "images", tenantId!);
    result.fold(logger.e, (key) async {
      final name = basename(key);
      _images.add(publicPath(name));
      notifyListeners();
    });
    return result;
  }

  Future<Either<Failure, void>> delete(List<String> urls) async {
    final result = await mediaRepository.delete(
        "images", urls.map((e) => "$tenantId/${basename(e)}").toList());
    result.fold((l) => null, (r) {
      for (var i = 0; i < urls.length; i++) {
        _images.remove(urls[i]);
      }
    });
    return result;
  }
}
