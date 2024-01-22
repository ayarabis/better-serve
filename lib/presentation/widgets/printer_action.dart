import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/constants.dart';
import '/core/util.dart';
import '../providers/printer_provider.dart';
import 'printer_setting_dialog.dart';

class PrinterAction extends StatefulWidget {
  const PrinterAction({super.key});

  @override
  State<PrinterAction> createState() => _PrinterActionState();
}

class _PrinterActionState extends State<PrinterAction> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "printer_settings",
      child: Material(
        color: Colors.transparent,
        child: IconButton(
          onPressed: () {
            pushHeroDialog(primaryContext, const PrinterSettingDialog(), true);
          },
          icon:
              Consumer<PrinterProvider>(builder: (context, printerProvider, _) {
            if (printerProvider.isConnected) {
              return const Icon(Icons.print_rounded);
            }
            return const Icon(Icons.print_disabled);
          }),
          splashRadius: 20,
        ),
      ),
    );
  }
}
