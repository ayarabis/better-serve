import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../providers/coupon_provider.dart';
import '../common/custom_dialog.dart';
import '/core/util.dart';
import '/domain/models/coupon.dart';

class CouponDeleteDialog extends StatefulWidget {
  final List<Coupon> coupons;
  final VoidCallback callback;
  const CouponDeleteDialog(this.coupons, this.callback, {super.key});

  @override
  State<CouponDeleteDialog> createState() => _CouponDeleteDialogState();
}

class _CouponDeleteDialogState extends State<CouponDeleteDialog> {
  bool deleting = false;

  final CouponProvider couponProvider = CouponProvider();

  @override
  Widget build(BuildContext context) {
    List<Coupon> coupons = widget.coupons;
    return CustomDialog(
      title: "Delete Couopon${coupons.length > 1 ? "s" : ""}?",
      content: coupons.length == 1
          ? "Are you sure you want to delete coupon ${coupons[0].code}"
          : "Are you sure you want to delete ${coupons.length} coupon${coupons.length > 1 ? "s" : ""}?",
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
              couponProvider.deleteCoupons(coupons).then((r) {
                r.fold((l) {
                  showToast(context, child: Text(l.message));
                  setState(() {
                    deleting = false;
                  });
                }, (r) {
                  showToast(context,
                      child: Text("${coupons.length} addons deleted"));
                  Navigator.of(context).pop();
                });
              });
            },
    );
  }
}
