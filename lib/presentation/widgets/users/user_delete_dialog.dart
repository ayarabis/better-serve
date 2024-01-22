import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../common/custom_dialog.dart';
import '/core/util.dart';
import '/domain/models/profile.dart';
import '/presentation/providers/user_provider.dart';

class UserDeleteDialog extends StatefulWidget {
  final Profile profile;
  const UserDeleteDialog({super.key, required this.profile});

  @override
  State<UserDeleteDialog> createState() => _UserDeleteDialogState();
}

class _UserDeleteDialogState extends State<UserDeleteDialog> {
  final UserProvider userProvider = UserProvider();

  bool deleting = false;

  @override
  Widget build(BuildContext context) {
    Profile user = widget.profile;
    return Hero(
      tag: "delete_user_${user.id}",
      child: CustomDialog(
        title: "Delete User?",
        content: "Are you sure you want to delete (${user.email})",
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
                userProvider.deleteUser(user).then((r) {
                  r.fold((l) {
                    showToast(context, child: Text(l.message));
                    setState(() {
                      deleting = false;
                    });
                  }, (r) {
                    showToast(context,
                        child: Text("User (${user.email}) deleted"));
                    Navigator.of(context).pop();
                  });
                });
              },
      ),
    );
  }
}
