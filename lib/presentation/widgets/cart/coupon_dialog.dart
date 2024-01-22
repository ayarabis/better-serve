import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../common/dialog_pane.dart';
import '/domain/models/coupon.dart';

class CouponDialog extends StatefulWidget {
  final Coupon? value;
  final Function(String) onComplete;
  final VoidCallback? onRemove;
  const CouponDialog(
      {super.key, this.value, required this.onComplete, this.onRemove});

  @override
  State<CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<CouponDialog> {
  late TextEditingController _codeController;
  String value = "";

  @override
  void initState() {
    value = widget.value?.code ?? '';
    _codeController = TextEditingController(text: value);
    _codeController.addListener(() {
      setState(() {
        value = _codeController.text;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogPane(
      tag: "coupon",
      width: 400,
      header: const Row(
        children: [
          Icon(MdiIcons.ticketOutline),
          SizedBox(
            width: 5,
          ),
          Text("Add Coupon"),
        ],
      ),
      footer: Row(
        children: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Close"),
          ),
          const SizedBox(
            width: 10,
          ),
          if (widget.value != null) ...[
            OutlinedButton(
              onPressed: () {
                widget.onRemove?.call();
              },
              child: const Text("Remove"),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
          Expanded(
            child: FilledButton(
              onPressed: _codeController.text.isEmpty
                  ? null
                  : () {
                      if (widget.value == null) {
                        widget.onComplete(_codeController.text);
                      }
                      Navigator.of(context).pop();
                    },
              child: const Text("Ok"),
            ),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              readOnly: widget.value != null,
              controller: _codeController,
              inputFormatters: [
                UpperCaseTextFormatter(),
              ],
              canRequestFocus: widget.value == null,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                icon: const Icon(MdiIcons.text),
                hintText: "Coupon Code",
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                suffixIcon: widget.value == null
                    ? IconButton(
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        onPressed: _codeController.clear,
                        icon: const Icon(Icons.clear),
                      )
                    : const SizedBox(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
