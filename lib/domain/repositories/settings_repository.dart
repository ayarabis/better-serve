import 'package:fpdart/fpdart.dart';

import '../../data/models/failure.dart';
import '../models/setting.dart';

abstract class SettingsRepository {
  Future<Either<Failure, List<Setting>>> all();
}
