import 'package:better_serve/presentation/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '/constants.dart';
import 'navigation_drawer_header.dart';

class ManagerNavigationDrawer extends StatefulWidget {
  static const initialPage = "dashboard";
  const ManagerNavigationDrawer({super.key});

  @override
  State<ManagerNavigationDrawer> createState() =>
      _ManagerNavigationDrawerState();
}

class _ManagerNavigationDrawerState extends State<ManagerNavigationDrawer> {
  List<dynamic> navItems = List.from([
    {"icon": MdiIcons.store, "name": "Products", "path": "products"},
    {"icon": MdiIcons.shape, "name": "Categories", "path": "categories"},
    {"icon": MdiIcons.food, "name": "Addons", "path": "addons"},
    {"icon": MdiIcons.ticketPercent, "name": "Coupons", "path": "coupons"},
    {"icon": MdiIcons.image, "name": "Media", "path": "media"},
  ]);

  AppProvider appProvider = AppProvider();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(children: [
                const NavigationDrawerHeader(),
                for (var i = 0; i < navItems.length; i++)
                  menuItem(navItems[i]["icon"], navItems[i]["name"], () {
                    Navigator.of(primaryContext).pop();

                    if (appProvider.currentRoute == navItems[i]["path"]) {
                      return;
                    }
                    Navigator.of(managerContext).pushNamedAndRemoveUntil(
                        navItems[i]["path"], (route) => false);
                    appProvider.setCurrentRoute(navItems[i]["path"]);
                  }),
                const Spacer(),
                const Divider(height: 1.0, color: Colors.grey),
                menuItem(Icons.exit_to_app, "Exit", () => _exitManager(context))
              ]),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _exitManager(BuildContext context) async {
    Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
  }

  Widget menuItem(IconData ic, String text, void Function() onTap) {
    return ListTile(leading: Icon(ic), title: Text(text), onTap: onTap);
  }
}
