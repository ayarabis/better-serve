import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../providers/product_provider.dart';
import '../common/custom_dialog.dart';
import '/core/util.dart';
import '/domain/models/product.dart';

class ProductDeleteDialog extends StatefulWidget {
  final List<Product> product;
  final VoidCallback callback;
  const ProductDeleteDialog(this.product, this.callback, {super.key});

  @override
  State<ProductDeleteDialog> createState() => _ProductDeleteDialogState();
}

class _ProductDeleteDialogState extends State<ProductDeleteDialog> {
  bool deleting = false;

  final ProductProvider productProvider = ProductProvider();

  @override
  Widget build(BuildContext context) {
    List<Product> products = widget.product;
    return CustomDialog(
      title: "Delete Product${products.length > 1 ? "s" : ""}?",
      content:
          "Are you sure you want to delete ${products.length} product${products.length > 1 ? "s" : ""}?",
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
              productProvider.deleteProducts(products).then((r) {
                r.fold((l) {
                  showToast(context, child: Text(l.message));
                }, (r) {
                  showToast(context,
                      child: Text("${products.length} Products deleted"));
                  Navigator.of(context).pop();
                  widget.callback();
                });
              });
            },
    );
  }
}
