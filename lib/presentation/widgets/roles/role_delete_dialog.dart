import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/role_provider.dart';
import '../common/custom_dialog.dart';
import '/core/util.dart';
import '/domain/models/role.dart';

class RoleDeleteDialog extends StatefulWidget {
  final List<Role> roles;
  final VoidCallback? callback;
  const RoleDeleteDialog(this.roles, this.callback, {super.key});

  @override
  State<RoleDeleteDialog> createState() => _RoleDeleteDialogState();
}

class _RoleDeleteDialogState extends State<RoleDeleteDialog> {
  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    List<Role> roles = widget.roles;
    return Consumer<RoleProvider>(builder: (context, roleProvider, _) {
      return CustomDialog(
        title: "Delete Role${roles.length > 1 ? "s" : ""}?",
        content: roles.length == 1
            ? "Are you sure you want to delete role ${roles[0].name}?"
            : "Are you sure you want to delete ${roles.length} role${roles.length > 1 ? "s" : ""}?",
        positiveBtnText: "Yes",
        negativeBtnText: "Cancel",
        destructive: true,
        type: DialogType.error,
        icon: CircleAvatar(
          maxRadius: 40.0,
          backgroundColor: Colors.redAccent,
          child: deleting
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : const Icon(
                  MdiIcons.trashCan,
                  size: 30,
                  color: Colors.white,
                ),
        ),
        onPositive: deleting
            ? null
            : () {
                setState(() {
                  deleting = true;
                });
                roleProvider.deleteRoles(roles).then((r) {
                  r.fold((l) {
                    showToast(context, child: Text(l.message));
                  }, (r) {
                    showToast(context,
                        child: Text(roles.length == 1
                            ? "Role ${roles[0].name} deleted"
                            : "${roles.length} roles deleted"));
                    Navigator.of(context).pop();
                    widget.callback?.call();
                  });
                });
              },
      );
    });
  }
}
