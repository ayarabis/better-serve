import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/breakpoint.dart';
import 'package:responsive_framework/responsive_breakpoints.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '/presentation/pages/admin_page.dart';
import '/presentation/pages/manager/dashboard_page.dart';
import '/presentation/providers/attribute_provider.dart';
import '/presentation/providers/variation_provider.dart';
import 'constants.dart';
import 'presentation/pages/cart_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/manager_page.dart';
import 'presentation/pages/orders_page.dart';
import 'presentation/pages/post_register.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/transactions_page.dart';
import 'presentation/providers/addon_provider.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/coupon_provider.dart';
import 'presentation/providers/file_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/printer_provider.dart';
import 'presentation/providers/product_provider.dart';
import 'presentation/providers/role_provider.dart';
import 'presentation/providers/setting_provider.dart';
import 'presentation/providers/user_provider.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  String? supabaseUrl = dotenv.env['SUPABASE_URL'];
  String? supbaseAnonKey = dotenv.env['SUPABASE_ANON'];

  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl!,
    anonKey: supbaseAnonKey!,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => AddonProvider()),
        ChangeNotifierProvider(create: (_) => FileProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => CouponProvider()),
        ChangeNotifierProvider(create: (_) => PrinterProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => VariationProvider()),
        ChangeNotifierProvider(create: (_) => AttributeProvider()),
      ],
      child: Consumer<SettingProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: "Better Serve",
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: settingsProvider.primaryColor,
              ),
              checkboxTheme: CheckboxThemeData(
                fillColor:
                    MaterialStateProperty.all(settingsProvider.primaryColor),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: settingsProvider.primaryColor,
                brightness: Brightness.dark,
              ),
              checkboxTheme: CheckboxThemeData(
                fillColor:
                    MaterialStateProperty.all(settingsProvider.primaryColor),
              ),
            ),
            builder: (context, child) => ResponsiveBreakpoints.builder(
              child: child!,
              useShortestSide: true,
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP)
              ],
            ),
            themeMode: settingsProvider.themeMode,
            initialRoute: '/',
            navigatorKey: NavigatorKeys.primary,
            routes: <String, WidgetBuilder>{
              '/': (_) => const SplashPage(),
              '/login': (_) => const LoginPage(),
              '/register': (_) => const RegisterPage(),
              '/post-register': (_) => const PostRegisterPage(),
              '/home': (_) => const HomePage(),
              '/dashboard': (_) => const DashboardPage(),
              '/manager': (_) => const ManagerPage(),
              '/admin': (_) => const AdminPage(),
              '/transactions': (_) => const TransactionsPage(),
              '/orders': (_) => const OrdersPage(),
              '/cart': (_) => const CartPage(),
            },
          );
        },
      ),
    );
  }
}
