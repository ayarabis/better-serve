import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/addon_provider.dart';
import '../common/custom_dialog.dart';
import '/core/util.dart';
import '/domain/models/addon.dart';

class AddonDeleteDialog extends StatefulWidget {
  final List<Addon> addons;
  final VoidCallback callback;
  const AddonDeleteDialog(this.addons, this.callback, {super.key});

  @override
  State<AddonDeleteDialog> createState() => _AddonDeleteDialogState();
}

class _AddonDeleteDialogState extends State<AddonDeleteDialog> {
  bool deleting = false;
  @override
  Widget build(BuildContext context) {
    List<Addon> addons = widget.addons;
    return Consumer<AddonProvider>(builder: (context, addonProvider, _) {
      return CustomDialog(
        title: "Delete Addon${addons.length > 1 ? "s" : ""}?",
        content:
            "Are you sure you want to delete ${addons.length} addon${addons.length > 1 ? "s" : ""}?",
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
                addonProvider.deleteAddons(addons).then((r) {
                  r.fold((l) {
                    showToast(context, child: Text(l.message));
                  }, (r) {
                    showToast(context,
                        child: Text("${addons.length} addons deleted"));
                    Navigator.of(context).pop();
                    widget.callback();
                  });
                });
              },
      );
    });
  }
}
