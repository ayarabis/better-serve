import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';

import '/constants.dart';
import '../../data/models/failure.dart';
import '/core/pallete.dart';
import '../../core/config/settings.dart';
import '/data/repositories/settings_repository_impl.dart';
import '/data/sources/settings_data_source.dart';
import 'auth_provider.dart';

class SettingProvider with ChangeNotifier {
  static final SettingProvider _instance = SettingProvider._internal();
  factory SettingProvider() => _instance;
  SettingProvider._internal();

  final SettingRepositoryImpl _repository =
      SettingRepositoryImpl(source: SettingsDataSource());

  bool isDirty = false;

  Future<Settings> init() async {
    await loadSettings();
    notifyListeners();
    return settings;
  }

  Future<void> loadSettings() async {
    final res = await _repository.all();
    res.fold(logger.e, (sets) {
      settings.load(sets);
      setDirty(false);
    });
  }

  Color get primaryColor =>
      Pallete.hexToColor(settings.valueOf(Settings.appThemeColor));

  void setPrimaryColor(Color color) {
    isDirty = true;
    settings.setValue(Settings.appThemeColor,
        '#${color.value.toRadixString(16).substring(2)}');
    notifyListeners();
  }

  ImageProvider get logo => settings.hasValue(Settings.companyLogoUrl)
      ? NetworkImage(settings.valueOf(Settings.companyLogoUrl))
      : Image.asset('assets/images/logo.png').image;

  ThemeMode get themeMode {
    if (settings.has(Settings.appThemeInterface)) {
      switch (settings.valueOf(Settings.appThemeInterface)) {
        case "dark":
          return ThemeMode.dark;
        case "light":
          return ThemeMode.light;
        case "system":
          return ThemeMode.system;
      }
    }
    return ThemeMode.system;
  }

  SettingProvider setValue<T>(String key, T value) {
    settings.setValue(key, value);
    isDirty = true;
    notifyListeners();
    return this;
  }

  Future<Either<Failure, void>> save() async {
    final result = await _repository.saveSettings(
        settings
            .getEntries()
            .filter((t) => t.value != null)
            .map((e) => {
                  "id": e.id,
                  "key": e.key,
                  "value": e.value,
                })
            .toList(),
        tenantId!);
    result.fold(logger.e, (r) {
      settings.load(r);
      isDirty = false;
      notifyListeners();
    });
    return result;
  }

  void setDirty(bool dirty) {
    isDirty = dirty;
    notifyListeners();
  }

  T valueOf<T>(String key) {
    return settings.valueOf(key);
  }
}
