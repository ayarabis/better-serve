import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../drawer/manager_navigation_drawer.dart';
import '../widgets/route_builder/fade_route.dart';
import '/constants.dart';
import '/domain/models/category.dart';
import '/presentation/pages/manager/coupons_page.dart';
import '/presentation/providers/app_provider.dart';
import '/presentation/widgets/products/products_category_navigation.dart';
import 'admin/users_page.dart';
import 'manager/addons_page.dart';
import 'manager/categories_page.dart';
import 'manager/media_page.dart';
import 'manager/products_page.dart';

class ManagerPage extends StatefulWidget {
  const ManagerPage({Key? key}) : super(key: key);

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  String page = ManagerNavigationDrawer.initialPage;

  @override
  void initState() {
    AppProvider().currentRoute = "products";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final initialPage =
        (ModalRoute.of(context)!.settings.arguments ?? "products") as String;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          shadowColor: Colors.grey,
          title: Row(
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: 30,
              ),
              const SizedBox(
                width: 10,
              ),
              const Text("Better Serve"),
            ],
          ),
        ),
        drawer: const ManagerNavigationDrawer(),
        bottomNavigationBar:
            Consumer<AppProvider>(builder: (context, appProvider, child) {
          return OrientationBuilder(builder: (context, orientation) {
            return (appProvider.currentRoute == "products" &&
                    orientation == Orientation.portrait)
                ? const ProductsCategoryNavigation(
                    orientation: Orientation.landscape,
                  )
                : const SizedBox();
          });
        }),
        body: Navigator(
          key: NavigatorKeys.manager,
          initialRoute: initialPage,
          onGenerateRoute: (settings) {
            Function(BuildContext, Object?) builder =
                _routeBuilders[settings.name]!;
            return FadeRoute(
              widget: Material(
                child: builder(context, settings.arguments),
              ),
            );
          },
        ),
      ),
    );
  }

  Map<String, Function(BuildContext, Object?)> get _routeBuilders {
    return {
      'products': (context, args) => ProductsPage(args as Category?),
      'categories': (context, args) => const CategoriesPage(),
      'addons': (context, args) => const AddonsPage(),
      'coupons': (context, args) => const CouponsPage(),
      'media': (context, args) => const MediaPage(),
      'users': (context, args) => const UsersPage(),
    };
  }
}
