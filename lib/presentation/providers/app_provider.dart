import 'package:flutter/material.dart';

import '/constants.dart';
import '/presentation/providers/auth_provider.dart';

class AppProvider with ChangeNotifier {
  static final AppProvider _instance = AppProvider._internal();
  factory AppProvider() => _instance;
  AppProvider._internal() {
    logger.i(("init app provider"));
  }

  String? currentRoute;

  String publicPath(String path, [String bucket = 'images']) {
    return supabase.storage.from(bucket).getPublicUrl("$tenantId/$path");
  }

  void setCurrentRoute(String? route) {
    currentRoute = route;
    notifyListeners();
  }
}
