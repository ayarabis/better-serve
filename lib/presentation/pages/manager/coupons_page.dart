import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../providers/coupon_provider.dart';
import '../../widgets/coupons/coupon_delete_dialog.dart';
import '../../widgets/coupons/coupon_form_dialog.dart';
import '/constants.dart';
import '/core/util.dart';
import '/domain/models/coupon.dart';
import '/presentation/widgets/common/button.dart';

class CouponsPage extends StatefulWidget {
  const CouponsPage({super.key});

  @override
  State<CouponsPage> createState() => _CouponsPageState();
}

class _CouponsPageState extends State<CouponsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CouponProvider>(
      builder: (context, couponProvider, _) {
        List<Coupon> coupons = couponProvider.coupons;
        List<Coupon> selected = coupons.where((c) => c.selected).toList();
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: AnimatedCrossFade(
                firstChild: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            MdiIcons.ticketPercent,
                            size: 15,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${couponProvider.coupons.length} Coupons",
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    PrimaryButton(
                      onPressed: () {
                        pushHeroDialog(
                            primaryContext, const CouponFormDialog());
                      },
                      icon: const Icon(Icons.add),
                      text: 'Add',
                    )
                  ],
                ),
                secondChild: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            MdiIcons.ticketPercent,
                            size: 15,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            "${selected.length}/${couponProvider.coupons.length} Selected",
                            style: const TextStyle(fontSize: 20),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          for (var e in couponProvider.coupons) {
                            e.selected = false;
                          }
                        });
                      },
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.redAccent),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CouponDeleteDialog(selected, () {
                              setState(() {
                                selected.clear();
                              });
                            });
                          },
                        );
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.delete,
                            size: 20,
                            color: Colors.white,
                          ),
                          Text(
                            "Delete",
                            style: TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                crossFadeState: selected.isEmpty
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 100),
              ),
            ),
            const Divider(
              height: 5,
            ),
            Expanded(
              child: couponProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : couponProvider.coupons.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: DataTable(
                                  columnSpacing: 12,
                                  horizontalMargin: 12,
                                  columns: const [
                                    DataColumn(
                                      label: Text(''),
                                    ),
                                    DataColumn(
                                      label: Text('Code'),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Description',
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text('Quantity'),
                                    ),
                                    DataColumn(
                                      label: Text('Discount Type'),
                                    ),
                                    DataColumn(
                                      label: Text('Discount Value'),
                                    ),
                                    DataColumn(
                                      label: Text('Usage Count'),
                                    ),
                                    DataColumn(
                                      label: Text('Quantity'),
                                    ),
                                    DataColumn(
                                      label: Text(""),
                                    ),
                                  ],
                                  rows: [
                                    for (Coupon coupon
                                        in couponProvider.coupons)
                                      DataRow(
                                        cells: [
                                          DataCell(
                                            Checkbox(
                                              value: coupon.selected,
                                              onChanged: (v) {
                                                setState(() {
                                                  coupon.selected = v!;
                                                });
                                              },
                                            ),
                                          ),
                                          DataCell(Text(coupon.code)),
                                          DataCell(Text(coupon.description)),
                                          DataCell(
                                              Text(coupon.quantity.toString())),
                                          DataCell(
                                              Text(coupon.discount.type.name)),
                                          DataCell(
                                            Text(coupon.discount.value
                                                .toString()),
                                          ),
                                          DataCell(
                                            Text(coupon.usageCount.toString()),
                                          ),
                                          DataCell(
                                            Text(coupon.quantity.toString()),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Hero(
                                                  tag:
                                                      "edit_coupon_${coupon.id}",
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: IconButton(
                                                      splashRadius: 20,
                                                      onPressed: () {
                                                        pushHeroDialog(
                                                            primaryContext,
                                                            CouponFormDialog(
                                                              coupon: coupon,
                                                            ));
                                                      },
                                                      icon: const Icon(
                                                        Icons.edit,
                                                        color: Colors.blue,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Hero(
                                                  tag:
                                                      "delete_coupon_${coupon.id}",
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    child: IconButton(
                                                      splashRadius: 20,
                                                      onPressed: () {
                                                        pushHeroDialog(
                                                          primaryContext,
                                                          CouponDeleteDialog(
                                                              [coupon], () {}),
                                                          true,
                                                        );
                                                      },
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.redAccent,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/coupons.png",
                              width: 200,
                              opacity: const AlwaysStoppedAnimation(100),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Add your first coupon",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            const Text(
                              "Tap '+ Add' button to add coupon",
                              style:
                                  TextStyle(fontSize: 15, color: Colors.grey),
                            )
                          ],
                        ),
            )
          ],
        );
      },
    );
  }
}
