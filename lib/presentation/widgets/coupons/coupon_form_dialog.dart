import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../providers/coupon_provider.dart';
import '../../providers/setting_provider.dart';
import '../common/dialog_pane.dart';
import '/core/enums/discount_type.dart';
import '/data/models/discount.dart';
import '/domain/models/coupon.dart';

class CouponFormDialog extends StatefulWidget {
  final Coupon? coupon;
  const CouponFormDialog({Key? key, this.coupon}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CouponFormDialogState();
}

class _CouponFormDialogState extends State<CouponFormDialog> {
  String code = "";
  String description = "";
  String quantity = "";
  String discountValue = "";
  DiscountType discountType = DiscountType.fixed;

  late TextEditingController _codeController;
  late TextEditingController _descController;
  late TextEditingController _qtyController;
  late TextEditingController _valueController;

  final SettingProvider settingProvider = SettingProvider();
  final CouponProvider couponProvider = CouponProvider();

  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> discountTypes = [
    {
      'value': "Fixed",
      'label': "Fixed",
    },
    {
      'value': "Rate",
      'label': "Rate",
    }
  ];

  @override
  void initState() {
    if (widget.coupon != null) {
      code = widget.coupon!.code;
      description = widget.coupon!.description;
      quantity = widget.coupon!.quantity.toString();
      discountValue = widget.coupon!.discount.value.toString();
      discountType = widget.coupon!.discount.type;
    }
    _codeController = TextEditingController(text: code);
    _descController = TextEditingController(text: description);
    _qtyController = TextEditingController(text: quantity);
    _valueController = TextEditingController(text: discountValue);
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Coupon? coupon = widget.coupon;
    return DialogPane(
      tag: coupon == null ? "add_coupon" : "edit_coupon_${coupon.id}",
      width: 400,
      builder: (context, toggleLoadding) {
        return Padding(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        const Icon(Icons.add),
                        Text(
                          coupon == null ? "Create New Coupon" : "Edit Coupon",
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                  ],
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Code',
                    icon: Icon(MdiIcons.barcode),
                  ),
                  onChanged: (value) {
                    setState(() {
                      code = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Code is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Description',
                    icon: Icon(MdiIcons.text),
                  ),
                  onChanged: (value) {
                    setState(() {
                      description = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Qantity',
                    icon: Icon(MdiIcons.counter),
                  ),
                  onChanged: (value) {
                    setState(() {
                      quantity = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Quantity is required';
                    }
                    return null;
                  },
                ),
                SelectFormField(
                  type: SelectFormFieldType.dropdown,
                  labelText: 'Discount Type',
                  items: discountTypes,
                  initialValue: discountType.name,
                  decoration: const InputDecoration(
                    icon: Icon(
                      MdiIcons.ticketPercentOutline,
                      size: 18,
                    ),
                  ),
                  onChanged: (val) => setState(() {
                    setState(() {
                      discountType = DiscountType.fromValue(val);
                    });
                  }),
                ),
                TextFormField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    isDense: true,
                    labelText: 'Discount Value',
                    icon: Icon(MdiIcons.calculator),
                  ),
                  onChanged: (value) {
                    setState(() {
                      discountValue = value;
                    });
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Discount Value is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
      footerBuilder: (context, toggleLoadding) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel")),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: FilledButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    toggleLoadding();
                    if (coupon != null) {
                    } else {
                      coupon = Coupon(
                          code: code,
                          description: description,
                          discount: Discount(
                            discountType,
                            int.parse(discountValue),
                          ),
                          quantity: int.parse(quantity),
                          usageCount: 0);
                    }
                    couponProvider.saveCoupon(coupon!).then((res) {
                      Navigator.of(context).pop();
                    });
                  }
                },
                child: const Icon(
                  Icons.check,
                  size: 30,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
