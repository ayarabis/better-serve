import 'dart:collection';

import 'package:better_serve/constants.dart';

import '/domain/models/setting.dart';

class Settings {
  final Map<String, Setting> _settings = HashMap();

  static final Settings _instance = Settings._internal();
  factory Settings() => _instance;
  Settings._internal() {
    _set(Settings.companyName, "");
    _set(Settings.companyAddress, "");
    _set(Settings.companyVatRegistration, "");
    _set(Settings.shopShowItemPrice, false);
    _set(Settings.shopShowQuickView, true);
    _set(Settings.shopEnableQuickAdd, true);
    _set(Settings.shopGridSize, 6);
    _set(Settings.appThemeColor, "#00aaff");
    _set(Settings.appThemeInterface, "system");
  }

  void load(List<Setting> settings) {
    if (settings.isEmpty) return;
    for (var s in settings) {
      _set(s.key, s.value, s.id);
    }
  }

  void _set(String key, dynamic value, [int? id]) {
    final option = Setting(key, value, id);
    if (_settings.containsKey(key)) {
      _settings[key] = option;
    } else {
      _settings.addEntries([MapEntry(key, option)]);
    }
  }

  T? valueOf<T>(String key) {
    if (_settings.containsKey(key)) {
      return _settings[key]!.value as T;
    }
    return null;
  }

  void setValue<T>(String key, T? value) {
    var option = Setting(key, value);
    if (_settings.containsKey(key)) {
      option = _settings[key]!;
      option.value = value;
      logger.i(_settings[key]);
    } else {
      _settings.addEntries([MapEntry(key, option)]);
    }
  }

  Iterable<Setting> getEntries() {
    return _settings.values;
  }

  bool has(String key) {
    return _settings.containsKey(key);
  }

  bool hasValue(String key) {
    return _settings.containsKey(key) && _settings[key]!.value != null;
  }

  // company specific settings
  static String companyName = "company_name";
  static String companyAddress = "company_address";
  static String companyVatRegistration = "company_vat_registration";
  static String companyLogoUrl = "company_logo_url";

  // ordering interface settings
  static String shopShowItemPrice = "shop_show_item_price";
  static String shopShowQuickView = "shop_show_quick_view";
  static String shopEnableQuickAdd = "shop_enable_quick_add";
  static String shopGridSize = "shop_grid_size";

  // general application settings
  static String appThemeColor = "app_theme_color";
  static String appThemeInterface = "app_theme_interface";

  // other settings
  static String receiptLogoUrl = "receipt_logo_url";
  static String printerName = "printer_name";
}
