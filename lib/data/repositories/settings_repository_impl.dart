import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../sources/settings_data_source.dart';
import '../models/failure.dart';
import '/domain/models/setting.dart';
import '/domain/repositories/settings_repository.dart';

class SettingRepositoryImpl implements SettingsRepository {
  final SettingsDataSource source;

  SettingRepositoryImpl({
    required this.source,
  });

  @override
  Future<Either<Failure, List<Setting>>> all() async {
    try {
      var list = await source.getSetting();
      return Right(list);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }

  Future<Either<Failure, List<Setting>>> saveSettings(
      List<Map<String, dynamic>> settings, String tenantId) async {
    try {
      final result = await source.saveSetting(settings, tenantId);
      return Right(result);
    } on PostgrestException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
