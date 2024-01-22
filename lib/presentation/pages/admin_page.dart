import 'package:flutter/material.dart';

import '../widgets/route_builder/fade_route.dart';
import '/constants.dart';
import '/presentation/drawer/admin_navigation_drawer.dart';
import '/presentation/pages/admin/roles_page.dart';
import '/presentation/pages/admin/users_page.dart';

class AdminPage extends StatelessWidget {
  static String initialPage = "roles";
  static String currentPath = initialPage;

  const AdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AdminPage.currentPath = initialPage;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
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
        drawer: const AdminNavigationDrawer(),
        body: Navigator(
          key: NavigatorKeys.admin,
          initialRoute: AdminNavigationDrawer.initialPage,
          onGenerateRoute: (settings) {
            AdminPage.currentPath = settings.name!;
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
      'roles': (context, args) => const RolesPage(),
      'users': (context, args) => const UsersPage(),
    };
  }
}
