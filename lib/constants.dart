import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/settings.dart';

final supabase = Supabase.instance.client;
final settings = Settings();
final logger = Logger();

final dateFormat = DateFormat("yyyy-MM-dd");
final timeFormat = DateFormat("HH:mm:ss");

class NavigatorKeys {
  static final GlobalKey<NavigatorState> primary = GlobalKey();
  static final GlobalKey<NavigatorState> manager = GlobalKey();
  static final GlobalKey<NavigatorState> admin = GlobalKey();
}

BuildContext get primaryContext => NavigatorKeys.primary.currentContext!;
BuildContext get managerContext => NavigatorKeys.manager.currentContext!;
BuildContext get adminContext => NavigatorKeys.admin.currentContext!;
