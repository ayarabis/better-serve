import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../pages/settings_page.dart';
import '../providers/auth_provider.dart';
import '/constants.dart';
import '/core/util.dart';
import 'navigation_drawer_header.dart';

class MainNavigationDrawer extends StatefulWidget {
  const MainNavigationDrawer({super.key});

  @override
  State<MainNavigationDrawer> createState() => _MainNavigationDrawerState();
}

class _MainNavigationDrawerState extends State<MainNavigationDrawer> {
  List<dynamic> navItems = List.from([
    {"icon": MdiIcons.viewDashboard, "name": "Dashboard", "path": "/dashboard"},
    if (permissions.contains('manage_inventory'))
      {"icon": Icons.inventory, "name": "Manage Inventory", "path": "/manager"},
    if (permissions.contains('manage_users'))
      {
        "icon": Icons.admin_panel_settings,
        "name": "Administration",
        "path": "/admin"
      },
    {
      "icon": MdiIcons.listStatus,
      "name": "Transactions",
      "path": "/transactions"
    },
  ]);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                children: <Widget>[
                  const NavigationDrawerHeader(),
                  for (var i = 0; i < navItems.length; i++)
                    menuItem(navItems[i]["icon"], navItems[i]["name"], () {
                      Navigator.of(primaryContext).pop();
                      Navigator.of(primaryContext)
                          .pushNamed(navItems[i]["path"]);
                    }),
                  menuItem(Icons.settings, "Settings", () {
                    Navigator.of(primaryContext).pop();
                    pushHeroDialog(context, const SettingsPage());
                  }),
                  const Spacer(),
                  const Divider(height: 1.0, color: Colors.grey),
                  menuItem(Icons.exit_to_app, "Sign out", _signOut)
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _signOut() async {
    showLoading(context);
    AuthProvider().signOut().then((_) => Navigator.of(context)
        .pushNamedAndRemoveUntil("/login", (route) => false));
  }

  Widget menuItem(IconData ic, String text, void Function() onTap) {
    return ListTile(leading: Icon(ic), title: Text(text), onTap: onTap);
  }
}
