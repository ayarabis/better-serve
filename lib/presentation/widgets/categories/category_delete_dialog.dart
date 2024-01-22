import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/category_provider.dart';
import '../common/custom_dialog.dart';
import '/core/util.dart';
import '/domain/models/category.dart';

class CategoryDeleteDialog extends StatefulWidget {
  final Category category;
  const CategoryDeleteDialog(this.category, {super.key});

  @override
  State<CategoryDeleteDialog> createState() => _CategoryDeleteDialogState();
}

class _CategoryDeleteDialogState extends State<CategoryDeleteDialog> {
  bool deleting = false;

  @override
  Widget build(BuildContext context) {
    Category category = widget.category;
    return Consumer<CategoryProvider>(builder: (context, categiryProvider, _) {
      return Hero(
        tag: "delete_category_${category.id}",
        child: CustomDialog(
          title: "Delete Category?",
          content: "Are you sure you want to delete (${category.name})",
          positiveBtnText: "Yes",
          negativeBtnText: "Cancel",
          type: DialogType.error,
          destructive: true,
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
                  categiryProvider.deleteCategory(category).then((r) {
                    r.fold((l) {
                      showToast(context, child: Text(l.message));
                      setState(() {
                        deleting = false;
                      });
                    }, (r) {
                      showToast(context,
                          child: Text("Category (${category.name}) deleted"));
                      Navigator.of(context).pop();
                    });
                  });
                },
        ),
      );
    });
  }
}
