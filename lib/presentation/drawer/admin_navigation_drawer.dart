import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '/constants.dart';
import '/presentation/pages/admin_page.dart';
import 'navigation_drawer_header.dart';

class AdminNavigationDrawer extends StatefulWidget {
  static const initialPage = "users";
  const AdminNavigationDrawer({super.key});

  @override
  State<AdminNavigationDrawer> createState() => _AdminNavigationDrawerState();
}

class _AdminNavigationDrawerState extends State<AdminNavigationDrawer> {
  List<dynamic> navItems = List.from([
    {"icon": MdiIcons.accountMultiple, "name": "Manage Users", "path": "users"},
    {"icon": MdiIcons.badgeAccount, "name": "Manage Roles", "path": "roles"},
  ]);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        const NavigationDrawerHeader(),
        for (var i = 0; i < navItems.length; i++)
          menuItem(navItems[i]["icon"], navItems[i]["name"], () {
            Navigator.of(primaryContext).pop();

            if (AdminPage.currentPath == navItems[i]["path"]) {
              return;
            }
            Navigator.of(adminContext)
                .pushNamedAndRemoveUntil(navItems[i]["path"], (route) => false);
          }),
        const Spacer(),
        const Divider(height: 1.0, color: Colors.grey),
        menuItem(Icons.exit_to_app, "Exit", () => _exitAdmin(context))
      ]),
    );
  }

  Future<void> _exitAdmin(BuildContext context) async {
    Navigator.of(context).pushNamedAndRemoveUntil("/home", (route) => false);
  }

  Widget menuItem(IconData ic, String text, void Function() onTap) {
    return ListTile(leading: Icon(ic), title: Text(text), onTap: onTap);
  }
}
